import Foundation
import SwiftUI
import Firebase

// AppDelegate to configure Firebase
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct VoyageVaultApp: App {
    // Initialize location manager as shared state object
    @StateObject var locationManager = LocationManager()
    
    // Register the app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // Shared instance of PersistenceController for Core Data
    let persistenceController = PersistenceController.shared
    
    @State private var isFirstLaunch = !UserDefaults.standard.bool(forKey: "HasLaunchedOnce")
    @State private var showSignInView: Bool = false
    
    // App Structure
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSignInView {
                    AuthenticationView(showSignInView: $showSignInView)
                } else if isFirstLaunch {
                    OnboardingView(isFirstLaunch: $isFirstLaunch)
                } else {
                    ContentView(showSignInView: $showSignInView)
                }
            }
            .onAppear {
                let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                showSignInView = (authUser == nil)
            }
        }
    }
}
