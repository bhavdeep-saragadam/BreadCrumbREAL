import Foundation

struct MealEntry: Identifiable, Codable {
    var id = UUID()
    var food: Food
    var date: Date
    var mealType: MealType
    var quantity: Double = 1.0
    
    var totalCalories: Int {
        return Int(Double(food.calories) * quantity)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case food
        case date
        case mealType = "meal_type"
        case quantity
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
} 