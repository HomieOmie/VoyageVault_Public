import Foundation
import SwiftUI
import MapKit

struct MiniMapDisplay: UIViewRepresentable {
    var pins: [Pin]
    let paddingFactor: Double = 50
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.isScrollEnabled = false
        setupMapView(mapView)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotations(for: uiView)
    }
    
    private func setupMapView(_ mapView: MKMapView) {
        let region = calculateRegion(for: pins)
        mapView.setRegion(region, animated: true)
    }
    
    private func updateAnnotations(for mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        let annotations = pins.map { pin -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: pin.coordinates.latitude,
                longitude: pin.coordinates.longitude
            )
            annotation.title = pin.name
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
    
    private func calculateRegion(for pins: [Pin]) -> MKCoordinateRegion {
        guard !pins.isEmpty else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        }
        
        var minLat = pins.first!.coordinates.latitude
        var maxLat = minLat
        var minLon = pins.first!.coordinates.longitude
        var maxLon = minLon
        
        for pin in pins {
            minLat = min(minLat, pin.coordinates.latitude)
            maxLat = max(maxLat, pin.coordinates.latitude)
            minLon = min(minLon, pin.coordinates.longitude)
            maxLon = max(maxLon, pin.coordinates.longitude)
        }
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * paddingFactor, longitudeDelta: (maxLon - minLon) * paddingFactor)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MiniMapDisplay
        
        init(_ parent: MiniMapDisplay) {
            self.parent = parent
        }
    }
}
