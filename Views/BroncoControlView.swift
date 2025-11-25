import SwiftUI

struct BroncoControlView: View {
    @Binding var vehicleData: VehicleData
    @Environment(\.dismiss) var dismiss
    @State private var showingFordPass = false
    @State private var showingOBD = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Vehicle Type") {
                    Picker("Vehicle", selection: $vehicleData.vehicleType) {
                        ForEach(VehicleType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                if vehicleData.vehicleType == .bronco {
                    Section("Terrain Management System") {
                        Picker("Terrain Mode", selection: $vehicleData.terrainMode) {
                            Text("Not Set").tag(nil as BroncoTerrainMode?)
                            ForEach(BroncoTerrainMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode as BroncoTerrainMode?)
                            }
                        }
                        
                        Picker("Drive Mode", selection: $vehicleData.driveMode) {
                            Text("Not Set").tag(nil as DriveMode?)
                            ForEach(DriveMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode as DriveMode?)
                            }
                        }
                    }
                    
                    Section("Lockers & Off-Road Features") {
                        Toggle("Front Locker Engaged", isOn: $vehicleData.frontLockerEngaged)
                        Toggle("Rear Locker Engaged", isOn: $vehicleData.rearLockerEngaged)
                        Toggle("Sway Bar Disconnected", isOn: $vehicleData.swayBarDisconnected)
                        Toggle("Trail Control Active", isOn: $vehicleData.trailControlActive)
                        Toggle("Trail Turn Assist Active", isOn: $vehicleData.trailTurnAssistActive)
                        Toggle("Winch Used", isOn: $vehicleData.winchUsed)
                    }
                    
                    Section("Vehicle Status") {
                        HStack {
                            Text("Fuel Level")
                            Spacer()
                            if let fuel = vehicleData.fuelLevel {
                                Text("\(Int(fuel))%")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Not Set")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button("Set Fuel Level") {
                            // Simple input - could be enhanced with slider
                            // For now, placeholder
                        }
                        
                        if let pressure = vehicleData.tirePressure, pressure.count == 4 {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tire Pressure (PSI)")
                                    .font(.headline)
                                HStack {
                                    VStack {
                                        Text("FL")
                                        Text("\(Int(pressure[0]))")
                                    }
                                    VStack {
                                        Text("FR")
                                        Text("\(Int(pressure[1]))")
                                    }
                                    VStack {
                                        Text("RL")
                                        Text("\(Int(pressure[2]))")
                                    }
                                    VStack {
                                        Text("RR")
                                        Text("\(Int(pressure[3]))")
                                    }
                                }
                                .font(.caption)
                            }
                        }
                    }
                }
                
                Section("Data Sources") {
                    HStack {
                        Text("Current Source")
                        Spacer()
                        Text(vehicleData.dataSource.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Connect FordPass") {
                        showingFordPass = true
                    }
                    .disabled(!FordPassManager.shared.checkAvailability())
                    
                    Button("Connect OBD-II") {
                        showingOBD = true
                    }
                    .disabled(!OBDManager.shared.isAvailable)
                }
            }
            .navigationTitle("Bronco Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFordPass) {
                FordPassConnectView(vehicleData: $vehicleData)
            }
            .sheet(isPresented: $showingOBD) {
                OBDConnectView(vehicleData: $vehicleData)
            }
        }
    }
}

struct FordPassConnectView: View {
    @Binding var vehicleData: VehicleData
    @Environment(\.dismiss) var dismiss
    @StateObject private var fordPass = FordPassManager.shared
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var vin: String = ""
    @State private var isConnecting = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("FordPass API integration requires:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("• Ford Developer API access")
                    Text("• FordPass account")
                    Text("• Vehicle VIN registered")
                } header: {
                    Text("Requirements")
                }
                
                Section {
                    TextField("FordPass Username", text: $username)
                        .textContentType(.username)
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                    TextField("Vehicle VIN", text: $vin)
                        .textContentType(.none)
                        .autocapitalization(.allCharacters)
                } header: {
                    Text("Credentials")
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button("Connect") {
                        Task {
                            await connect()
                        }
                    }
                    .disabled(isConnecting || username.isEmpty || password.isEmpty || vin.isEmpty)
                    
                    if fordPass.isAuthenticated {
                        Button("Disconnect", role: .destructive) {
                            fordPass.disconnect()
                            vehicleData.dataSource = .manual
                        }
                    }
                }
            }
            .navigationTitle("FordPass")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func connect() async {
        isConnecting = true
        errorMessage = nil
        
        do {
            try await fordPass.authenticate(username: username, password: password)
            fordPass.vehicleVIN = vin
            vehicleData.dataSource = .fordPass
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isConnecting = false
    }
}

struct OBDConnectView: View {
    @Binding var vehicleData: VehicleData
    @Environment(\.dismiss) var dismiss
    @StateObject private var obd = OBDManager.shared
    @State private var isScanning = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("OBD-II integration requires:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("• Bluetooth Low Energy OBD-II adapter")
                    Text("• ELM327-compatible adapter")
                    Text("• Adapter plugged into OBD-II port")
                } header: {
                    Text("Requirements")
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    if obd.isConnected {
                        HStack {
                            Text("Connected")
                            Spacer()
                            if let device = obd.deviceName {
                                Text(device)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button("Disconnect", role: .destructive) {
                            obd.disconnect()
                            vehicleData.dataSource = .manual
                        }
                    } else {
                        Button("Scan for Adapters") {
                            Task {
                                await scan()
                            }
                        }
                        .disabled(isScanning || !obd.isAvailable)
                    }
                } header: {
                    Text("Connection")
                }
            }
            .navigationTitle("OBD-II")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func scan() async {
        isScanning = true
        errorMessage = nil
        
        do {
            try await obd.scanForDevices()
            vehicleData.dataSource = .obd2
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isScanning = false
    }
}

