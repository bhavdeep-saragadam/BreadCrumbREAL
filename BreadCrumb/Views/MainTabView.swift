import SwiftUI
import Foundation

struct MainTabView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ExploreView(viewModel: viewModel)
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
            
            FoodCatalogView(viewModel: viewModel)
                .tabItem {
                    Label("Foods", systemImage: "fork.knife")
                }
            
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(Color(red: 0.42, green: 0.26, blue: 0.13))
        .overlay(
            Group {
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .padding(.bottom, 80)
                            .onAppear {
                               
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    if viewModel.errorMessage == errorMessage {
                                        viewModel.errorMessage = nil
                                    }
                                }
                            }
                    }
                }
            }
        )
    }
}

struct ExploreView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for foods", text: $searchText)
                        .foregroundColor(.primary)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                
                // Cuisine grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.cuisines, id: \.self) { cuisine in
                            CuisineCard(cuisine: cuisine) {
                                // Filter by cuisine
                                searchText = cuisine
                            }
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    // Popular foods section
                    VStack(alignment: .leading) {
                        Text("Popular Foods")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(searchResults) { food in
                            PopularFoodRow(food: food, onTap: {
                                // Add a meal with this food
                                viewModel.addMealEntry(food: food, mealType: .snack)
                            })
                        }
                    }
                    .padding(.top)
                }
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .navigationTitle("Explore")
        }
    }
    
    private var searchResults: [Food] {
        let foods = viewModel.foods
        
        if searchText.isEmpty {
            return foods
        } else {
            return foods.filter { 
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.cuisine.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

struct CuisineCard: View {
    var cuisine: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.42, green: 0.26, blue: 0.13).opacity(0.8))
                    .frame(height: 100)
                    .overlay(
                        Text(cuisine)
                            .font(.headline)
                            .foregroundColor(.white)
                    )
            }
        }
    }
}

struct PopularFoodRow: View {
    var food: Food
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(food.calories) cal • \(food.cuisine)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .foregroundColor(Color(red: 0.42, green: 0.26, blue: 0.13))
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
} 
