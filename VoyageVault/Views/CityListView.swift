//
//  CityListView.swift
//  VoyageVault
//
//  Created by Om Patel on 12/8/23.
//

import SwiftUI

struct CityListView: View {
    @ObservedObject private var viewModel = CityListViewModel.shared
    
    @State private var searchText = ""
    
    let backgroundColor = Color(red: 248/255, green: 233/255, blue: 223/255)
    let textColor = Color(red: 199/255, green: 92/255, blue: 0)
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(backgroundColor)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(textColor)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(textColor)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(textColor)
    }
    
    var body: some View {
            List {
                ForEach(filteredCities, id: \.self) { city in
                    NavigationLink(destination: PinListView(pinViewModel: PinViewModel(city: city))) {
                        HStack {
                            Text(city)
                                .font(.headline)
                                .foregroundColor(textColor)
                            Spacer()
                            Text("\(viewModel.cities[city] ?? 0) Pins")
                                .foregroundColor(.gray)
                        }
                    }
                    .listRowBackground(backgroundColor)
                }
            }
            .background(backgroundColor)
            .searchable(text: $searchText)
            .listStyle(PlainListStyle())
            .onChange(of: viewModel.selectedSortOption) { (_, newSortOption) in
            }
            .onAppear {
                viewModel.selectedSortOption = .nameAscending  // Default sorting option
            }
    }
    
    private var filteredCities: [String] {
        print("SORETD: ", viewModel.sortedCities)
        if searchText.isEmpty {
            print("SORETD: ", viewModel.sortedCities)
            return viewModel.sortedCities
        } else {
            return viewModel.sortedCities.filter { city in
                let cityMatches = city.localizedCaseInsensitiveContains(searchText)
                
                let pinMatches = viewModel.pinRepository.user?.pins?.contains { pin in
                    pin.city == city &&
                        (pin.name.localizedCaseInsensitiveContains(searchText) ||
                         pin.country.localizedCaseInsensitiveContains(searchText) ||
                         pin.notes.localizedCaseInsensitiveContains(searchText) ||
                         pin.type.localizedCaseInsensitiveContains(searchText))
                } == true
                
                return cityMatches || pinMatches
            }
        }
    }
}
