//
//  AddPinView.swift
//  VoyageVault
//
//  Created by Deep Chandra on 05/11/2023.
//

import SwiftUI
import FirebaseFirestore
import PhotosUI

struct AddPinView: View {
  @ObservedObject var pinRepository = PinRepository.shared
  @ObservedObject var locationManager = LocationManager.shared
  
  
  @Binding var alertMessage: String
  @Binding var showAlert: Bool
  
  @State private var name: String = ""
  @State private var type: String = ""
  @State private var city: String = ""
  @State private var country: String = ""
  @State private var selectedDate: Date = Date()
  @State private var latitude: Double = 0.0
  @State private var longitude: Double = 0.0
  @State private var currLatitude: Double = 0.0
  @State private var currLongitude: Double = 0.0
  @State private var notes: String = ""
  //  @State private var images: [UIImage] = []
  @State private var imagePreview: UIImage? = nil
  @State private var selectedPhoto: PhotosPickerItem? = nil
  @State private var imageData: Data? = nil
  @State private var isSubmitting = false
  @State private var isCameraPresented: Bool = false
  enum LocationSource: String, CaseIterable, Equatable {
    case currentLocation = "Current Location"
    case tapOnMap = "New Pin Drop"
    
    static func == (lhs: LocationSource, rhs: LocationSource) -> Bool {
      return lhs.rawValue == rhs.rawValue
    }
  }
  @State private var locationSource: LocationSource = .currentLocation
  @Binding var tempPinLocation: CLLocationCoordinate2D?
  
  
  var onPinAdded: () -> Void
  
  @Environment(\.presentationMode) var presentationMode
  
  private let coordinateFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 6
    return formatter
  }()
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Location")) {
          Picker(selection: $locationSource, label: Text("")){
            Text("Current Location").tag(LocationSource.currentLocation)
            Text("New Pin Drop").tag(LocationSource.tapOnMap)
          }
          .pickerStyle(SegmentedPickerStyle())
          .onChange(of: locationSource) { (_, newLocationSource) in
            switch newLocationSource {
            case .currentLocation:
              if let currentLocation = locationManager.location {
                latitude = currLatitude
                longitude = currLongitude
                locationManager.getCityFromCoordinates(latitude: latitude, longitude: longitude)
                locationManager.getCountryFromCoordinates(latitude: latitude, longitude: longitude)
              }
            case .tapOnMap:
              if let tempLocation = tempPinLocation {
                latitude = tempLocation.latitude
                longitude = tempLocation.longitude
                locationManager.getCityFromCoordinates(latitude: latitude, longitude: longitude)
                locationManager.getCountryFromCoordinates(latitude: latitude, longitude: longitude)
              } else {
                latitude = currLatitude
                longitude = currLongitude
                locationManager.getCityFromCoordinates(latitude: latitude, longitude: longitude)
                locationManager.getCountryFromCoordinates(latitude: latitude, longitude: longitude)
              }
            }
          }
        }
        Section(header: Text("Pin Details")) {
          if imagePreview == nil {
            HStack {
              PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                HStack {
                  Image(systemName: "camera")
                  Text("Add Image...")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
              }
              .buttonStyle(.bordered)
              
              Button("Take Picture") {
                isCameraPresented.toggle()
              }
              .buttonStyle(.bordered)
              .sheet(isPresented: $isCameraPresented) {
                ImageCaptureView(imagePreview: $imagePreview, imageData: $imageData)
              }
            }
          } else {
            // If there is an imagePreview, show the image and a button to change it
            HStack {
              Image(uiImage: imagePreview!)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .cornerRadius(8)
                .overlay(
                  Button(action: {
                    // Clear the selection when x on the image preview is pressed
                    clearImageSelection()
                  }) {
                    Image(systemName: "xmark.circle.fill")
                      .foregroundColor(.white.opacity(0.8))
                      .padding(3)
                      .background(Color.gray)
                      .clipShape(Circle())
                  }
                    .padding(3), alignment: .topTrailing
                )
              
              
              PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared())
              {
                Text("Change Photo")
              }
              .buttonStyle(.bordered)
            }
          }
          
          
          TextField("Name", text: $name)
          TextField("City", text: $city)
          TextField("Country", text: $country)
          TextField("Type", text: $type)
          DatePicker("Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
          ZStack(alignment: .leading) {
            if notes.isEmpty {
              Text("Notes")
                .foregroundColor(.gray.opacity(0.5))
                .padding(.leading, 5)
                .padding(.bottom, 80)
            }
            TextEditor(text: $notes)
              .frame(minHeight: 100)
          }
          TextField("Latitude", value: $latitude, formatter: coordinateFormatter)
          TextField("Longitude", value: $longitude, formatter: coordinateFormatter)
        }
        
        Button(action: addPin) {
          Text("Submit")
        }
        .disabled(isSubmitting)
        .accessibility(identifier: "submitButton")
      }
      .overlay(
        ZStack {
          if isSubmitting {
            Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
            ProgressView("Submitting Pin...")
              .progressViewStyle(CircularProgressViewStyle(tint: .white))
              .foregroundColor(.white)
          }
        }
      )
      .onChange(of: selectedPhoto) {
        Task {
          guard let item = selectedPhoto,
                let data = try await item.loadTransferable(type: Data.self) else {
            clearImageSelection()
            return
          }
          self.imageData = data
          if let uiImage = UIImage(data: data) {
            self.imagePreview = uiImage
          }
        }
      }
      
      .navigationBarTitle("Add New Pin", displayMode: .inline)
      .navigationBarItems(leading: Button("Cancel") {
        presentationMode.wrappedValue.dismiss()
      })
      .alert(isPresented: $showAlert) {
        Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
          self.presentationMode.wrappedValue.dismiss()
        }
        )
      }
      .onAppear {
        if let currentLocation = locationManager.location {
          currLatitude = currentLocation.coordinate.latitude
          currLongitude = currentLocation.coordinate.longitude
          locationManager.getCityFromCoordinates(latitude: latitude, longitude: longitude)
          locationManager.getCountryFromCoordinates(latitude: latitude, longitude: longitude)
          latitude = currLatitude
          longitude = currLongitude
        }
      }
      .onReceive(locationManager.$city) { updatedCity in
        self.city = updatedCity ?? ""
      }
      .onReceive(locationManager.$country) { updatedCountry in
        self.country = updatedCountry ?? ""
      }
    }
  }
  
  private func addPin() {
    guard !name.isEmpty, !city.isEmpty, !country.isEmpty, !type.isEmpty else {
      self.alertMessage = "Please fill in all fields."
      self.showAlert = true
      return
    }
    
    guard !isSubmitting else {
      return // Do nothing if already submitting
    }
    
    isSubmitting = true
    
    let newPinId = UUID().uuidString
    
    if let imageData = imageData {
      // Asynchronously upload the image and wait for the process to complete before creating the pin.
      Task {
        do {
          let imagePath = try await StorageManager.shared.saveImage(data: imageData, userId: pinRepository.user?.userId, pinId: newPinId)
          print("Successfully uploaded image!")
          print("Path: ", imagePath)
          
          // Create the pin object with the image path
          let newPin = Pin(
            id: newPinId,
            name: self.name,
            coordinates: GeoPoint(latitude: latitude, longitude: longitude),
            datetime: selectedDate,
            notes: notes,
            type: type,
            city: city,
            country: country,
            image: imagePath
          )
          
          // Call createPin on the main thread after image upload is complete
          DispatchQueue.main.async {
            self.createPinHandler(newPin.dictionary)
          }
        } catch {
          DispatchQueue.main.async {
            self.alertMessage = "Error uploading image: \(error.localizedDescription)"
            self.showAlert = true
          }
        }
      }
    } else {
      // Proceed to create the pin without an image.
      let newPin = Pin(
        id: newPinId,
        name: self.name,
        coordinates: GeoPoint(latitude: latitude, longitude: longitude),
        datetime: selectedDate,
        notes: notes,
        type: type,
        city: city,
        country: country,
        image: nil
      )
      
      // No need to wait, call createPin directly
      self.createPinHandler(newPin.dictionary)        }
  }
  
  private func createPinHandler(_ pinDictionary: [String: Any]) {
    pinRepository.createPin(pinDictionary) { result in
      switch result {
      case .success():
        onPinAdded()
        self.alertMessage = "Pin successfully added!"
        isSubmitting = false
      case .failure(let error):
        self.alertMessage = "Error adding pin: \(error.localizedDescription)"
        isSubmitting = false;
      }
      self.showAlert = true
    }
  }
  
  private func clearImageSelection() {
    selectedPhoto = nil
    imageData = nil
    imagePreview = nil
  }
}
