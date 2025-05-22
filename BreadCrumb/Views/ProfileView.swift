import SwiftUI
import Foundation

struct ProfileView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var calorieGoal: String
    @State private var showingSuccessAlert = false
    @State private var showingSignOutAlert = false
    
    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
        _calorieGoal = State(initialValue: String(viewModel.userProfile.dailyCalorieGoal))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("PROFILE")) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color(red: 0.42, green: 0.26, blue: 0.13))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.userProfile.name)
                                .font(.headline)
                            
                            if viewModel.userProfile.weight > 0 {
                                Text("Current: \(String(format: "%.1f", viewModel.userProfile.weight)) kg")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if viewModel.userProfile.goalWeight > 0 {
                                Text("Goal: \(String(format: "%.1f", viewModel.userProfile.goalWeight)) kg")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("NUTRITION GOALS")) {
                    HStack {
                        Text("Daily Calorie Goal")
                        Spacer()
                        TextField("Calories", text: $calorieGoal)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Activity Level")
                        Spacer()
                        Text(viewModel.userProfile.activityLevel.title)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Save Changes") {
                        if let newGoal = Int(calorieGoal) {
                            viewModel.updateCalorieGoal(to: newGoal)
                            showingSuccessAlert = true
                        }
                    }
                    .foregroundColor(Color(red: 0.42, green: 0.26, blue: 0.13))
                }
                
                Section(header: Text("FAVORITE CUISINES")) {
                    ForEach(viewModel.cuisines, id: \.self) { cuisine in
                        HStack {
                            Text(cuisine)
                            Spacer()
                            if viewModel.userProfile.favoriteCuisines.contains(cuisine) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            } else {
                                Image(systemName: "star")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.toggleFavoriteCuisine(cuisine)
                        }
                    }
                }
                
                Section {
                    Button("Sign Out") {
                        showSignOutConfirmation()
                    }
                    .foregroundColor(.red)
                }
                
                // Add a section to show storage mode
                Section(header: Text("STORAGE")) {
                    HStack {
                        Text("Storage Mode")
                        Spacer()
                        Text(UserDefaults.standard.bool(forKey: "using_local_storage") ? "Local Only" : "Cloud")
                            .foregroundColor(.secondary)
                    }
                    
                    if UserDefaults.standard.bool(forKey: "using_local_storage") {
                        Text("Your data is stored only on this device and will be lost if the app is deleted.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if viewModel.isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Changes Saved"),
                    message: Text("Your profile settings have been updated."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showingSignOutAlert) {
                signOutAlert
            }
            .disabled(viewModel.isLoading)
        }
    }
    
    private func showSignOutConfirmation() {
        showingSignOutAlert = true
    }
    
    // Custom alert with SignOut confirmation
    var signOutAlert: Alert {
        Alert(
            title: Text("Sign Out"),
            message: Text("You will need to sign in again to use BreadCrumb. Authentication is required to access the app."),
            primaryButton: .destructive(Text("Sign Out")) {
                viewModel.signOut()
            },
            secondaryButton: .cancel()
        )
    }
} 