import XCTest
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
@testable import VoyageVault

class DBUserTests: XCTestCase {
    
    var authDataResult: AuthDataResultModel?
    
    func setUpWithError() async throws {
        do {
            print("Fetching data...")
            let result = try await Auth.auth().signIn(withEmail: "test@gmail.com", password: "test1234")
            authDataResult = AuthDataResultModel(user: result.user)
            print("data fetched...")
        } catch {
            print("Error fetching data: \(error)")
            throw error
        }
    }
        
    func tearDownWithError() async throws {
        try super.tearDownWithError()
        authDataResult = nil
    }
    
    func testDBUsertests() async throws {
        try await setUpWithError()
        
        do {
            try await testAuthDataResultNotNil()
            try await testDBUserInit()
            try await testDBUserEncodingAndDecoding()
        } catch {
            print("Error in testDBUserTests: \(error)")
            throw error
        }
    }
    
    private func testAuthDataResultNotNil() async throws {
        XCTAssertNotNil(authDataResult)
    }
    
    private func testDBUserInit() async throws {
        let dbUser = DBUser(auth: authDataResult!)
        XCTAssertEqual(dbUser.userId, authDataResult?.uid)
        XCTAssertEqual(dbUser.name, authDataResult?.name)
        XCTAssertEqual(dbUser.email, authDataResult?.email)
        XCTAssertEqual(dbUser.photoUrl, authDataResult?.photoUrl)
        XCTAssertEqual(dbUser.pins, authDataResult?.pins)
    }
    
    private func testDBUserEncodingAndDecoding() async throws {
        let dbUser = DBUser(auth: authDataResult!)
        let encoder = JSONEncoder()
        let data = try encoder.encode(dbUser)

        let decoder = JSONDecoder()
        let decodedDBUser = try decoder.decode(DBUser.self, from: data)

        XCTAssertEqual(dbUser, decodedDBUser)
    }
}
