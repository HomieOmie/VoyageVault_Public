import Foundation
import CoreLocation
import PlaygroundSupport
import MapKit

func getCountryFromCoordinates(latitude: Double, longitude: Double) {
    let location = CLLocation(latitude: latitude, longitude: longitude)
    let geocoder = CLGeocoder()
    
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
        if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
        }
        
        if let placemarks = placemarks, let placemark = placemarks.first, let country = placemark.country {
            print("Country: \(country)")
        } else {
            print("Country not found")
        }
    }
}

func getCityFromCoordinates(latitude: Double, longitude: Double) {
    let location = CLLocation(latitude: latitude, longitude: longitude)
    let geocoder = CLGeocoder()
    
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
        if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
        }
        
        if let placemarks = placemarks, let placemark = placemarks.first, let city = placemark.locality {
            print("City: \(city)")
        } else {
            print("City not found")
        }
    }
}

//class CurrentLocationManager: NSObject, CLLocationManagerDelegate {
//    private var locationManager = CLLocationManager()
//    
//    override init() {
//        super.init()
//        self.locationManager.delegate = self
//        self.locationManager.requestWhenInUseAuthorization()
//    }
//    
//    func start() {
//        locationManager.startUpdatingLocation()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            let geocoder = CLGeocoder()
//            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
//                if let error = error {
//                    print("An error occurred: \(error.localizedDescription)")
//                    return
//                }
//                
//                if let placemarks = placemarks, let placemark = placemarks.first {
//                    let country = placemark.country ?? "Country not found"
//                    let state = placemark.administrativeArea ?? "State not found"
//                    print("Country: \(country), State: \(state)")
//                } else {
//                    print("Location not found")
//                }
//                
//                // Stop updating location after fetching required info
//                self.locationManager.stopUpdatingLocation()
//            }
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Failed to get location: \(error.localizedDescription)")
//    }
//}

//let currentLocationManager = CurrentLocationManager()
//currentLocationManager.start()

//func findLandmarksNearby(latitude: Double, longitude: Double, looking_for: String) {
////    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//    let request = MKLocalSearch.Request()
//    
////    Dont know why but this doesn't do anything.
////    request.region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 0, longitudinalMeters: 0)
//    request.naturalLanguageQuery = looking_for
//    
//    let search = MKLocalSearch(request: request)
//    search.start { (response, error) in
//        if let error = error {
//            print("An error occurred: \(error.localizedDescription)")
//            return
//        }
//        
//        if let response = response, !response.mapItems.isEmpty {
//            let landmark_list = response.mapItems
//            print("There are \(landmark_list.count) \(looking_for) near you:")
//            for item in landmark_list{
//                print("- \(item.name ?? "Unknown Landmark")")
//            }
//        } else {
//            print("No landmarks found.")
//        }
//    }
//}

func findLandmarksNearby(looking_for: String) {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = looking_for
    
    let search = MKLocalSearch(request: request)
    search.start { (response, error) in
        if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
        }
        
        if let response = response, let firstItem = response.mapItems.first {
            let latitude = firstItem.placemark.location?.coordinate.latitude ?? 0.0
            let longitude = firstItem.placemark.location?.coordinate.longitude ?? 0.0
            print("Your current location: Latitude \(latitude), Longitude \(longitude)")
            
            if !response.mapItems.isEmpty {
                let landmark_list = response.mapItems
                print("There are \(landmark_list.count) \(looking_for) near you:")
                for item in landmark_list {
                    print("- \(item.name ?? "Unknown Landmark")")
                }
            } else {
                print("No landmarks found.")
            }
        }
    }
}

func findLocationInformation(looking_for: String) {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = looking_for
    
    let search = MKLocalSearch(request: request)
    search.start { (response, error) in
        if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
        }
        
        if let response = response {
            for item in response.mapItems {
                print("Name: \(item.name ?? "N/A")")
                print("Phone: \(item.phoneNumber ?? "N/A")")
                print("URL: \(item.url?.absoluteString ?? "N/A")")
                print("Latitude: \(item.placemark.location?.coordinate.latitude ?? 0.0)")
                print("Longitude: \(item.placemark.location?.coordinate.longitude ?? 0.0)")
                print("Is Current Location: \(item.isCurrentLocation)")
                print("-----------------------")
            }
        }
    }
}

// Always pulls 25 landmarks 0 clue why.
//findLandmarksNearby(latitude: 37.7749, longitude: -122.4194, looking_for: "landmarks")
//findLandmarksNearby(latitude: 37.7749, longitude: -122.4194, looking_for: "cafes")
//findLandmarksNearby(latitude: 37.7749, longitude: -122.4194, looking_for: "bars")

//findLandmarksNearby(looking_for: "landmarks")
//findLandmarksNearby(looking_for: "cafes")
//findLandmarksNearby(looking_for: "bars")
//findLandmarksNearby(looking_for: "Colleges")

findLocationInformation(looking_for: "parks")


getCountryFromCoordinates(latitude: 37.7749, longitude: -122.4194) // For San Francisco, CA
getCityFromCoordinates(latitude: 37.7749, longitude: -122.4194)

PlaygroundPage.current.needsIndefiniteExecution = true


//MKCoordinateRegion
//MKCoordinateSpan
