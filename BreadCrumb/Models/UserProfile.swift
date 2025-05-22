import Foundation

struct UserProfile: Codable {
    var name: String
    var dailyCalorieGoal: Int = 2000
    var favoriteCuisines: [String] = []
    var weight: Double = 0
    var goalWeight: Double = 0
    var activityLevel: ActivityLevel = .moderate
    
    enum CodingKeys: String, CodingKey {
        case name
        case dailyCalorieGoal = "daily_calorie_goal"
        case favoriteCuisines = "favorite_cuisines"
        case weight
        case goalWeight = "goal_weight"
        case activityLevel = "activity_level"
    }
}

// Make ActivityLevel codable
extension ActivityLevel: Codable {} 