import Foundation

class DifficultyCalculator {
    static func calculate(for trip: Trip) -> DifficultyRatings {
        var ratings = DifficultyRatings()
        // Simplified algo based on telemetry/weather
        let maxGrade = trip.points.map { $0.gradePercent }.max() ?? 0
        let avgRough = trip.points.reduce(0) { $0 + $1.roughness } / Double(trip.points.count)
        let weatherPenalty = trip.weatherSnapshots.contains { $0.precipitation > 0.1 } ? 2 : 0
        
        ratings.suttonScore = Int((maxGrade / 10) + (avgRough * 20) + Double(weatherPenalty))
        ratings.jeepBadge = min(10, ratings.suttonScore / 10)
        ratings.wellsRating = ratings.suttonScore > 70 ? "Double Black ♦♦♦♦" : ratings.suttonScore > 40 ? "Black Diamond ♦♦♦" : "Green Circle ●"
        ratings.usfsRating = ratings.suttonScore > 70 ? "Most Difficult" : ratings.suttonScore > 30 ? "More Difficult" : "Easiest"
        ratings.international = ratings.suttonScore > 80 ? "Double Black" : "Red"
        
        return ratings
    }
}