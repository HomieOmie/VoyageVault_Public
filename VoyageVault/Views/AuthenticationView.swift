import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class AuthenticationViewModel: ObservableObject {
  @Published var email = ""
  @Published var password = ""
  @Published var name = ""
  @Published var currentError: AuthenticationError?
  
  func signUpEmail(completion: @escaping (Bool) -> Void) async {
    guard !email.isEmpty, !password.isEmpty else {
      currentError = .emptyFields
      return
    }
    
    do {
      let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
      let user = DBUser(auth: authDataResult)
      try await UserManager.shared.createNewUser(user: user)
      completion(false)
    } catch {
      currentError = .authenticationFailed(error)
    }
  }
  
  func signInEmail(completion: @escaping (Bool) -> Void) async {
    guard !email.isEmpty, !password.isEmpty else {
      currentError = .emptyFields
      return
    }
    
    do {
      try await AuthenticationManager.shared.signInUser(email: email, password: password)
      completion(false)
    } catch {
      currentError = .authenticationFailed(error)
    }
  }
  
  func signInGoogle() async throws {
    let helper = SignInGoogleHelper()
    let tokens = try await helper.signIn()
    let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
    // Check if user already exists in Firestore
    let userId = authDataResult.uid
        do {
            try await UserManager.shared.getUser(userId: userId)
        } catch {
            // If the user does not exist, create a new one
            let newUser = DBUser(auth: authDataResult)
            try await UserManager.shared.createNewUser(user: newUser)
        }
  }
}

struct AuthenticationView: View {
  @Binding var showSignInView: Bool
  @StateObject private var viewModel = AuthenticationViewModel()
  @State private var showingSignUp = false
  
  let lightColor = Color(red: 248/255, green: 233/255, blue: 223/255)
  let darkColor = Color(red: 199/255, green: 92/255, blue: 0)
  
  var body: some View {
    ZStack {
      LinearGradient(gradient: Gradient(colors: [darkColor, lightColor]), startPoint: .top, endPoint: .bottom)
        .edgesIgnoringSafeArea(.all)
      
      VStack(spacing: 20) {
        Spacer()
        
        Text("VoyageVault")
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(lightColor)
        
        Text("🌍")
          .font(.system(size: 100))
        
        if showingSignUp {
          TextField("Name", text: $viewModel.name)
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal, 40)
        }
        
        TextField("Email", text: $viewModel.email)
          .padding()
          .background(Color.white.opacity(0.8))
          .cornerRadius(10)
          .shadow(radius: 5)
          .padding(.horizontal, 40)
        
        SecureField("Password", text: $viewModel.password)
          .padding()
          .background(Color.white.opacity(0.8))
          .cornerRadius(10)
          .shadow(radius: 5)
          .padding(.horizontal, 40)
        
        
        showingSignUp ? (Button {
          Task {
            await viewModel.signUpEmail { success in
              showSignInView = success
              if !success, let error = viewModel.currentError {
                print("Sign up error: \(error.localizedDescription)")
              }
            }
          }
        }
      label: {
        Text("Sign Up")
          .fontWeight(.bold)
          .foregroundColor(lightColor)
          .padding()
          .frame(maxWidth: .infinity)
          .background(darkColor)
          .cornerRadius(10)
          .padding(.horizontal, 40)
      }
          .shadow(radius: 5)) : (
            Button {
            Task {
              await viewModel.signInEmail { success in
                showSignInView = success
                if !success, let error = viewModel.currentError {
                  print("Sign in error: \(error.localizedDescription)")
                }
              }
            }
          }
        label: {
          Text("Sign In")
            .fontWeight(.bold)
            .foregroundColor(lightColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(darkColor)
            .cornerRadius(10)
            .padding(.horizontal, 40)
        }
        .shadow(radius: 5))
        
        Text("OR")
          .fontWeight(.bold)
        
        HStack {
          GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .icon, state: .normal)) {
            Task {
              do {
                try await viewModel.signInGoogle()
                showSignInView = false
              } catch {
                print(error)
              }
            }
          }
          .cornerRadius(.infinity)
          .padding(10.0)
          .background(darkColor)
          .cornerRadius(.infinity)
          .shadow(radius: 5, x: 0, y: 4)
        }
        
        Spacer()
        
        showingSignUp ? (Text("Already have an account? Sign in here!")
          .foregroundColor(darkColor)
          .font(.system(size: 14))
          .onTapGesture {
            showingSignUp = false
          }) :
        (Text("Don't have an account? Sign up here!")
          .foregroundColor(darkColor)
          .font(.system(size: 14))
          .onTapGesture {
            showingSignUp = true
          })
      }
    }
  }
}

enum AuthenticationError: Error, LocalizedError {
    case emptyFields
    case authenticationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "Please enter both email and password."
        case .authenticationFailed(let error):
            return error.localizedDescription
        }
    }
}

//struct AuthenticationView_Previews: PreviewProvider {
//    static var previews: some View {
//      AuthenticationView(showSignInView: .constant(false))
//    }
//}
