//
//  CityViewModel.swift
//  VoyageVault
//
//  Created by Om Patel on 12/8/23.
//

import Foundation
import Combine

class CityListViewModel: ObservableObject {
    static let shared = CityListViewModel()
    
    @Published var cities: [String: Int] = [:]
    @Published var sortedCities: [String] = []
    @Published var pinRepository = PinRepository.shared
    @Published var selectedSortOption: HistoryView.FilterOption? {
        didSet {
            if let option = selectedSortOption {
                sortCities(option: option)
            }
        }
    }
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        pinRepository.$user
            .compactMap { $0?.pins }
            .map { pins in
                Dictionary(grouping: pins, by: { $0.city })
            }
            .map { cityToPins in
                var cityToPinCount: [String: Int] = [:]
                for (city, pins) in cityToPins {
                    cityToPinCount[city] = pins.count
                }
                return cityToPinCount
            }
            .assign(to: \.cities, on: self)
            .store(in: &cancellables)
    }
    
    private func latestPinDate(for city: String) -> Date {
        // Implement logic to get the latest pin date for the given country
        // You can use pinRepository.user?.pins to get the pins for the user
        // and then filter by country to find the latest date
        // For simplicity, let's assume there's a function getLatestPinDate(country: String) in PinRepository
        return pinRepository.getLatestPinDateForCity(city: city) ?? Date.distantPast
    }
    
    func sortCities(option: HistoryView.FilterOption) {
        switch option {
        case .nameAscending:
            print("sorted prior", sortedCities)
            sortedCities = cities.keys.sorted()
            print("sorted after", sortedCities)
        case .nameDescending:
            print("sorted prior", sortedCities)
            sortedCities = cities.keys.sorted().reversed()
            print("sorted after", sortedCities)
        case .dateAscending:
            sortedCities = cities.keys.sorted {
                city1, city2 in
                let date1 = latestPinDate(for: city1)
                let date2 = latestPinDate(for: city2)
                return date1 < date2
            }
        case .dateDescending:
            sortedCities = cities.keys.sorted {
                city1, city2 in
                let date1 = latestPinDate(for: city1)
                let date2 = latestPinDate(for: city2)
                return date1 > date2
            }
        }
    }
}
