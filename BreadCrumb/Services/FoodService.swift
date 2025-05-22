import Foundation

// Structure to decode the JSON file
struct FoodData: Codable {
    let foods: [Food]
    let cuisines: [String]
    
    init(foods: [Food], cuisines: [String]) {
        self.foods = foods
        self.cuisines = cuisines
    }
}

class FoodService: ObservableObject {
    static let shared = FoodService()
    
    @Published var foods: [Food] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        loadFoods()
        loadFavorites()
    }
    
    private(set) var cuisines: [String] = []
    
    func loadFoods() {
        guard let url = Bundle.main.url(forResource: "foods", withExtension: "json") else {
            print("Error: foods.json file not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let foodData = try decoder.decode(FoodData.self, from: data)
            self.foods = foodData.foods
            
            // Use cuisines from JSON, but if empty, extract them from foods
            if foodData.cuisines.isEmpty {
                self.cuisines = Array(Set(foods.map { $0.cuisine })).sorted()
            } else {
                self.cuisines = foodData.cuisines
            }
            
            print("Loaded \(foods.count) foods successfully")
        } catch {
            print("Error loading foods: \(error.localizedDescription)")
            
            // Add some fallback foods in case JSON loading fails
            addFallbackFoods()
        }
    }
    
    private func addFallbackFoods() {
        // Add a few basic foods as fallback
        foods = [
            Food(id: "1", name: "Butter Chicken", cuisine: "Indian", calories: 490, protein: 27, carbs: 10, fat: 38, image: nil, description: nil),
            Food(id: "2", name: "Tacos", cuisine: "Mexican", calories: 320, protein: 15, carbs: 30, fat: 16, image: nil, description: nil),
            Food(id: "3", name: "Kung Pao Chicken", cuisine: "Chinese", calories: 410, protein: 30, carbs: 24, fat: 22, image: nil, description: nil)
        ]
        
        cuisines = ["Indian", "Mexican", "Chinese"]
    }
    
    func addFood(name: String, cuisine: String, calories: Int, protein: Double, carbs: Double, fat: Double, description: String) -> Food? {
        // Create a new ID (simple incrementation of the highest ID for now)
        let highestID = foods.compactMap { Int($0.id) }.max() ?? 0
        let newID = String(highestID + 1)
        
        // Create new food
        let newFood = Food(
            id: newID,
            name: name,
            cuisine: cuisine,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            image: nil,
            description: description.isEmpty ? nil : description
        )
        
        // Add to our array
        foods.append(newFood)
        
        // Save to JSON file
        saveToJSON()
        
        return newFood
    }
    
    func deleteFood(id: String) {
        foods.removeAll { $0.id == id }
        saveToJSON()
    }
    
    func updateFood(food: Food) {
        if let index = foods.firstIndex(where: { $0.id == food.id }) {
            foods[index] = food
            saveToJSON()
        }
    }
    
    func addCuisine(_ cuisine: String) -> Bool {
        if !cuisines.contains(cuisine) {
            cuisines.append(cuisine)
            saveToJSON()
            return true
        }
        return false
    }
    
    private func saveToJSON() {
        // Create FoodData struct for encoding
        let foodData = FoodData(foods: foods, cuisines: cuisines)
        
        // Try to get the URL of the JSON file in the app's documents directory
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not find documents directory")
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("foods.json")
        
        do {
            // Encode the data
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(foodData)
            
            // Write to file
            try jsonData.write(to: fileURL)
            print("Saved foods to \(fileURL.path)")
        } catch {
            print("Error saving foods to JSON: \(error)")
        }
    }
    
    func toggleFavorite(for food: Food) {
        if let index = foods.firstIndex(where: { $0.id == food.id }) {
            foods[index].isFavorite.toggle()
            saveFavorites()
        }
    }
    
    func loadFavorites() {
        if let favoriteIds = UserDefaults.standard.array(forKey: "favorite_foods") as? [String] {
            // Update isFavorite flag for all matching foods
            for i in 0..<foods.count {
                foods[i].isFavorite = favoriteIds.contains(foods[i].id)
            }
        }
    }
    
    func saveFavorites() {
        // Get IDs of favorite foods
        let favoriteIds = foods.filter { $0.isFavorite }.map { $0.id }
        
        // Save to UserDefaults
        UserDefaults.standard.set(favoriteIds, forKey: "favorite_foods")
    }
    
    func getFoodsByCuisine(_ cuisine: String) -> [Food] {
        return foods.filter { $0.cuisine == cuisine }
    }
    
    func getRecommendedFoods(forUserProfile profile: UserProfile) -> [Food] {
        // This can be expanded with more sophisticated recommendation logic
        var recommendedFoods: [Food] = []
        
        // If user has weight loss goal, recommend high protein, lower carb foods
        if profile.weight > 0 && profile.goalWeight > 0 && profile.weight > profile.goalWeight {
            // Sort by protein-to-calorie ratio for weight loss
            recommendedFoods = foods.sorted { 
                ($0.protein / Double($0.calories)) > ($1.protein / Double($1.calories))
            }
        } 
        // If user has weight gain goal, recommend higher calorie, balanced foods
        else if profile.weight > 0 && profile.goalWeight > 0 && profile.weight < profile.goalWeight {
            recommendedFoods = foods.sorted { $0.calories > $1.calories }
        }
        // Otherwise provide a balanced mix
        else {
            // Mix of cuisines and nutrition profiles
            recommendedFoods = foods.shuffled()
        }
        
        // Prioritize user's favorite cuisines if they have any
        if !profile.favoriteCuisines.isEmpty {
            let favoriteFoods = foods.filter { profile.favoriteCuisines.contains($0.cuisine) }
            let otherFoods = foods.filter { !profile.favoriteCuisines.contains($0.cuisine) }
            
            recommendedFoods = favoriteFoods + otherFoods
        }
        
        // Return top 5 recommendations or all if fewer than 5
        let limit = min(5, recommendedFoods.count)
        return Array(recommendedFoods.prefix(limit))
    }
} 