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
        let weatherPenalty = trip.weatherSnapshots.contains { $0.precipitation > Constants.Weather.precipitationThreshold } ? Constants.Difficulty.weatherPenalty : 0

        // Edge case: if average roughness is below threshold, it's likely not real off-roading
        // (e.g., highway driving, paved roads). Apply a penalty to the score.
        let isRealOffroading = avgRough >= Constants.Difficulty.minOffroadRoughness
        
        // Vehicle-specific adjustments
        var vehicleAdjustment: Double = 0
        if trip.vehicleData.vehicleType == .bronco {
            // Terrain mode indicates difficulty level
            if let terrain = trip.vehicleData.terrainMode {
                switch terrain {
                case .rockCrawl:
                    vehicleAdjustment += Constants.Bronco.rockCrawlBonus
                case .baja:
                    vehicleAdjustment += Constants.Bronco.bajaBonus
                case .sandMud:
                    vehicleAdjustment += Constants.Bronco.sandMudBonus
                case .slippery:
                    vehicleAdjustment += Constants.Bronco.slipperyBonus
                default:
                    break
                }
            }

            // Lockers engaged = difficult terrain attempted
            if trip.vehicleData.frontLockerEngaged || trip.vehicleData.rearLockerEngaged {
                vehicleAdjustment += Constants.Bronco.lockerBonus
            }

            // 4WD Low = serious off-roading
            if trip.vehicleData.driveMode == .fourWDLow {
                vehicleAdjustment += Constants.Bronco.fourWDLowBonus
            }

            // Winch used = extreme difficulty
            if trip.vehicleData.winchUsed {
                vehicleAdjustment += Constants.Bronco.winchBonus
            }

            // Trail Control/Turn Assist = indicates challenging navigation
            if trip.vehicleData.trailControlActive || trip.vehicleData.trailTurnAssistActive {
                vehicleAdjustment += Constants.Bronco.trailControlBonus
            }
        }
        
        // Sutton Score calculation (0-100)
        let gradeScore = min(Constants.Difficulty.maxGradePoints, maxGrade / Constants.Difficulty.gradeDivisor)
        let roughnessScore = min(Constants.Difficulty.maxRoughnessPoints, avgRough * Constants.Difficulty.roughnessMultiplier)
        let gForceScore = min(Constants.Difficulty.maxGForcePoints, maxGForce * Constants.Difficulty.gForceMultiplier)
        let pitchScore = min(Constants.Difficulty.maxPitchPoints, maxPitch / Constants.Difficulty.pitchDivisor)

        var totalScore = gradeScore + roughnessScore + gForceScore + pitchScore + Double(weatherPenalty) + vehicleAdjustment

        // Apply penalty if not real off-roading (smooth road driving)
        if !isRealOffroading {
            totalScore *= 0.5 // 50% penalty for non-offroad conditions
        }

        ratings.suttonScore = Int(totalScore)
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