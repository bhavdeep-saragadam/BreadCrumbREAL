import SwiftUI
import Foundation



struct AddMealView: View {
    @ObservedObject var viewModel: AppViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedCuisine: String = "Indian"
    @State private var selectedMealType: MealType = .lunch
    @State private var searchText = ""
    @State private var quantity: Double = 1.0
    
    var body: some View {
        NavigationView {
            VStack {
               
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.cuisines, id: \.self) { cuisine in
                            CuisineButton(
                                cuisine: cuisine,
                                isSelected: selectedCuisine == cuisine,
                                action: { selectedCuisine = cuisine }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search foods", text: $searchText)
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
                
                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(MealType.allCases, id: \.self) { mealType in
                        Text(mealType.rawValue).tag(mealType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if viewModel.isLoading && viewModel.foods.isEmpty {
                
                    Spacer()
                    ProgressView("Loading foods...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else {
       
                    List {
                        ForEach(filteredFoods) { food in
                            FoodRow(food: food, selectedMealType: $selectedMealType, quantity: $quantity, onAdd: {
                                viewModel.addMealEntry(food: food, mealType: selectedMealType, quantity: quantity)
                                isPresented = false
                            })
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    if filteredFoods.isEmpty {
                        VStack {
                            Text("No foods found")
                                .foregroundColor(.gray)
                            
                            if !searchText.isEmpty {
                                Text("Try a different search term or cuisine")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Add Meal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
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
                                .padding(.bottom, 20)
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
    
    private var filteredFoods: [Food] {
        let cuisineFoods = viewModel.foodsByCuisine(selectedCuisine)
        
        if searchText.isEmpty {
            return cuisineFoods
        } else {
            return cuisineFoods.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}

struct CuisineButton: View {
    var cuisine: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(cuisine)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : .primary)
                .background(isSelected ? Color(red: 0.42, green: 0.26, blue: 0.13) : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

struct FoodRow: View {
    var food: Food
    @Binding var selectedMealType: MealType
    @Binding var quantity: Double
    var onAdd: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.headline)
                    
                    Text("\(food.calories) cal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    isExpanded.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
                
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(red: 0.42, green: 0.26, blue: 0.13))
                        .imageScale(.large)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    HStack {
                        Text("Protein: \(Int(food.protein))g")
                        Spacer()
                        Text("Carbs: \(Int(food.carbs))g")
                        Spacer()
                        Text("Fat: \(Int(food.fat))g")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Quantity:")
                        Stepper(
                            value: $quantity,
                            in: 0.5...5.0,
                            step: 0.5
                        ) {
                            Text("\(quantity, specifier: "%.1f")")
                                .font(.body)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            isExpanded.toggle()
        }
    }
} 
