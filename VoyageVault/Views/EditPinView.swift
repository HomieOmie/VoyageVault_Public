import SwiftUI
import FirebaseFirestore
import PhotosUI
import FirebaseStorage

struct EditPinView: View {
  @ObservedObject var pinRepository = PinRepository.shared
  @ObservedObject var locationManager = LocationManager.shared
  
  @State var alertMessage: String = ""
  @State var showAlert: Bool = false
  
  @State private var name: String = ""
  @State private var type: String = ""
  @State private var city: String = ""
  @State private var country: String = ""
  @State private var selectedDate: Date = Date()
  @State private var latitude: Double = 0.0
  @State private var longitude: Double = 0.0
  @State private var notes: String = ""
  @State private var image: String = ""
  
  @State private var imagePreview: UIImage? = nil
  @State private var selectedPhoto: PhotosPickerItem? = nil
  @State private var imageData: Data? = nil
  
  @State private var isSubmitting = false
  
  @State private var photoUpdated = false
  
  @Environment(\.presentationMode) var presentationMode
  
  private let coordinateFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 6
    return formatter
  }()
  
  var originalPin: Pin
  
  var onPinUpdated: () -> Void = {}
  
  init(pin: Pin, onPinUpdated: @escaping () -> Void = {}) {
    self.originalPin = pin
    
    _name = State(initialValue: pin.name)
    _type = State(initialValue: pin.type)
    _city = State(initialValue: pin.city)
    _country = State(initialValue: pin.country)
    _selectedDate = State(initialValue: pin.datetime ?? Date())
    _latitude = State(initialValue: pin.coordinates.latitude)
    _longitude = State(initialValue: pin.coordinates.longitude)
    _notes = State(initialValue: pin.notes)
    _image = State(initialValue: pin.image ?? "")
    
  }
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Pin Details")) {
          if imagePreview == nil {
            HStack {
              PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                HStack {
                  Image(systemName: "photo.badge.plus")
                  Text("Add Image...")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
              }
              .buttonStyle(.bordered)
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
        
        Button(action: updatePin) {
          Text("Update")
        }
        .disabled(isSubmitting)
      }
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
          self.photoUpdated = true
        }
      }
      
      .navigationBarTitle("Edit Pin", displayMode: .inline)
      .navigationBarItems(leading: Button("Cancel") {
        presentationMode.wrappedValue.dismiss()
      })
      .alert(isPresented: $showAlert) {
        Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
          self.presentationMode.wrappedValue.dismiss()
        }
        )
      }
    }
    .onAppear{
      loadImage()
    }
  }
  
  private func updatePin() {
    guard !name.isEmpty, !city.isEmpty, !country.isEmpty, !type.isEmpty else {
      self.alertMessage = "Please fill in all fields."
      self.showAlert = true
      return
    }
    
    guard !isSubmitting else {
      return
    }
    
    isSubmitting = true
    
    Task{
      if photoUpdated{
        if let oldImage = originalPin.image {
          print("Deleting old image...")
          try await StorageManager.shared.deleteImage(path: oldImage)
        }
      }
    }
    
    // either old photo or new photo
    if let imageData = imageData{
      Task {
        do {
          let newPinId = UUID().uuidString
          var updateImagePath = originalPin.image
          
          if photoUpdated {
            updateImagePath = try await StorageManager.shared.saveImage(data: imageData, userId: pinRepository.user?.userId, pinId: newPinId)
          }

          
          // Create updated pin with new image path
          let updatedPin = Pin(
            id: newPinId,
            name: self.name,
            coordinates: GeoPoint(latitude: latitude, longitude: longitude),
            datetime: selectedDate,
            notes: notes,
            type: type,
            city: city,
            country: country,
            image: updateImagePath
          )
          
          // Now call updatePin on the pinRepository
          self.updatePinHandler(updatedPin.dictionary, originalPin.id)
        } catch {
          self.alertMessage = "Error updating pin: \(error.localizedDescription)"
          self.showAlert = true
          isSubmitting = false
        }
      }
    } else {
      // If photo has not been changed or removed
      let updatedPin = Pin(
        id: originalPin.id,
        name: self.name,
        coordinates: GeoPoint(latitude: latitude, longitude: longitude),
        datetime: selectedDate,
        notes: notes,
        type: type,
        city: city,
        country: country,
        image: nil
      )
      self.updatePinHandler(updatedPin.dictionary, originalPin.id)
    }
  }
  
  private func updatePinHandler(_ pinDictionary: [String: Any], _ originalPinId: String) {
    pinRepository.updatePin(pinDictionary, originalPinId: originalPinId) { result in
      switch result {
      case .success():
        self.onPinUpdated()
        self.alertMessage = "Pin successfully updated!"
        isSubmitting = false
      case .failure(let error):
        self.alertMessage = "Error updating pin: \(error.localizedDescription)"
        isSubmitting = false;
      }
      self.showAlert = true
    }
  }
  
  private func clearImageSelection() {
    selectedPhoto = nil
    imageData = nil
    imagePreview = nil
    photoUpdated = true
  }
  
  private func loadImage() {
    if let imagePath = originalPin.image {
      Task {
        do {
          if let imageData = try await StorageManager.shared.getImageData(path: imagePath) {
            DispatchQueue.main.async {
              self.imagePreview = UIImage(data: imageData)
            }
          }
        } catch {
          print("Error loading image data: \(error)")
        }
      }
    }
  }
}
