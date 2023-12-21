//
//  AuthenticationManagerTests.swift
//  VoyageVaultTests
//
//  Created by Om Patel on 12/12/23.
//

import Foundation
import XCTest
import FirebaseFirestore
import FirebaseAuth
@testable import VoyageVault

class AuthenticationManagerTests: XCTestCase {

    var authManager: AuthenticationManager!
    var authDataResult: AuthDataResultModel?

    func setUpWithError() async throws {
        try super.setUpWithError()
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
        _ = try await authManager.signInUser(email: "delete@delete.com", password: "delete")

        if let currentUser = Auth.auth().currentUser {
            try await currentUser.delete()
            print("User deleted successfully.")
        }
        authManager = nil
        try super.tearDownWithError()
    }
    
    func testAuthManagerTests() async throws {
        try await setUpWithError()
        
        do {
            try await testGetProviders()
            try await testGetAuthenticatedUser()
            try await testSignOut()
            try await tearDownWithError()
        } catch {
            try await tearDownWithError()
            XCTFail("Error running tests")
        }
    }
    
    private func testGetProviders() async throws {
        do {
            let providers = try authManager.getProviders()
            XCTAssertFalse(providers.isEmpty)
            XCTAssertTrue(providers.contains(.email))
        } catch {
            XCTFail("Error getting providers: \(error)")
        }
    }

    private func testSignOut() async throws {
        try authManager.signOut()
        XCTAssertNil(Auth.auth().currentUser)
    }
    
    private func testGetAuthenticatedUser() async throws {
        do {
            let authenticatedUser = try authManager.getAuthenticatedUser()

            // Assert
            XCTAssertNotNil(authenticatedUser)
            XCTAssertEqual(authenticatedUser.email, "delete@delete.com")
        } catch {
            XCTFail("Error getting authenticated user: \(error)")
        }
    }
}

