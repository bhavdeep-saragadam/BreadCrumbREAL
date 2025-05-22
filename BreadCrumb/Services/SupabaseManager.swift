import Foundation
import UIKit

// Simulated authentication manager instead of Supabase
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    @Published var isLoading = false
    @Published var isAuthenticated = false
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    private var authToken: String?
    private let tokenKey = "auth_token"
    private let sessionExpiryKey = "session_expiry"
    
    private init() {
        // Check if we have a stored user session and verify it's still valid
        validateStoredSession()
    }
    
    private func validateStoredSession() {
        guard let token = UserDefaults.standard.string(forKey: tokenKey),
              let expiryDate = UserDefaults.standard.object(forKey: sessionExpiryKey) as? Date else {
            // No stored session or expiry date
            invalidateSession()
            return
        }
        
        // Check if session has expired
        if Date() > expiryDate {
            // Session expired
            invalidateSession()
            return
        }
        
        // Valid session, load user profile
        if let userData = UserDefaults.standard.data(forKey: "user_profile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: userData) {
            self.userProfile = profile
            self.authToken = token
            self.isAuthenticated = true
        } else {
            // Profile data missing or corrupted
            invalidateSession()
        }
    }
    
    private func invalidateSession() {
        self.isAuthenticated = false
        self.userProfile = nil
        self.authToken = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: sessionExpiryKey)
        UserDefaults.standard.removeObject(forKey: "user_profile")
    }
    
    func signInWithGoogle(viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // IMPORTANT: This should launch the real Google OAuth authentication flow
        // For this demo, we'll show an alert that instructs the user that this is a required step
        let alert = UIAlertController(
            title: "Google Authentication Required",
            message: "You must sign in with Google to use BreadCrumb. This is a required security step that cannot be skipped.",
            preferredStyle: .alert
        )
        
        // Add a "Sign in with Google" button
        alert.addAction(UIAlertAction(title: "Sign in with Google", style: .default) { _ in
            // This would normally launch Google OAuth
            // Here we simulate a successful authentication after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isAuthenticated = true
                let newProfile = UserProfile(name: "Demo User", dailyCalorieGoal: 2000, favoriteCuisines: [])
                self.userProfile = newProfile
                
                // Generate a mock auth token
                self.authToken = UUID().uuidString
                
                // Set session expiry to 7 days from now
                let expiryDate = Date().addingTimeInterval(7 * 24 * 60 * 60)
                UserDefaults.standard.set(expiryDate, forKey: self.sessionExpiryKey)
                UserDefaults.standard.set(self.authToken, forKey: self.tokenKey)
                
                // Save the user profile to UserDefaults
                if let encoded = try? JSONEncoder().encode(newProfile) {
                    UserDefaults.standard.set(encoded, forKey: "user_profile")
                }
                
                self.isLoading = false
                completion(true)
            }
        })
        
        // No "Cancel" option - authentication is required
        
        // Present the alert
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
    
    func signOut() {
        isLoading = true
        errorMessage = "Signing out..."
        
        // Invalidate session
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.invalidateSession()
            self.errorMessage = "Signed out successfully"
            
            // Clear error message after showing it briefly
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.errorMessage = nil
                self.isLoading = false
            }
        }
    }
    
    // Verify auth token before allowing data operations
    private func verifyAuthentication() -> Bool {
        // Check if using local storage mode (bypass authentication)
        if UserDefaults.standard.bool(forKey: "using_local_storage") {
            return true
        }
        
        if !isAuthenticated || authToken == nil {
            errorMessage = "Authentication required"
            return false
        }
        return true
    }
    
    func saveUserProfile(userId: String, profile: UserProfile) {
        guard verifyAuthentication() else { return }
        
        self.userProfile = profile
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "user_profile")
        }
    }
    
    func updateCalorieGoal(to newGoal: Int) {
        guard verifyAuthentication() else { return }
        guard var profile = userProfile else {
            errorMessage = "No active user session"
            return
        }
        
        profile.dailyCalorieGoal = newGoal
        userProfile = profile
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "user_profile")
        }
    }
    
    // Toggle a cuisine in the user's favorite cuisines
    func toggleFavoriteCuisine(_ cuisine: String) {
        isLoading = true
        
        // Ensure we have a userProfile
        guard var localProfile = userProfile else {
            isLoading = false
            errorMessage = "User profile not found"
            return
        }
        
        // Toggle the cuisine
        if localProfile.favoriteCuisines.contains(cuisine) {
            localProfile.favoriteCuisines.removeAll { $0 == cuisine }
        } else {
            localProfile.favoriteCuisines.append(cuisine)
        }
        
        // Update the user profile
        userProfile = localProfile
        
        // Save to local storage
        saveUserProfile(userId: "demo-user", profile: localProfile)
        
        isLoading = false
    }
} 