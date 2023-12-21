//
//  LocationManager.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/1/23.
//

import Foundation
import MapKit

@MainActor
class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    @Published var country: String?
    @Published var city: String?
    
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    private let locationManager = CLLocationManager()
    
    override init() {
        self.latitude = 0.00
        self.longitude = 0.00
        super.init()
        //      the k stands for constant because apple devs are dumb lol
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //      Dont know what this does but it works so dont touch it
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        //      Need to ask for user permission
        locationManager.requestAlwaysAuthorization()
        
        //      This one is pretty obvious
        locationManager.startUpdatingLocation() //Remember to update Info.plist!
        
        //      When apple needs to call location stuff itll pass calls to specific functions to our app for further processing
        locationManager.delegate = self
    }
    
    func getCurrentLocation() {
        clearLocation()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        if let currLocation = locationManager.location {
            self.latitude = currLocation.coordinate.latitude
            self.longitude = currLocation.coordinate.longitude
        }
    }
    
    func clearLocation () {
        self.latitude = 0.00
        self.longitude = 0.00
    }
    
    func getCountryFromCoordinates(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let placemarks = placemarks, let placemark = placemarks.first, let country = placemark.country {
                self.country = country
                print("Country: \(country)")
            } else {
                self.country = nil
                print("Country not found")
            }
        }
    }
    
    func getCityFromCoordinates(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let placemarks = placemarks, let placemark = placemarks.first, let city = placemark.locality {
                self.city = city
                print("City: \(city)")
            } else {
                self.city = nil
                print("City not found")
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        self.location = location
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
    }
}
