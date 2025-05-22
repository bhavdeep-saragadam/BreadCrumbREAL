import SwiftUI

import Foundation


struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var isShowingSplash = true
    
    init(viewModel: AppViewModel = AppViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        if isShowingSplash {
            
            SplashView(isShowingSplash: $isShowingSplash)
        } else if !hasCompletedOnboarding {
           
            OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
        } else if !viewModel.isAuthenticated {
           
            UserSetupView(viewModel: viewModel)
        } else {
       
            MainTabView(viewModel: viewModel)
                .onAppear {
                  
                    viewModel.loadInitialData()
                }
        }
    }
}

struct SplashView: View {
    @Binding var isShowingSplash: Bool
    
    // Define colors to match other screens
    let bgColor = Color(red: 0.95, green: 0.92, blue: 0.89)
    let darkBrown = Color(red: 0.29, green: 0.16, blue: 0.05)
    let mediumBrown = Color(red: 0.42, green: 0.26, blue: 0.13)
    let lightBrown = Color(red: 0.62, green: 0.41, blue: 0.21)
    let tan = Color(red: 0.76, green: 0.58, blue: 0.38)
    let cream = Color(red: 0.86, green: 0.72, blue: 0.53)
    
    var body: some View {
        ZStack {
            // Background
            bgColor
                .ignoresSafeArea()
            
            // Layered bubble shapes with different colors
            IrregularBubbleShape(seed: 111)
                .fill(darkBrown)
                .frame(width: UIScreen.main.bounds.width * 1.8, height: UIScreen.main.bounds.height * 0.4)
                .position(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.1)
                .ignoresSafeArea()
            
            IrregularBubbleShape(seed: 222)
                .fill(mediumBrown)
                .frame(width: UIScreen.main.bounds.width * 1.7, height: UIScreen.main.bounds.height * 0.35)
                .position(x: UIScreen.main.bounds.width * 0.7, y: UIScreen.main.bounds.height * 0.25)
                .ignoresSafeArea()
            
            IrregularBubbleShape(seed: 333)
                .fill(lightBrown)
                .frame(width: UIScreen.main.bounds.width * 1.6, height: UIScreen.main.bounds.height * 0.3)
                .position(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * 0.35)
                .ignoresSafeArea()
            
            IrregularBubbleShape(seed: 444)
                .fill(tan)
                .frame(width: UIScreen.main.bounds.width * 1.5, height: UIScreen.main.bounds.height * 0.25)
                .position(x: UIScreen.main.bounds.width * 0.8, y: UIScreen.main.bounds.height * 0.45)
                .ignoresSafeArea()
            
            IrregularBubbleShape(seed: 555)
                .fill(cream)
                .frame(width: UIScreen.main.bounds.width * 1.4, height: UIScreen.main.bounds.height * 0.2)
                .position(x: UIScreen.main.bounds.width * 0.2, y: UIScreen.main.bounds.height * 0.55)
                .ignoresSafeArea()
                
            // Bottom bubble
            IrregularBubbleShape(seed: 666)
                .fill(darkBrown)
                .frame(width: UIScreen.main.bounds.width * 1.8, height: UIScreen.main.bounds.height * 0.5)
                .position(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 1.1)
                .ignoresSafeArea()
            
            // App content
            VStack {
                Spacer()
                
                // App title in center
                Text("BreadCrumb")
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Scroll up text at bottom
                Text("scroll up")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color.black.opacity(0.5))
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isShowingSplash = false
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.height < 0 {
                
                        withAnimation {
                            isShowingSplash = false
                        }
                    }
                }
        )
    }
}

struct UserSetupView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var name: String = ""
    @State private var weight: String = ""
    @State private var goalWeight: String = ""
    @State private var calorieGoal: String = "2000"
    @State private var selectedActivityLevel = ActivityLevel.moderate
    @State private var preferredCuisines: [String] = []
    @State private var currentPage: Int = 0
    @Environment(\.colorScheme) var colorScheme
    
    // Background colors
    let bgColor = Color(red: 0.95, green: 0.92, blue: 0.89)
    let darkBrown = Color(red: 0.29, green: 0.16, blue: 0.05)
    let mediumBrown = Color(red: 0.42, green: 0.26, blue: 0.13)
    
    var body: some View {
        ZStack {
            bgColor
                .ignoresSafeArea()
            
        
            IrregularBubbleShape(seed: 123)
                .fill(darkBrown)
                .frame(width: UIScreen.main.bounds.width * 1.5, height: UIScreen.main.bounds.height * 0.4)
                .position(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * 0.05)
                .rotationEffect(.degrees(180))
                .ignoresSafeArea()
            
      
            IrregularBubbleShape(seed: 456)
                .fill(darkBrown)
                .frame(width: UIScreen.main.bounds.width * 1.5, height: UIScreen.main.bounds.height * 0.4)
                .position(x: UIScreen.main.bounds.width * 0.7, y: UIScreen.main.bounds.height * 0.95)
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 1: Basic Info
                VStack(spacing: 24) {
                    Text("Tell us about yourself")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                    Text("This information helps us create a personalized experience for you")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                        .frame(height: 20)
                    
   
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's your name?")
                            .font(.headline)
                        
                        TextField("Your name", text: $name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 32)
                    
       
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current weight (kg)")
                            .font(.headline)
                        
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 32)
                    
      
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Goal weight (kg)")
                            .font(.headline)
                        
                        TextField("Goal weight", text: $goalWeight)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
           
                    Button(action: {
                        withAnimation {
                            currentPage = 1
                        }
                    }) {
                        Text("Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(mediumBrown)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                    .disabled(name.isEmpty || weight.isEmpty || goalWeight.isEmpty)
                    .opacity(name.isEmpty || weight.isEmpty || goalWeight.isEmpty ? 0.6 : 1)
                }
                .tag(0)
                
              
                VStack(spacing: 24) {
                    Text("Your Fitness Goals")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                    Text("Help us calculate your optimal nutrition plan")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                        .frame(height: 20)
                    
                 
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Activity Level")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                ActivityLevelRow(
                                    level: level,
                                    isSelected: selectedActivityLevel == level,
                                    onTap: {
                                        selectedActivityLevel = level
                                        updateCalorieGoal()
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
              
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily calorie goal")
                            .font(.headline)
                        
                        TextField("Calories", text: $calorieGoal)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation {
                                currentPage = 0
                            }
                        }) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(mediumBrown)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(mediumBrown, lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                        
                        Button(action: {
                            saveUserProfile()
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(mediumBrown)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .disabled(calorieGoal.isEmpty)
                        .opacity(calorieGoal.isEmpty ? 0.6 : 1)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
                .tag(1)
                
             
                VStack(spacing: 24) {
                    Text("What cuisines do you enjoy?")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                    Text("Select all that apply")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.cuisines, id: \.self) { cuisine in
                            CuisineSelectionCard(
                                cuisine: cuisine,
                                isSelected: preferredCuisines.contains(cuisine),
                                onToggle: {
                                    toggleCuisine(cuisine)
                                }
                            )
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button {
                       
                        let profile = UserProfile(
                            name: name,
                            dailyCalorieGoal: Int(calorieGoal) ?? 2000,
                            favoriteCuisines: preferredCuisines,
                            weight: Double(weight) ?? 0,
                            goalWeight: Double(goalWeight) ?? 0,
                            activityLevel: selectedActivityLevel
                        )
                        
                        viewModel.setUserProfile(profile)
                    } label: {
                        Text("Complete Setup")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(mediumBrown)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
         
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay(
                        ProgressView()
                            .scaleEffect(2)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                VStack {
                    Spacer()
                    
                    Text(errorMessage)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
        }
    }
    
    private func updateCalorieGoal() {
        // Simple calorie calculation based on user inputs
        if let weightValue = Double(weight) {
            // Base calculation on weight and activity level
            var baseCalories = weightValue * 24 // Simple basal metabolic rate
            
            // Adjust based on activity level
            switch selectedActivityLevel {
            case .sedentary:
                baseCalories *= 1.2
            case .moderate:
                baseCalories *= 1.5
            case .active:
                baseCalories *= 1.8
            }
            
           
            if let goalWeightValue = Double(goalWeight) {
                if goalWeightValue < weightValue {
                    baseCalories -= 500
                } else if goalWeightValue > weightValue {
                    baseCalories += 500
                }
            }
            
     
            let roundedCalories = Int(round(baseCalories / 50) * 50)
            calorieGoal = "\(roundedCalories)"
        }
    }
    
    private func saveUserProfile() {

        var userProfile = UserProfile(
            name: name,
            dailyCalorieGoal: Int(calorieGoal) ?? 2000,
            favoriteCuisines: preferredCuisines
        )
        

        userProfile.weight = Double(weight) ?? 0
        userProfile.goalWeight = Double(goalWeight) ?? 0
        userProfile.activityLevel = selectedActivityLevel
        
       
        viewModel.setUpLocalUser(with: userProfile)
    }
    
    private func toggleCuisine(_ cuisine: String) {
        if preferredCuisines.contains(cuisine) {
            preferredCuisines.removeAll { $0 == cuisine }
        } else {
            preferredCuisines.append(cuisine)
        }
    }
}

struct ActivityLevelRow: View {
    let level: ActivityLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(level.title)
                    .font(.headline)
                
                Text(level.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color(red: 0.42, green: 0.26, blue: 0.13), lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isSelected {
                    Circle()
                        .fill(Color(red: 0.42, green: 0.26, blue: 0.13))
                        .frame(width: 16, height: 16)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: isSelected ? Color(red: 0.42, green: 0.26, blue: 0.13).opacity(0.3) : Color.black.opacity(0.05), 
                radius: isSelected ? 4 : 2, 
                x: 0, 
                y: isSelected ? 2 : 1)
        .onTapGesture {
            onTap()
        }
    }
}

// Activity level enum
enum ActivityLevel: String, CaseIterable {
    case sedentary
    case moderate
    case active
    
    var title: String {
        switch self {
        case .sedentary: return "Sedentary"
        case .moderate: return "Moderately Active"
        case .active: return "Very Active"
        }
    }
    
    var description: String {
        switch self {
        case .sedentary: return "Little to no exercise"
        case .moderate: return "Exercise 3-5 days a week"
        case .active: return "Exercise 6-7 days a week"
        }
    }
}

struct CuisineSelectionCard: View {
    var cuisine: String
    var isSelected: Bool
    var onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                        Color(red: 0.42, green: 0.26, blue: 0.13) : 
                        Color(red: 0.86, green: 0.72, blue: 0.53).opacity(0.5))
                    .frame(height: 80)
                    .overlay(
                        Text(cuisine)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .black)
                    )
            }
        }
    }
}

#Preview {
    ContentView()
}
