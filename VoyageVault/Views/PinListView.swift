//
//  PinListView.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/4/23.
//

import Foundation
import SwiftUI

struct PinListView: View {
    @ObservedObject var pinViewModel: PinViewModel
    
    let backgroundColor = Color(red: 248/255, green: 233/255, blue: 223/255)
    let textColor = Color(red: 199/255, green: 92/255, blue: 0)
    
    var body: some View {
        List {
            // Add MiniMapDisplay as a header
            MiniMapDisplay(pins: pinViewModel.pinsForCity)
                .frame(height: 200) // Adjust the height as needed
                .listRowInsets(EdgeInsets())
            
            // Existing ForEach for pins
            ForEach(pinViewModel.pinsForCity) { pin in
                NavigationLink(destination: PinDetailsView(pin: pin)) {
                    Text(pin.name)
                        .foregroundColor(textColor)
                        .padding()
                }
                .listRowBackground(backgroundColor)
            }
        }
        .background(backgroundColor)
        .listStyle(PlainListStyle())
        .navigationBarTitle("Pins for \(pinViewModel.city)", displayMode: .inline)
    }
}
