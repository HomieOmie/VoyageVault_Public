//
//  UserManagerTests.swift
//  VoyageVaultTests
//
//  Created by Om Patel on 12/12/23.
//

import Foundation
import XCTest
import FirebaseFirestore
import FirebaseAuth
@testable import VoyageVault

class UserManagerTests: XCTestCase {
    
    var userManager: UserManager!
    var authDataResult: AuthDataResultModel?
    var authManager: AuthenticationManager!
    
    func setUpWithError() async throws {
        try super.setUpWithError()
        // Initialize UserManager
        userManager = UserManager.shared
        authManager = AuthenticationManager.shared
        
        do {            
            print("Fetching data...")
            authDataResult = try await authManager.createUser(email: "delete@delete.com", password: "delete")
            print("Data fetched...")
        } catch {
            print("Error fetching data: \(error)")
            throw error
        }
    }
    
    func tearDownWithError() async throws {
        // Cleanup code, if needed
        _ = try await authManager.signInUser(email: "delete@delete.com", password: "delete")

        // Delete the user if signed in
        if let currentUser = Auth.auth().currentUser {
            try await currentUser.delete()
            print("User deleted successfully.")
        }
        userManager = nil
        try super.tearDownWithError()
    }
    
    func testUserManagertests() async throws {
        print("running")
        try await setUpWithError()
        
        do {
            try await testCreateAndGetUser()
        } catch {
            XCTFail("Error running tests")
        }
        
        try await tearDownWithError()
    }
    
    private func testCreateAndGetUser() async throws {
        
        do {
            guard let authDataResult = authDataResult else {
                XCTFail("Auth data result is nil.")
                return
            }
            let expectedUser = DBUser(auth: authDataResult)
            // Create the user using the createNewUser method
            try await userManager.createNewUser(user: expectedUser)
            
            // Fetch the user from Firestore to verify creation
            let fetchedUser = try await userManager.getUser(userId: expectedUser.userId)
            
            // Assert
            XCTAssertEqual(fetchedUser.userId, expectedUser.userId)
            XCTAssertEqual(fetchedUser.name, expectedUser.name)
            XCTAssertEqual(fetchedUser.email, expectedUser.email)
            // Add more assertions based on your DBUser structure
        } catch {
            XCTFail("Error creating or fetching user: \(error)")
        }
    }
}
