//
//  AllPinsViewModel.swift
//  VoyageVault
//
//  Created by Om Patel on 12/8/23.
//

import Foundation
import Combine

class AllPinsViewModel: ObservableObject {
    static let shared = AllPinsViewModel()  // Singleton instance

    @Published var allPins: [Pin] = []
    @Published var sortedPins: [Pin] = []
    @Published var selectedSortOption: HistoryView.FilterOption? {
        didSet {
            if let option = selectedSortOption {
                sortPins(option: option)
            }
        }
    }

    private var pinRepository = PinRepository.shared
    private var cancellables: Set<AnyCancellable> = []

    private init() {
        pinRepository.$user
            .compactMap { $0?.pins }
            .assign(to: \.allPins, on: self)
            .store(in: &cancellables)
    }

    func sortPins(option: HistoryView.FilterOption) {
        switch option {
        case .nameAscending:
            sortedPins = allPins.sorted { $0.name < $1.name }
        case .nameDescending:
            sortedPins = allPins.sorted { $0.name > $1.name }
        case .dateAscending:
            sortedPins = allPins.sorted { $0.datetime ?? Date.distantPast < $1.datetime ?? Date.distantPast }
        case .dateDescending:
            sortedPins = allPins.sorted { $0.datetime ?? Date.distantPast > $1.datetime ?? Date.distantPast }
        }
    }
}
