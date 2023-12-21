//
//  CityListView.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/4/23.
//

import Foundation
import SwiftUI

struct CountryCityListView: View {
    @ObservedObject var viewModel: CountryCityViewModel
    var country: String
    
    @State private var searchText = ""
    
    let backgroundColor = Color(red: 248/255, green: 233/255, blue: 223/255)
    let textColor = Color(red: 199/255, green: 92/255, blue: 0)
    
    init(country: String) {
        self.country = country
        self.viewModel = CountryCityViewModel(country: country)
        
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
        .navigationBarTitle("Cities in \(country)")
        .searchable(text: $searchText)
        .listStyle(PlainListStyle())
    }
    private var filteredCities: [String] {
        if searchText.isEmpty {
            return viewModel.cities.keys.sorted()
        }
        else {
            return viewModel.cities.keys.filter { $0.localizedCaseInsensitiveContains(searchText) }.sorted()
        }
    }
}
