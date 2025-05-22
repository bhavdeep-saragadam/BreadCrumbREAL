//
//  BreadCrumbApp.swift
//  BreadCrumb
//
//  Created by Bhavdeep Saragadam on 4/28/25.
//

import SwiftUI

@main
struct BreadCrumbApp: App {
    // Monitor authentication state
    @StateObject private var authMonitor = AuthStateMonitor()
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            // Initialize ContentView with the shared ViewModel
            ContentView(viewModel: viewModel)
                .onAppear {
                    // Initialize auth check on app start
                    authMonitor.checkAuthState()
                    
                    // Check if we have a local user profile
                    if UserDefaults.standard.bool(forKey: "using_local_storage"),
                       let userData = UserDefaults.standard.data(forKey: "local_user_profile"),
                       let profile = try? JSONDecoder().decode(UserProfile.self, from: userData) {
                        // Use the saved profile
                        viewModel.setUpLocalUser(with: profile)
                    }
                }
        }
    }
}

// Class to monitor auth state across app lifecycle
class AuthStateMonitor: ObservableObject {
    private let supabaseManager = SupabaseManager.shared
    
    func checkAuthState() {
        // If using local storage mode, we don't need to verify authentication
        if UserDefaults.standard.bool(forKey: "using_local_storage") {
            return
        }
        
        // Check if user session is still valid
        if !supabaseManager.isAuthenticated {
            // Force sign out if session is invalid
            supabaseManager.signOut()
            
            // Clear any cached data that should be protected
            UserDefaults.standard.removeObject(forKey: "user_data")
        }
    }
}
