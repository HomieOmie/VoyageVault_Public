//
//  CountryViewModel.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/4/23.
//

import Foundation
import Combine

class CountryViewModel: ObservableObject {
    static let shared = CountryViewModel()
    
    @Published var uniqueCountries: [String] = []
    @Published var sortedCountries: [String] = []
    @Published var pinRepository = PinRepository.shared
    @Published var selectedSortOption: HistoryView.FilterOption? {
        didSet {
            if let option = selectedSortOption {
                sortCountries(option: option)
            }
        }
    }
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        pinRepository.$user
            .compactMap { $0?.pins }
            .sink { [weak self] pins in
                let countries = pins.map { $0.country }
                self?.uniqueCountries = Array(Set(countries)).sorted()
            }
            .store(in: &cancellables)
    }
    
    private func latestPinDate(for country: String) -> Date {
        // Implement logic to get the latest pin date for the given country
        // You can use pinRepository.user?.pins to get the pins for the user
        // and then filter by country to find the latest date
        // For simplicity, let's assume there's a function getLatestPinDate(country: String) in PinRepository
        return pinRepository.getLatestPinDateForCountry(country: country) ?? Date.distantPast
    }
    
    func sortCountries(option: HistoryView.FilterOption) {
        switch option {
        case .nameAscending:
            sortedCountries = uniqueCountries.sorted()
        case .nameDescending:
            sortedCountries = uniqueCountries.sorted().reversed()
        // Add more cases for different sorting options if needed
        case .dateAscending:
            sortedCountries = uniqueCountries.sorted {
                country1, country2 in
                let date1 = latestPinDate(for: country1)
                let date2 = latestPinDate(for: country2)
                return date1 < date2
            }
        case .dateDescending:
            sortedCountries = uniqueCountries.sorted {
                country1, country2 in
                let date1 = latestPinDate(for: country1)
                let date2 = latestPinDate(for: country2)
                return date1 > date2
            }
        }
    }
}
