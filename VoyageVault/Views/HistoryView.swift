//
//  HistoryView.swift
//  VoyageVault
//
//  Created by Om Patel on 12/8/23.
//

import SwiftUI

struct HistoryView: View {
    @State private var selectedTab: Tab = .allPins
    @State private var searchText = ""
    @State private var selectedSortOption: FilterOption?
    
    enum FilterOption: Equatable {
        case nameAscending
        case nameDescending
        case dateAscending
        case dateDescending
    }
    
    let backgroundColor = Color(red: 248/255, green: 233/255, blue: 223/255)
    
    enum Tab {
        case allPins, countries, cities
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Title, Filter icon, and Picker
                HStack {
                    // Tab selection
                    Picker(selection: $selectedTab, label: Text("")) {
                        Text("Countries").tag(Tab.countries)
                        Text("Cities").tag(Tab.cities)
                        Text("All Pins").tag(Tab.allPins)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Filter icon with Sorting menu
                    Menu {
                        Button(action: {
                            selectedSortOption = .nameAscending
                            handleSortSelection()
                        }) {
                            Text("Sort By Name (A-Z)")
                        }
                        
                        Button(action: {
                            selectedSortOption = .nameDescending
                            handleSortSelection()
                        }) {
                            Text("Sort By Name (Z-A)")
                        }
                        
                        Button(action: {
                            selectedSortOption = .dateAscending
                            handleSortSelection()
                        }) {
                            Text("Sort By Date (0-9)")
                        }
                        
                        Button(action: {
                            selectedSortOption = .dateDescending
                            handleSortSelection()
                        }) {
                            Text("Sort By Date (9-0)")
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .imageScale(.large)
                            .padding(.trailing)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                .padding(.horizontal, 50)
                .background(backgroundColor)
                
                // Display list based on the selected tab
                if selectedTab == .countries {
                    CountryView()
                        .background(backgroundColor)
                } else if selectedTab == .allPins {
                    AllPinsListView()
                } else {
                    CityListView()
                }
            }
            .background(backgroundColor)
            .navigationBarTitle("History")
            .background(backgroundColor)
        }
    }
    
    private func handleSortSelection() {
        guard let sortOption = selectedSortOption else {
            return
        }
        
        // Implement sorting logic based on the selected tab and option
        switch selectedTab {
        case .countries:
            CountryViewModel.shared.sortCountries(option: sortOption)
        case .allPins:
            AllPinsViewModel.shared.sortPins(option: sortOption)
        case .cities:
            // Implement sorting logic for CityListView
            CityListViewModel.shared.sortCities(option: sortOption)
        }
    }
}
