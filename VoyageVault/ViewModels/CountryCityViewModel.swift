//
//  CityViewModel.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/4/23.
//

import Foundation
import Combine

class CountryCityViewModel: ObservableObject {
    
    @Published var cities: [String: Int] = [:]
    
    private var pinRepository = PinRepository.shared
    private var cancellables: Set<AnyCancellable> = []
    
    init(country: String) {
        
        pinRepository.$user
            .compactMap { $0?.pins }
            .map { pins in
                pins.filter { $0.country == country }
            }
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
}
