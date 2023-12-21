import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserManager {
  
  static let shared = UserManager()
  private init() { }
  
  private let userCollection = Firestore.firestore().collection("users")
  
  private func userDocument(userId: String) -> DocumentReference {
    userCollection.document(userId)
  }
  
  func createNewUser(user: DBUser) async throws {
    try userDocument(userId: user.userId).setData(from: user, merge: false)
  }
  
  func getUser(userId: String) async throws -> DBUser {
      try await userDocument(userId: userId).getDocument(as: DBUser.self)
  }
}
