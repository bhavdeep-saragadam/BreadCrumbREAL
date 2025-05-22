import SwiftUI
import Foundation

struct FoodCatalogView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var searchText = ""
    @State private var selectedCuisine: String? = nil
    @State private var showingAddFoodSheet = false
    
    var filteredFoods: [Food] {
        let foods = viewModel.foods
        

        let searchFiltered = searchText.isEmpty 
            ? foods 
            : foods.filter { $0.name.localizedCaseInsensitiveContains(searchText) || 
                           $0.cuisine.localizedCaseInsensitiveContains(searchText) }
      
        if let selectedCuisine = selectedCuisine {
            return searchFiltered.filter { $0.cuisine == selectedCuisine }
        } else {
            return searchFiltered
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
          
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: {
                            selectedCuisine = nil
                        }) {
                            Text("All")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCuisine == nil ? 
                                    Color(red: 0.42, green: 0.26, blue: 0.13) : 
                                    Color.gray.opacity(0.2))
                                .foregroundColor(selectedCuisine == nil ? .white : .primary)
                                .cornerRadius(20)
                        }
                        
                        ForEach(viewModel.cuisines, id: \.self) { cuisine in
                            Button(action: {
                                selectedCuisine = cuisine
                            }) {
                                Text(cuisine)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCuisine == cuisine ? 
                                        Color(red: 0.42, green: 0.26, blue: 0.13) : 
                                        Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCuisine == cuisine ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Food list
                List {
                    ForEach(filteredFoods) { food in
                        FoodListItem(food: food, onSelect: { 
                            // You can add food selection functionality here
                        })
                    }
                }
                .listStyle(PlainListStyle())
                .searchable(text: $searchText, prompt: "Search for foods")
            }
            .navigationTitle("Food Catalog")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddFoodSheet = true
                    }) {
                        Label("Add Food", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddFoodSheet) {
                AddFoodView(viewModel: viewModel)
            }
        }
    }
}

struct FoodListItem: View {
    let food: Food
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
       
                ZStack {
                    Circle()
                        .fill(Color(red: 0.86, green: 0.72, blue: 0.53))
                        .frame(width: 50, height: 50)
                    
                    if let imageName = food.image, !imageName.isEmpty {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 46, height: 46)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: food.systemImageName)
                            .font(.system(size: 22))
                            .foregroundColor(Color(red: 0.42, green: 0.26, blue: 0.13))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Text("\(food.calories) kcal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(food.cuisine)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("P: \(Int(food.protein))g")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Text("C: \(Int(food.carbs))g")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("F: \(Int(food.fat))g")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AppViewModel
    
    @State private var foodName = ""
    @State private var calories = ""
    @State private var cuisine = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var description = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        _cuisine = State(initialValue: viewModel.cuisines.first ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Details")) {
                    TextField("Food Name", text: $foodName)
                    
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                    
                    Picker("Cuisine", selection: $cuisine) {
                        ForEach(viewModel.cuisines, id: \.self) { cuisine in
                            Text(cuisine).tag(cuisine)
                        }
                    }
                }
                
                Section(header: Text("Nutritional Information")) {
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.decimalPad)
                    
                    TextField("Carbs (g)", text: $carbs)
                        .keyboardType(.decimalPad)
                    
                    TextField("Fat (g)", text: $fat)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Additional Information")) {
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add New Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFood()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Food Entry", isPresented: $showingAlert) {
                Button("OK") {
                    if !alertMessage.contains("Error") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !foodName.isEmpty && 
        !calories.isEmpty && 
        !protein.isEmpty && 
        !carbs.isEmpty && 
        !fat.isEmpty
    }
    
    private func saveFood() {
        guard let caloriesValue = Int(calories),
              let proteinValue = Double(protein),
              let carbsValue = Double(carbs),
              let fatValue = Double(fat) else {
            alertMessage = "Error: Please enter valid numerical values"
            showingAlert = true
            return
        }
        
        if let newFood = viewModel.addFood(
            name: foodName,
            cuisine: cuisine,
            calories: caloriesValue,
            protein: proteinValue,
            carbs: carbsValue,
            fat: fatValue,
            description: description
        ) {
            alertMessage = "\(newFood.name) has been added to your food catalog!"
            showingAlert = true
            
            // Reset the form
            foodName = ""
            calories = ""
            protein = ""
            carbs = ""
            fat = ""
            description = ""
        } else {
            alertMessage = "Error: Could not add food"
            showingAlert = true
        }
    }
}

struct FoodCatalogView_Previews: PreviewProvider {
    static var previews: some View {
        FoodCatalogView(viewModel: AppViewModel())
    }
} 
