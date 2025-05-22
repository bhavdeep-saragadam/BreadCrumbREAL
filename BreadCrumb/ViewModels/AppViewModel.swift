import Foundation
import UIKit

class AppViewModel: ObservableObject {
    // Services
    private let supabaseManager = SupabaseManager.shared
    private let mealService = MealService.shared
    private let foodService = FoodService.shared
    
    // Published properties from SupabaseManager
    @Published var isLoading: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    
    // User profile
    @Published var userProfile: UserProfile {
        didSet {
            if isAuthenticated {
                supabaseManager.saveUserProfile(userId: "demo-user", profile: userProfile)
            }
        }
    }
    
    // Food-related properties
    @Published var foods: [Food] = []
    @Published var mealEntries: [MealEntry] = []
    @Published var cuisines: [String] = ["Indian", "Chinese", "Italian", "Mexican", "American", "Middle Eastern", "Thai", "Japanese", "Mediterranean", "African"]
    
    init() {
        // Initialize with default values
        self.userProfile = UserProfile(name: "User")
        
        // Setup bindings to services
        setupBindings()
    }
    
    private func setupBindings() {
        // Setup bindings to services
        supabaseManager.$isLoading.assign(to: &$isLoading)
        supabaseManager.$isAuthenticated.assign(to: &$isAuthenticated)
        supabaseManager.$errorMessage.assign(to: &$errorMessage)
        
        // Use the new FoodService
        foods = FoodService.shared.foods
        mealService.$mealEntries.assign(to: &$mealEntries)
        
        // Initialize user profile when supabaseManager.userProfile changes
        supabaseManager.$userProfile
            .compactMap { $0 }
            .assign(to: &$userProfile)
    }
    
    // MARK: - Authentication
    
    func signInWithGoogle(viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        supabaseManager.signInWithGoogle(viewController: viewController, completion: completion)
    }
    
    func signOut() {
        // If using local storage, clear that flag
        if UserDefaults.standard.bool(forKey: "using_local_storage") {
            UserDefaults.standard.removeObject(forKey: "using_local_storage")
            UserDefaults.standard.removeObject(forKey: "local_user_profile")
            
            // Optional: clear meal data or keep it for the next login
            // UserDefaults.standard.removeObject(forKey: "meal_entries")
            // UserDefaults.standard.removeObject(forKey: "favorite_foods")
        }
        
        // Standard sign out
        supabaseManager.signOut()
    }
    
    // Enable local-only storage mode (no authentication required)
    func useLocalStorageOnly() {
        isLoading = true
        
        // Create a local profile
        let localProfile = UserProfile(
            name: "Local User",
            dailyCalorieGoal: 2000,
            favoriteCuisines: []
        )
        
        // Save the local profile
        if let encoded = try? JSONEncoder().encode(localProfile) {
            UserDefaults.standard.set(encoded, forKey: "local_user_profile")
        }
        
        // Set authentication bypass flag
        UserDefaults.standard.set(true, forKey: "using_local_storage")
        
        // Update view model state
        self.userProfile = localProfile
        self.isAuthenticated = true
        
        // Load initial app data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.loadInitialData()
        }
    }
    
    // MARK: - User Profile
    
    // Setup user with saved local profile
    func setUpLocalUser(with profile: UserProfile) {
        isLoading = true
        
        // Update view model state
        self.userProfile = profile
        self.isAuthenticated = true
        
        // Set authentication bypass flag
        UserDefaults.standard.set(true, forKey: "using_local_storage")
        
        // Load initial app data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.loadInitialData()
        }
    }
    
    // Set user profile with personalized information
    func setUserProfile(_ profile: UserProfile) {
        isLoading = true
        
        // Save the profile
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "local_user_profile")
        }
        
        // Set authentication bypass flag
        UserDefaults.standard.set(true, forKey: "using_local_storage")
        
        // Update view model state
        self.userProfile = profile
        self.isAuthenticated = true
        
        // Load initial app data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.loadInitialData()
        }
    }
    
    // Helper to check auth status
    private func verifyAuthenticated() -> Bool {
        // Allow access if using local storage mode
        if UserDefaults.standard.bool(forKey: "using_local_storage") {
            return true
        }
        
        if !isAuthenticated {
            errorMessage = "You must be signed in to access this feature"
            return false
        }
        return true
    }
    
    // MARK: - Meal Management
    
    func addMealEntry(food: Food, mealType: MealType, quantity: Double = 1.0) {
        guard verifyAuthenticated() else { return }
        mealService.addMealEntry(food: food, mealType: mealType, quantity: quantity)
    }
    
    func removeMealEntry(at indexSet: IndexSet) {
        guard verifyAuthenticated() else { return }
        mealService.removeMealEntry(at: indexSet)
    }
    
    // MARK: - Food Management
    
    func addFood(name: String, cuisine: String, calories: Int, protein: Double, carbs: Double, fat: Double, description: String) -> Food? {
        return foodService.addFood(name: name, cuisine: cuisine, calories: calories, protein: protein, carbs: carbs, fat: fat, description: description)
    }
    
    func toggleFavoriteFood(food: Food) {
        foodService.toggleFavorite(for: food)
    }
    
    func foodsByCuisine(_ cuisine: String) -> [Food] {
        return foodService.getFoodsByCuisine(cuisine)
    }
    
    // MARK: - Data Analysis
    
    func caloriesConsumedToday() -> Int {
        guard verifyAuthenticated() else { return 0 }
        return mealService.caloriesConsumedToday()
    }
    
    func entriesForToday() -> [MealEntry] {
        guard verifyAuthenticated() else { return [] }
        return mealService.entriesForToday()
    }
    
    // MARK: - Profile Management
    
    func updateCalorieGoal(to newGoal: Int) {
        guard verifyAuthenticated() else { return }
        userProfile.dailyCalorieGoal = newGoal
    }
    
    func toggleFavoriteCuisine(_ cuisine: String) {
        guard verifyAuthenticated() else { return }
        if let index = userProfile.favoriteCuisines.firstIndex(of: cuisine) {
            userProfile.favoriteCuisines.remove(at: index)
        } else {
            userProfile.favoriteCuisines.append(cuisine)
        }
    }
    
    // MARK: - App Lifecycle
    
    func loadInitialData() {
        guard verifyAuthenticated() else { return }
        // The FoodService now loads its own foods via the JSON file
        mealService.loadMealEntries()
    }
} 