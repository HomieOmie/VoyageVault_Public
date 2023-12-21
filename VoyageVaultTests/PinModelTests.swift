//
//  PinModelTests.swift
//  VoyageVaultTests
//
//  Created by Om Patel on 12/10/23.
//

import Foundation
import XCTest
import FirebaseFirestore
import FirebaseFirestoreSwift

@testable import VoyageVault // Import the module where your Pin struct is defined

class PinTests: XCTestCase {
    
    // MARK: - Properties
    
    var pin: Pin!
    
    // MARK: - Set Up / Tear Down
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create a sample Pin for testing
        pin = Pin(
            id: "1",
            name: "Test Pin",
            coordinates: GeoPoint(latitude: 1.0, longitude: 2.0),
            datetime: nil,
            notes: "This is a test pin",
            type: "Test",
            city: "TestCity",
            country: "TestCountry",
            image: "test_image.jpg"
        )
    }
    
    override func tearDownWithError() throws {
        pin = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test Cases
    func testPinEquality() {
        // Arrange
        let pin1 = Pin(
            id: "1",
            name: "Test Pin",
            coordinates: GeoPoint(latitude: 1.0, longitude: 2.0),
            datetime: nil,
            notes: "This is a test pin",
            type: "Test",
            city: "TestCity",
            country: "TestCountry",
            image: "test_image.jpg"
        )
        
        let pin2 = Pin(
            id: "2",
            name: "Test Pin",
            coordinates: GeoPoint(latitude: 3.0, longitude: 4.0),
            datetime: nil,
            notes: "This is another test pin",
            type: "Test",
            city: "TestCity",
            country: "TestCountry",
            image: "another_test_image.jpg"
        )
        
        // Act
        let areEqual = pin1 == pin2
        
        // Assert
        XCTAssertTrue(areEqual, "Pins with the same country, city, and name should be equal")
    }
    
    func testPinComparisonByCity() {
        // Arrange
        let pin1 = Pin(
            id: "1",
            name: "Alpha",
            coordinates: GeoPoint(latitude: 1.0, longitude: 2.0),
            datetime: nil,
            notes: "This is a test pin",
            type: "Test",
            city: "CityA",
            country: "CountryA",
            image: "test_image.jpg"
        )
        
        let pin2 = Pin(
            id: "2",
            name: "Beta",
            coordinates: GeoPoint(latitude: 3.0, longitude: 4.0),
            datetime: nil,
            notes: "This is another test pin",
            type: "Test",
            city: "CityB",
            country: "CountryA",
            image: "another_test_image.jpg"
        )
        
        // Act
        let isLessThan = pin1 < pin2
        
        // Assert
        XCTAssertTrue(isLessThan, "Pin1 should be less than Pin2 based on country, city, and name")
    }
    
    func testPinComparisonByCountry() {
        // Arrange
        let pin1 = Pin(
            id: "1",
            name: "Alpha",
            coordinates: GeoPoint(latitude: 1.0, longitude: 2.0),
            datetime: nil,
            notes: "This is a test pin",
            type: "Test",
            city: "CityA",
            country: "CountryA",
            image: "test_image.jpg"
        )
        
        let pin2 = Pin(
            id: "2",
            name: "Beta",
            coordinates: GeoPoint(latitude: 3.0, longitude: 4.0),
            datetime: nil,
            notes: "This is another test pin",
            type: "Test",
            city: "CityB",
            country: "CountryB", // Different country
            image: "another_test_image.jpg"
        )
        
        // Act
        let isLessThan = pin1 < pin2
        
        // Assert
        XCTAssertTrue(isLessThan, "Pin1 should be less than Pin2 based on country")
    }
    
    func testPinComparisonByName() {
        // Arrange
        let pin1 = Pin(
            id: "1",
            name: "Alpha",
            coordinates: GeoPoint(latitude: 1.0, longitude: 2.0),
            datetime: nil,
            notes: "This is a test pin",
            type: "Test",
            city: "CityA",
            country: "CountryA",
            image: "test_image.jpg"
        )
        
        let pin2 = Pin(
            id: "2",
            name: "Beta",
            coordinates: GeoPoint(latitude: 3.0, longitude: 4.0),
            datetime: nil,
            notes: "This is another test pin",
            type: "Test",
            city: "CityA",
            country: "CountryA",
            image: "another_test_image.jpg"
        )
        
        // Act
        let isLessThan = pin1 < pin2
        
        // Assert
        XCTAssertTrue(isLessThan, "Pin1 should be less than Pin2 based on name")
    }
    
    func testPinHashing() {
        // Arrange
        let pin1 = Pin(
            id: "1",
            name: "Alpha",
            coordinates: GeoPoint(latitude: 1.0, longitude: 2.0),
            datetime: nil,
            notes: "This is a test pin",
            type: "Test",
            city: "CityA",
            country: "CountryA",
            image: "test_image.jpg"
        )
        
        let pin2 = Pin(
            id: "2",
            name: "Beta",
            coordinates: GeoPoint(latitude: 3.0, longitude: 4.0),
            datetime: nil,
            notes: "This is another test pin",
            type: "Test",
            city: "CityB",
            country: "CountryB",
            image: "another_test_image.jpg"
        )
        
        // Act
        var hasher1 = Hasher()
        pin1.hash(into: &hasher1)
        
        var hasher2 = Hasher()
        pin2.hash(into: &hasher2)
        
        // Assert
        XCTAssertNotEqual(hasher1.finalize(), hasher2.finalize(), "Hashes should be different for pins with different ids")
    }
    
    func testDictionaryRepresentation() {
        // Arrange
        let pin = Pin(
            id: "1",
            name: "Test Pin",
            coordinates: GeoPoint(latitude: 1.0, longitude: 2.0),
            datetime: nil,
            notes: "This is a test pin",
            type: "Test",
            city: "TestCity",
            country: "TestCountry",
            image: "test_image.jpg"
        )
        
        // Act
        let dictionary = pin.dictionary
        
        XCTAssertEqual(dictionary["id"] as? String, "1", "Dictionary should contain the correct 'id' value")
        XCTAssertEqual(dictionary["name"] as? String, "Test Pin", "Dictionary should contain the correct 'name' value")
        XCTAssertEqual(dictionary["coordinates"] as? GeoPoint, GeoPoint(latitude: 1.0, longitude: 2.0), "Dictionary should contain the correct 'coordinates' value")
        XCTAssertEqual(dictionary["datetime"] as? Date, nil, "Dictionary should contain the correct 'datetime' value (nil)")
        XCTAssertEqual(dictionary["notes"] as? String, "This is a test pin", "Dictionary should contain the correct 'notes' value")
        XCTAssertEqual(dictionary["type"] as? String, "Test", "Dictionary should contain the correct 'type' value")
        XCTAssertEqual(dictionary["city"] as? String, "TestCity", "Dictionary should contain the correct 'city' value")
        XCTAssertEqual(dictionary["country"] as? String, "TestCountry", "Dictionary should contain the correct 'country' value")
        XCTAssertEqual(dictionary["image"] as? String, "test_image.jpg", "Dictionary should contain the correct 'image' value")
        
        // Ensure that nil values are excluded
        XCTAssertNil(dictionary["datetime"], "Dictionary should not contain 'datetime' key for nil value")
    }
    
}
