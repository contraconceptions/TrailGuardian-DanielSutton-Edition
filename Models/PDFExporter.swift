import SwiftUI
import PDFKit
import MapKit

class PDFExporter {
    static func generatePDF(for trip: Trip, mapSnapshot: UIImage) -> Data? {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        
        do {
            return try renderer.pdfData { ctx in
                ctx.beginPage()
                
                var yPosition: CGFloat = 40
                
                // Title
                let title = "Trail Summary – \(trip.title) | Daniel Sutton Edition"
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .foregroundColor: UIColor.black
                ]
                title.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: titleAttributes)
                yPosition += 50
                
                // Map
                mapSnapshot.draw(in: CGRect(x: 40, y: yPosition, width: 532, height: 300))
                yPosition += 320
                
                // Stats & Ratings
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                
                let duration: String
                if let ended = trip.endedAt {
                    let interval = ended.timeIntervalSince(trip.startedAt)
                    let hours = Int(interval) / 3600
                    let minutes = (Int(interval) % 3600) / 60
                    duration = "\(hours)h \(minutes)m"
                } else {
                    duration = "Ongoing"
                }
                
                var stats = """
                Started: \(dateFormatter.string(from: trip.startedAt))
                Duration: \(duration)
                Points Recorded: \(trip.points.count)
                Sutton Score: \(trip.difficultyRatings.suttonScore)/100
                Jeep Badge: \(trip.difficultyRatings.jeepBadge)/10
                Max Pitch: \(String(format: "%.1f", trip.telemetryStats.maxPitch))°
                Max Roll: \(String(format: "%.1f", trip.telemetryStats.maxRoll))°
                Max G-Force: \(String(format: "%.2f", trip.telemetryStats.maxGForce))g
                Weather: \(trip.weatherSnapshots.first?.condition ?? "Unknown")
                """
                
                let statsAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.black
                ]
                stats.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: statsAttributes)
                yPosition += 180
                
                // Bronco Configuration Section
                if trip.vehicleData.vehicleType == .bronco {
                    let broncoTitle = "Ford Bronco Configuration"
                    let broncoTitleAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 18),
                        .foregroundColor: UIColor.blue
                    ]
                    broncoTitle.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: broncoTitleAttributes)
                    yPosition += 30
                    
                    var broncoInfo = ""
                    if let mode = trip.vehicleData.terrainMode {
                        broncoInfo += "Terrain Mode: \(mode.rawValue)\n"
                    }
                    if let drive = trip.vehicleData.driveMode {
                        broncoInfo += "Drive Mode: \(drive.rawValue)\n"
                    }
                    if trip.vehicleData.frontLockerEngaged || trip.vehicleData.rearLockerEngaged {
                        let lockers = "\(trip.vehicleData.frontLockerEngaged ? "Front " : "")\(trip.vehicleData.rearLockerEngaged ? "Rear" : "")"
                        broncoInfo += "Lockers: \(lockers)\n"
                    }
                    if trip.vehicleData.swayBarDisconnected {
                        broncoInfo += "Sway Bar: Disconnected\n"
                    }
                    if trip.vehicleData.trailControlActive {
                        broncoInfo += "Trail Control: Active\n"
                    }
                    if trip.vehicleData.trailTurnAssistActive {
                        broncoInfo += "Trail Turn Assist: Active\n"
                    }
                    if trip.vehicleData.winchUsed {
                        broncoInfo += "Winch: Used\n"
                    }
                    if let fuel = trip.vehicleData.fuelLevel {
                        broncoInfo += "Fuel Level: \(Int(fuel))%\n"
                    }
                    broncoInfo += "Data Source: \(trip.vehicleData.dataSource.rawValue)"
                    
                    let broncoAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 14),
                        .foregroundColor: UIColor.black
                    ]
                    broncoInfo.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: broncoAttributes)
                    yPosition += CGFloat(broncoInfo.components(separatedBy: "\n").count * 20)
                }
                
                // Camp Sites Section
                if !trip.campSites.isEmpty {
                    // Check if we need a new page
                    if yPosition > 700 {
                        ctx.beginPage()
                        yPosition = 40
                    }
                    
                    let campTitle = "Camp Sites (\(trip.campSites.count))"
                    let campTitleAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.boldSystemFont(ofSize: 18),
                        .foregroundColor: UIColor.purple
                    ]
                    campTitle.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: campTitleAttributes)
                    yPosition += 30
                    
                    for (index, site) in trip.campSites.enumerated() {
                        if yPosition > 750 {
                            ctx.beginPage()
                            yPosition = 40
                        }
                        
                        var campInfo = "\(index + 1). \(site.name)\n"
                        campInfo += "   Coordinates: \(String(format: "%.6f", site.latitude)), \(String(format: "%.6f", site.longitude))\n"
                        campInfo += "   Elevation: \(String(format: "%.0f", site.elevation))m\n"
                        campInfo += "   Rating: \(site.starRating)/5 stars\n"
                        if let desc = site.description {
                            campInfo += "   \(desc)\n"
                        }
                        if site.hasFireRing {
                            campInfo += "   Fire Ring: Yes\n"
                        }
                        if let water = site.waterSource {
                            campInfo += "   Water: \(water.type.rawValue) (\(Int(water.distance))m away)\n"
                        }
                        if let cell = site.cellService {
                            campInfo += "   Cell Service: \(cell ? "Yes" : "No")\n"
                        }
                        campInfo += "   Time: \(dateFormatter.string(from: site.timestamp))\n"
                        
                        let campAttributes: [NSAttributedString.Key: Any] = [
                            .font: UIFont.systemFont(ofSize: 12),
                            .foregroundColor: UIColor.black
                        ]
                        campInfo.draw(at: CGPoint(x: 40, y: yPosition), withAttributes: campAttributes)
                        yPosition += CGFloat(campInfo.components(separatedBy: "\n").count * 18)
                    }
                }
            }
        } catch {
            print("PDF generation error: \(error.localizedDescription)")
            return nil
        }
    }
}