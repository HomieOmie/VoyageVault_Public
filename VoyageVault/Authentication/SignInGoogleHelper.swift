import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
  let idToken: String
  let accessToken: String
  let name: String?
  let email: String?
}

final class SignInGoogleHelper {
  
  @MainActor
  func signIn() async throws -> GoogleSignInResultModel {
    // Ensures there's a top view controller to present the sign-in UI
    guard let topVC = Utilities.shared.topViewController() else {
      throw URLError(.cannotFindHost)
    }
    
    // Performs the Google sign-in process, awaits its completion.
    let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
    
    // Extracts the ID token from the sign-in result
    guard let idToken = gidSignInResult.user.idToken?.tokenString else {
      throw URLError(.badServerResponse)
    }
    
    // Retrieves the access token and optional user details (name and email).
    let accessToken = gidSignInResult.user.accessToken.tokenString
    let name = gidSignInResult.user.profile?.name
    let email = gidSignInResult.user.profile?.email
    
    // Creates a model instance with the obtained tokens and user details.
    let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, name: name, email: email)
    return tokens
  }
  
}
