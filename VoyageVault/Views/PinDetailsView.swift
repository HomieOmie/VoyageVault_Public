//
//  PinDetailsView.swift
//  VoyageVault
//
//  Created by Deep Chandra on 06/11/2023.
//

import SwiftUI



struct PinDetailsView: View {
  @ObservedObject var pinRepository = PinRepository.shared
  @State private var showingDeleteAlert = false
  @State private var url: URL? = nil
  @State private var showingEditView = false
  @State private var refreshPinData = false
  
  var pin: Pin
  
  @Environment(\.presentationMode) var presentationMode
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 10) {
        // Image
        if let url = url {
          AsyncImage(url: url) { phase in
            if let image = phase.image {
              image
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
            } else if phase.error != nil {
              EmptyView()
            } else {
              ProgressView()
                .frame(maxWidth: .infinity)
            }
          }
          .aspectRatio(contentMode: .fit)
        }
        
        // Title and Location
        VStack(alignment: .leading, spacing: 5) {
          Text(pin.name)
            .font(.largeTitle)
            .fontWeight(.bold)
          
          Text("\(pin.city), \(pin.country)")
            .font(.title3)
            .fontWeight(.semibold)
        }
        .padding(.top)
        
        // Divider to separate title from details
        Divider()
        
        // Remaining Details
        VStack(alignment: .leading, spacing: 5) {
          detailView(title: "Type", value: pin.type)
          detailView(title: "Date", value: pin.datetime?.formatted(date: .abbreviated, time: .shortened) ?? "Not available")
          detailView(title: "Coordinates", value: "Lat \(pin.coordinates.latitude), Long \(pin.coordinates.longitude)")
          
          // Notes
          if !pin.notes.isEmpty {
            Text("Notes")
              .font(.headline)
              .fontWeight(.semibold)
            Text(pin.notes)
              .foregroundColor(.secondary)
          }
        }
        .padding([.horizontal, .bottom])
      }
    }
    .task {
      if let path = pin.image {
        let url = try? await StorageManager.shared.getUrlForImage(path: path)
        self.url = url
      }
    }
    .navigationTitle("Pin Details")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Edit") {
          showingEditView = true
        }
      }
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Delete") {
          showingDeleteAlert = true
        }
      }
    }
    .sheet(isPresented: $showingEditView, onDismiss: {
        pinRepository.getAllPins() // This closure will be called when the sheet is dismissed.
    }) {
        // The content of the sheet goes here.
        EditPinView(pin: pin, onPinUpdated: {
            self.refreshPinData.toggle()
        })
    }
    .alert("Are you sure you want to delete this pin?", isPresented: $showingDeleteAlert) {
      Button("Delete", role: .destructive) { performDeletion() }
      Button("Cancel", role: .cancel) { }
    }
  }
  
  // Helper function to create a row of details
  @ViewBuilder
  private func detailView(title: String, value: String) -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.headline)
        .fontWeight(.semibold)
      Text(value)
        .foregroundColor(.secondary)
    }
  }
  
  private func performDeletion() {
    pinRepository.deletePin(pin) { result in
      switch result {
      case .success():
        print("Pin successfully deleted")
        presentationMode.wrappedValue.dismiss()
      case .failure(let error):
        print("Error deleting pin: \(error.localizedDescription)")
      }
    }
  }
}
