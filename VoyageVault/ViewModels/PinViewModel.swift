//
//  PinViewModel.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/2/23.
//

import Foundation
import Combine

class PinViewModel: ObservableObject {

    @Published var pinsForCity: [Pin] = []
    var city: String
    
    private var pinRepository = PinRepository.shared
    private var cancellables: Set<AnyCancellable> = []

    init(city: String) {
        self.city = city
        
        pinRepository.$user
            .compactMap { $0?.pins }
            .map { pins in
                pins.filter { $0.city == city }
            }
            .assign(to: \.pinsForCity, on: self)
            .store(in: &cancellables)
    }
}
