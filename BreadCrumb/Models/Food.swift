import Foundation

struct Food: Identifiable, Codable {
    let id: String
    let name: String
    let cuisine: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let image: String?
    let description: String?
    
    var isFavorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, name, cuisine, calories, protein, carbs, fat, image, description
    }
}

// Extension for sample data and convenience methods
extension Food {
    // Get an appropriate system image based on the cuisine
    var systemImageName: String {
        switch cuisine.lowercased() {
        case "indian":
            return "flame.fill"
        case "mexican":
            return "tortilla"
        case "chinese":
            return "chart.bar.doc.horizontal"
        case "middle eastern":
            return "leaf.fill"
        case "african":
            return "sun.max.fill"
        case "thai":
            return "flame.fill"
        case "japanese":
            return "chart.bar.doc.horizontal"
        case "italian":
            return "chart.bar.doc.horizontal"
        case "greek":
            return "leaf.fill"
        case "korean":
            return "flame.fill"
        default:
            return "fork.knife"
        }
    }
    
    // Some sample food items for preview and testing
    static let samples = [
        Food(id: "1", name: "Butter Chicken", cuisine: "Indian", calories: 490, protein: 27, carbs: 10, fat: 38, image: nil, description: "Tender chicken in a rich, creamy tomato sauce."),
        Food(id: "2", name: "Tacos", cuisine: "Mexican", calories: 320, protein: 15, carbs: 30, fat: 16, image: nil, description: "Corn tortillas with various fillings."),
        Food(id: "3", name: "Kung Pao Chicken", cuisine: "Chinese", calories: 410, protein: 30, carbs: 24, fat: 22, image: nil, description: "Spicy stir-fried chicken with peanuts.")
    ]
} 