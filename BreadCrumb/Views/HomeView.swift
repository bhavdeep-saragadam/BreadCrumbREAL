import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showingAddMealSheet = false
    @State private var selectedMealType: MealType = .breakfast
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
           
                    welcomeSection
                    
                   
                    calorieProgressSection
                    
            
                    todaysMealsSection
                    
               
                    if viewModel.userProfile.weight > 0 && viewModel.userProfile.goalWeight > 0 {
                        weightProgressSection
                    }
                    
            
                    personalizedRecommendationsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddMealSheet = true
                    }) {
                        Label("Add Meal", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMealSheet) {
                mealSelectionSheet
            }
        }
    }
    

    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(greeting), \(viewModel.userProfile.name)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(motivationalMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }
    
  
    private var calorieProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Calories")
                .font(.headline)
            
            HStack(alignment: .bottom, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.caloriesConsumedToday())")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("of \(viewModel.userProfile.dailyCalorieGoal) kcal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                
                ZStack {
                    Circle()
                        .stroke(
                            Color(red: 0.86, green: 0.72, blue: 0.53).opacity(0.3),
                            lineWidth: 10
                        )
                    
                    Circle()
                        .trim(from: 0, to: min(CGFloat(viewModel.caloriesConsumedToday()) / CGFloat(viewModel.userProfile.dailyCalorieGoal), 1.0))
                        .stroke(
                            Color(red: 0.42, green: 0.26, blue: 0.13),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(min(Double(viewModel.caloriesConsumedToday()) / Double(viewModel.userProfile.dailyCalorieGoal) * 100, 100)))%")
                        .font(.headline)
                }
                .frame(width: 80, height: 80)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
   
    private var todaysMealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Meals")
                .font(.headline)
            
            if viewModel.entriesForToday().isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No meals logged today")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("Add Your First Meal") {
                            showingAddMealSheet = true
                        }
                        .font(.headline)
                        .foregroundColor(Color(red: 0.42, green: 0.26, blue: 0.13))
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        let entries = viewModel.entriesForToday().filter { $0.mealType == mealType }
                        
                        if !entries.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(mealType.title)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                ForEach(entries) { entry in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(entry.food.name)
                                                .font(.headline)
                                            
                                            Text("\(entry.totalCalories) kcal • \(entry.food.cuisine)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if entry.quantity != 1.0 {
                                            Text("×\(String(format: "%.1f", entry.quantity))")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Button(action: {
                                            if let index = viewModel.entriesForToday().firstIndex(where: { $0.id == entry.id }) {
                                                viewModel.removeMealEntry(at: IndexSet(integer: index))
                                            }
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .padding(8)
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            if let index = viewModel.entriesForToday().firstIndex(where: { $0.id == entry.id }) {
                                                viewModel.removeMealEntry(at: IndexSet(integer: index))
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Weight progress section
    private var weightProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight Progress")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(String(format: "%.1f", viewModel.userProfile.weight)) kg")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Current Weight")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Goal weight
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(String(format: "%.1f", viewModel.userProfile.goalWeight)) kg")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Goal Weight")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Weight progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(red: 0.86, green: 0.72, blue: 0.53).opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color(red: 0.42, green: 0.26, blue: 0.13))
                        .frame(width: calculateProgressWidth(geometry.size.width), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            .padding(.top, 8)
            
            // Remaining text
            Text(weightRemainingText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Recommendations section
    private var personalizedRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personalized Recommendations")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recommendedFoods) { food in
                        Button(action: {
                            addFoodToMeal(food)
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(food.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                HStack {
                                    Text("\(food.calories) kcal")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(food.cuisine)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color(red: 0.62, green: 0.41, blue: 0.21))
                                        .cornerRadius(4)
                                }
                                
                                Text(foodRecommendationReason(for: food))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .frame(width: 200)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Meal selection sheet
    private var mealSelectionSheet: some View {
        NavigationView {
            List {
                Section(header: Text("Select meal type")) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        Button(action: {
                            selectedMealType = mealType
                            showingAddMealSheet = false
                            // Navigate to food selection (simplified for now)
                        }) {
                            HStack {
                                Text(mealType.title)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Add Meal")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    showingAddMealSheet = false
                }
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 12 {
            return "Good morning"
        } else if hour < 17 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }
    
    private var motivationalMessage: String {
        let messages = [
            "Track your meals to reach your goals!",
            "Every healthy choice counts!",
            "Stay consistent with your nutrition!",
            "Eating well is an act of self-care!",
            "Balance is key to sustainable habits!"
        ]
        
        // Use day of year as a seed for pseudo-randomness
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return messages[dayOfYear % messages.count]
    }
    
    private func calculateProgressWidth(_ totalWidth: CGFloat) -> CGFloat {
        let currentWeight = viewModel.userProfile.weight
        let goalWeight = viewModel.userProfile.goalWeight
        
        // If current weight equals goal weight, show full progress
        if currentWeight == goalWeight {
            return totalWidth
        }
        
        // If losing weight (goal < current)
        if goalWeight < currentWeight {
            // Start with no progress if difference is 10+ kg
            let maxDifference: Double = 10.0
            let difference = min(currentWeight - goalWeight, maxDifference)
            let remainingDifference = maxDifference - difference
            
            return (remainingDifference / maxDifference) * totalWidth
        } 
        // If gaining weight (goal > current)
        else {
            // Start with no progress if difference is 10+ kg
            let maxDifference: Double = 10.0
            let difference = min(goalWeight - currentWeight, maxDifference)
            let progress = maxDifference - difference
            
            return (progress / maxDifference) * totalWidth
        }
    }
    
    private var weightRemainingText: String {
        let currentWeight = viewModel.userProfile.weight
        let goalWeight = viewModel.userProfile.goalWeight
        
        if abs(currentWeight - goalWeight) < 0.1 {
            return "You've reached your goal weight!"
        } else if currentWeight > goalWeight {
            let remaining = currentWeight - goalWeight
            return "\(String(format: "%.1f", remaining)) kg to lose to reach your goal"
        } else {
            let remaining = goalWeight - currentWeight
            return "\(String(format: "%.1f", remaining)) kg to gain to reach your goal"
        }
    }
    
    private var recommendedFoods: [Food] {
        // Get all foods, or a subset if there are lots
        let allFoods = viewModel.foods
        
        // Filter to preferred cuisines if set
        var filteredFoods = allFoods
        
        if !viewModel.userProfile.favoriteCuisines.isEmpty {
            filteredFoods = allFoods.filter { viewModel.userProfile.favoriteCuisines.contains($0.cuisine) }
            // Fallback to all foods if no matches
            if filteredFoods.isEmpty {
                filteredFoods = allFoods
            }
        }
        
        // Prioritize foods based on user goals
        let sortedFoods = filteredFoods.sorted { (food1, food2) -> Bool in
            // If trying to lose weight, prioritize lower calorie foods
            if viewModel.userProfile.weight > viewModel.userProfile.goalWeight {
                return food1.calories < food2.calories
            } 
            // If trying to gain weight, prioritize higher protein foods
            else if viewModel.userProfile.weight < viewModel.userProfile.goalWeight {
                return food1.protein > food2.protein
            }
            // Otherwise, sort by highest rated or random
            else {
                return food1.id < food2.id // random-ish sort
            }
        }
        
        // Take top 5 or fewer
        return Array(sortedFoods.prefix(5))
    }
    
    private func foodRecommendationReason(for food: Food) -> String {
        // Recommend based on weight goals
        if viewModel.userProfile.weight > viewModel.userProfile.goalWeight {
            return "Low calorie option for weight loss"
        } else if viewModel.userProfile.weight < viewModel.userProfile.goalWeight {
            return "Good protein source for muscle building"
        } else {
            return "Balanced nutritional choice"
        }
    }
    
    private func addFoodToMeal(_ food: Food) {
        viewModel.addMealEntry(food: food, mealType: .snack)
    }
}

extension MealType {
    var title: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        }
    }
} 
