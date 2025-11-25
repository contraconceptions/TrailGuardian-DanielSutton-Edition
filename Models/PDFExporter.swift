import SwiftUI
import PDFKit
import MapKit

class PDFExporter {
    static func generatePDF(for trip: Trip, mapSnapshot: UIImage) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        return renderer.pdfData { ctx in
            ctx.beginPage()
            
            // Title
            let title = "Trail Summary – \(trip.title) | Daniel Sutton Edition"
            title.draw(at: CGPoint(x: 40, y: 40), withAttributes: [.font: UIFont.boldSystemFont(ofSize: 24)])
            
            // Map
            mapSnapshot.draw(in: CGRect(x: 40, y: 80, width: 532, height: 300))
            
            // Stats & Ratings
            let statsY = 400.0
            let stats = """
            Started: \(trip.startedAt.formatted())
            Sutton Score: \(trip.difficultyRatings.suttonScore)/100
            Max Pitch: \(trip.telemetryStats.maxPitch, specifier: "%.1f")°
            Weather: \(trip.weatherSnapshots.first?.condition ?? "Clear")
            """
            stats.draw(at: CGPoint(x: 40, y: statsY), withAttributes: [.font: UIFont.systemFont(ofSize: 16)])
        }
    }
}