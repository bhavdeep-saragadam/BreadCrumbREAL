import Foundation

class MealService: ObservableObject {
    static let shared = MealService()
    
    @Published var mealEntries: [MealEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        loadMealEntries()
    }
    
    func loadMealEntries() {
        isLoading = true
        errorMessage = nil
        
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "meal_entries") {
            do {
                let entries = try JSONDecoder().decode([MealEntry].self, from: data)
                DispatchQueue.main.async {
                    self.mealEntries = entries
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode meal entries: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        } else {
            // No saved entries found
            DispatchQueue.main.async {
                self.mealEntries = []
                self.isLoading = false
            }
        }
    }
    
    func addMealEntry(food: Food, mealType: MealType, quantity: Double = 1.0) {
        let entry = MealEntry(food: food, date: Date(), mealType: mealType, quantity: quantity)
        
        // Optimistically update UI
        DispatchQueue.main.async {
            self.mealEntries.append(entry)
        }
        
        // Save to UserDefaults
        saveToUserDefaults()
    }
    
    func removeMealEntry(at indexSet: IndexSet) {
        // Optimistically update UI
        DispatchQueue.main.async {
            self.mealEntries.remove(atOffsets: indexSet)
        }
        
        // Save to UserDefaults
        saveToUserDefaults()
    }
    
    private func saveToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(mealEntries)
            UserDefaults.standard.set(data, forKey: "meal_entries")
        } catch {
            errorMessage = "Failed to save meals: \(error.localizedDescription)"
        }
    }
    
    func caloriesConsumedToday() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return mealEntries
            .filter { calendar.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.totalCalories }
    }
    
    func entriesForToday() -> [MealEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return mealEntries
            .filter { calendar.isDate($0.date, inSameDayAs: today) }
            .sorted(by: { $0.date > $1.date })
    }
} 