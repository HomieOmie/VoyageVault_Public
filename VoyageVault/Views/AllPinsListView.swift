//
//  AllPinsView.swift
//  VoyageVault
//
//  Created by Om Patel on 12/8/23.
//


import SwiftUI

struct AllPinsListView: View {
    @ObservedObject private var viewModel = AllPinsViewModel.shared
    @State private var searchText = ""

    let backgroundColor = Color(red: 248/255, green: 233/255, blue: 223/255)
    let textColor = Color(red: 199/255, green: 92/255, blue: 0)

    var body: some View {
        List {
            ForEach(filteredPins, id: \.self) { pin in
                NavigationLink(destination: PinDetailsView(pin: pin)) {
                    Text(pin.name)
                        .foregroundColor(textColor)
                        .padding()
                }
                .listRowBackground(backgroundColor)
            }
        }
        .background(backgroundColor)
        .searchable(text: $searchText)
        .listStyle(PlainListStyle())
        .onChange(of: viewModel.selectedSortOption) { (_, newSortOption) in
            // Sorting option changed, the list will update automatically
        }
        .onAppear {
            viewModel.selectedSortOption = .nameAscending  // Default sorting option
        }
    }

    private var filteredPins: [Pin] {
        if searchText.isEmpty {
            return viewModel.sortedPins
        } else {
            return viewModel.sortedPins.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.city.localizedCaseInsensitiveContains(searchText) ||
                $0.country.localizedCaseInsensitiveContains(searchText) ||
                $0.notes.localizedCaseInsensitiveContains(searchText) ||
                $0.type.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
