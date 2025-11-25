import Foundation

class DifficultyCalculator {
    static func calculate(for trip: Trip) -> DifficultyRatings {
        var ratings = DifficultyRatings()
        
        guard !trip.points.isEmpty else {
            return ratings
        }
        
        // Calculate metrics
        let maxGrade = trip.points.map { abs($0.gradePercent) }.max() ?? 0
        let avgRough = trip.points.reduce(0) { $0 + $1.roughness } / Double(trip.points.count)
        let maxGForce = trip.telemetryStats.maxGForce
        let maxPitch = trip.telemetryStats.maxPitch
        let weatherPenalty = trip.weatherSnapshots.contains { $0.precipitation > 0.1 } ? 2 : 0
        
        // Bronco-specific adjustments
        var broncoAdjustment: Double = 0
        if trip.vehicleData.vehicleType == .bronco {
            // Terrain mode indicates difficulty level
            if let terrain = trip.vehicleData.terrainMode {
                switch terrain {
                case .rockCrawl:
                    broncoAdjustment += 5 // Rock Crawl = serious off-roading
                case .baja:
                    broncoAdjustment += 3 // Baja = high-speed off-road
                case .sandMud:
                    broncoAdjustment += 2 // Sand/Mud = challenging terrain
                case .slippery:
                    broncoAdjustment += 1 // Slippery = difficult conditions
                default:
                    break
                }
            }
            
            // Lockers engaged = difficult terrain attempted
            if trip.vehicleData.frontLockerEngaged || trip.vehicleData.rearLockerEngaged {
                broncoAdjustment += 3
            }
            
            // 4WD Low = serious off-roading
            if trip.vehicleData.driveMode == .fourWDLow {
                broncoAdjustment += 2
            }
            
            // Winch used = extreme difficulty
            if trip.vehicleData.winchUsed {
                broncoAdjustment += 4
            }
            
            // Trail Control/Turn Assist = indicates challenging navigation
            if trip.vehicleData.trailControlActive || trip.vehicleData.trailTurnAssistActive {
                broncoAdjustment += 1
            }
        }
        
        // Sutton Score calculation (0-100)
        let gradeScore = min(40, maxGrade / 2.5) // Max 40 points for grade
        let roughnessScore = min(30, avgRough * 100) // Max 30 points for roughness
        let gForceScore = min(20, maxGForce * 10) // Max 20 points for G-force
        let pitchScore = min(10, maxPitch / 2) // Max 10 points for pitch
        
        ratings.suttonScore = Int(gradeScore + roughnessScore + gForceScore + pitchScore + Double(weatherPenalty) + broncoAdjustment)
        ratings.suttonScore = min(100, max(0, ratings.suttonScore)) // Clamp to 0-100
        
        // Derived ratings
        ratings.jeepBadge = min(10, max(1, ratings.suttonScore / 10))
        
        if ratings.suttonScore > 70 {
            ratings.wellsRating = "Double Black ♦♦♦♦"
            ratings.usfsRating = "Most Difficult"
            ratings.international = "Double Black"
        } else if ratings.suttonScore > 40 {
            ratings.wellsRating = "Black Diamond ♦♦♦"
            ratings.usfsRating = "More Difficult"
            ratings.international = "Black"
        } else if ratings.suttonScore > 30 {
            ratings.wellsRating = "Blue Square ♦♦"
            ratings.usfsRating = "More Difficult"
            ratings.international = "Red"
        } else {
            ratings.wellsRating = "Green Circle ●"
            ratings.usfsRating = "Easiest"
            ratings.international = "Blue"
        }
        
        return ratings
    }
}