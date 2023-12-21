import Foundation
import MapKit
import SwiftUI


struct MapDisplay: UIViewRepresentable {
    @StateObject private var locationManager = LocationManager()
    @Binding var centerOnUserLocation: Bool
    @Binding var pins: [Pin]
    @State private var mapView: MKMapView?
    @State private var temporaryPin: MKPointAnnotation?
    @Binding var tempPinLocation: CLLocationCoordinate2D?
    var onTap: (CLLocationCoordinate2D) -> Void
    
    // Initialize with a binding
    init(tempPinLocation: Binding<CLLocationCoordinate2D?>, centerOnUserLocation: Binding<Bool>, pins:Binding<[Pin]>, onTap: @escaping (CLLocationCoordinate2D) -> Void) {
        self._centerOnUserLocation = centerOnUserLocation
        self._pins = pins
//        self._pins = .constant([])  // Initialize as constant empty array
//        PinRepository.shared.getAllPins()
//
//        if let pins = PinRepository.shared.getPins() as? [Pin] {
//            self._pins = .constant(pins)
//        }
        self._tempPinLocation = tempPinLocation
        self.onTap = onTap
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        setupMapView(mapView)
        self.mapView = mapView
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
                mapView.addGestureRecognizer(tapGesture)
        
        addPins(mapView)
        mapView.accessibilityIdentifier = "MapDisplay"
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if centerOnUserLocation {
            recenterMap(uiView)
            centerOnUserLocation = false
        }
        
        uiView.showsUserLocation = true
        
        uiView.removeAnnotations(uiView.annotations)
        
        let newAnnotations = pins.map { pin -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: pin.coordinates.latitude,
                longitude: pin.coordinates.longitude
            )
            annotation.title = pin.name
            return annotation
        }
        
        if let userLocationView = uiView.view(for: uiView.userLocation) {
            userLocationView.tintColor = .blue
        }
        
        uiView.addAnnotations(newAnnotations)
        print("update")
    }
    
    private func addPins(_ mapView: MKMapView) {
        
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: pin.coordinates.latitude,
                longitude: pin.coordinates.longitude
            )
            annotation.title = pin.name
            mapView.addAnnotation(annotation)
        }
    }
    
    private func setupMapView(_ mapView: MKMapView) {
        let coordinate = CLLocationCoordinate2D(latitude: locationManager.latitude, longitude: locationManager.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
    }
    
    private func recenterMap(_ mapView: MKMapView) {
        locationManager.getCurrentLocation()
        let coordinate = CLLocationCoordinate2D(
            latitude: locationManager.latitude,
            longitude: locationManager.longitude
        )
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapDisplay

        init(parent: MapDisplay) {
            self.parent = parent
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            print("hiot")
            let mapView = gesture.view as! MKMapView
            let tapPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(tapPoint, toCoordinateFrom: mapView)
            parent.tempPinLocation = coordinate
            parent.onTap(coordinate)
            
            // Remove previous temporary pin
            if let previousTempPin = parent.temporaryPin {
                mapView.removeAnnotation(previousTempPin)
            }

            let tempPin = MKPointAnnotation()
            tempPin.coordinate = coordinate
            tempPin.title = "New Pin Drop"
            mapView.addAnnotation(tempPin)

            // Update the temporary pin in the parent
            parent.temporaryPin = tempPin
        }
    }
}

struct MapDisplayView: View {
    @State private var tempPinLocation: CLLocationCoordinate2D? = nil
    @ObservedObject var pinRepository = PinRepository.shared
    @State private var centerOnUserLocation = false
    @State private var userPins: [Pin] = PinRepository.shared.getPins()
    @State private var showingAddPinView = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var refreshMap = false
    
    
    var body: some View {
        MapDisplay(tempPinLocation: $tempPinLocation, centerOnUserLocation: $centerOnUserLocation, pins: $userPins){ coordinate in
            print("Tapped on coordinate: \(coordinate)")
        }
            .onAppear {
                centerOnUserLocation = true
                PinRepository.shared.getAllPins()
                userPins = PinRepository.shared.getPins()
                refreshMap.toggle()
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Button(action: {
                                showingAddPinView = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 35))
                                    .padding(5)
                                    .background(Color.white.opacity(0.7))
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .accessibility(identifier: "addPinButton")
                            
                            Button(action: {
                                centerOnUserLocation = true
                            }) {
                                Image(systemName: "location.circle.fill")
                                    .font(.system(size: 35))
                                    .padding(5)
                                    .background(Color.white.opacity(0.7))
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .accessibility(identifier: "locationButton")
                        }
                        .padding(.bottom, 20)
                        .padding(.trailing, 20)
                    }
                }
            )
            .sheet(isPresented: $showingAddPinView, onDismiss: {
                pinRepository.getAllPins()
                userPins = pinRepository.getPins()
                refreshMap.toggle()
            }) {
                AddPinView(alertMessage: $alertMessage, showAlert: $showAlert, tempPinLocation: $tempPinLocation,
                           onPinAdded: {
                               pinRepository.getAllPins()
                               userPins = pinRepository.getPins()
                               refreshMap.toggle()
                           })
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
    }
}

