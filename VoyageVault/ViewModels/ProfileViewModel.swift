//
//  ProfileViewModel.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/27/23.
//

import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var totalPins: Int = 0
    @Published var uniqueCountries: Int = 0
    @Published var uniqueCities: Int = 0
    @Published var favoriteCity: String = ""
    @Published var mostFrequentSeason: String = ""
    @Published var topTravelerPercentage: String = ""
    @Published var mostSouthernPoint: String = ""
    @Published var mostNorthernPoint: String = ""
    @Published var uniqueContinents: Int = 0
    @Published var mostCommonPinType: String = ""
    private var pinRepository = PinRepository.shared
    private var cancellables = Set<AnyCancellable>()
    
    var currentUser: DBUser? {
        pinRepository.user
    }
    
    init() {
        // Subscribe to user changes in the repository
        pinRepository.$user
            .sink { [weak self] _ in
                self?.calculateStatistics()
            }
            .store(in: &cancellables)
        
        calculateStatistics() // Initial calculation
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    
    private func calculateStatistics() {
        totalPins = pinRepository.user?.pins?.count ?? 0
        uniqueCountries = calculateUniqueCountries()
        uniqueCities = calculateUniqueCities()
        favoriteCity = calculateFavoriteCity()
        mostFrequentSeason = calculateMostFrequentSeason()
        topTravelerPercentage = calculateTopTravelerPercentage()
        mostSouthernPoint = calculateMostSouthernPoint()
        mostNorthernPoint = calculateMostNorthernPoint()
        uniqueContinents = calculateUniqueContinents()
        mostCommonPinType = calculateMostCommonPinType()
    }
    
    private func calculateUniqueCountries() -> Int {
        let countries = pinRepository.user?.pins?.map { $0.country }
        return Set(countries ?? []).count
    }
    
    private func calculateUniqueCities() -> Int {
        let cities = pinRepository.user?.pins?.map { $0.city }
        return Set(cities ?? []).count
    }
    
    private func calculateFavoriteCity() -> String {
        let cityFrequency = Dictionary(grouping: pinRepository.user?.pins ?? [], by: { $0.city })
        if let mostCommonCity = cityFrequency.max(by: { $0.value.count < $1.value.count })?.key {
            return mostCommonCity
        }
        return "N/A"
    }
    
    private func calculateMostFrequentSeason() -> String {
        let seasonCount = pinRepository.user?.pins?.reduce(into: [String: Int]()) { counts, pin in
            let season = season(for: pin.datetime ?? Date())
            counts[season, default: 0] += 1
        }
        return seasonCount?.max(by: { $0.value < $1.value })?.key ?? "N/A"
    }
    
    private func season(for date: Date) -> String {
        let month = Calendar.current.component(.month, from: date)
        switch month {
        case 3...5: return "Spring"
        case 6...8: return "Summer"
        case 9...11: return "Fall"
        default: return "Winter"
        }
    }
    
    private func calculateTopTravelerPercentage() -> String {
        let basePercentile: Int = 95
        
        let pinFactor = totalPins * 2
        let countryFactor = uniqueCountries * 5
        let cityFactor = uniqueCities * 3

        let reduction = pinFactor + countryFactor + cityFactor        
        let finalPercentile = max(basePercentile - reduction, 5)

        return "\(finalPercentile)%"
    }


    
    private func calculateMostSouthernPoint() -> String {
        guard let pins = pinRepository.user?.pins, !pins.isEmpty else { return "N/A" }
        if let southernmostPin = pins.min(by: { $0.coordinates.latitude < $1.coordinates.latitude }) {
            return "\(southernmostPin.city), \(southernmostPin.country)"
        }
        return "N/A"
    }
    
    private func calculateMostNorthernPoint() -> String {
        guard let pins = pinRepository.user?.pins, !pins.isEmpty else { return "N/A" }
        if let northernmostPin = pins.max(by: { $0.coordinates.latitude < $1.coordinates.latitude }) {
            return "\(northernmostPin.city), \(northernmostPin.country)"
        }
        return "N/A"
    }
    
    private func calculateUniqueContinents() -> Int {
        guard let pins = pinRepository.user?.pins else { return 0 }
        let continents = pins.compactMap { continent(forCountry: $0.country) }
        return Set(continents).count
    }
    
    private func continent(forCountry country: String) -> String {
        let continents = [
            "North America": [
                "Antigua and Barbuda", "Bahamas", "Barbados", "Belize", "Canada",
                "Costa Rica", "Cuba", "Dominica", "Dominican Republic", "El Salvador",
                "Grenada", "Guatemala", "Haiti", "Honduras", "Jamaica",
                "Mexico", "Nicaragua", "Panama", "Saint Kitts and Nevis", "Saint Lucia",
                "Saint Vincent and the Grenadines", "Trinidad and Tobago", "United States",
            ],
            
            "South America": [
                "Argentina", "Bolivia", "Brazil", "Chile", "Colombia",
                "Ecuador", "Guyana", "Paraguay", "Peru", "Suriname",
                "Uruguay", "Venezuela"
            ],
            
            "Europe": [
                "Albania", "Andorra", "Austria", "Belarus", "Belgium",
                "Bosnia and Herzegovina", "Bulgaria", "Croatia", "Cyprus", "Czech Republic",
                "Denmark", "Estonia", "Finland", "France", "Germany",
                "Greece", "Hungary", "Iceland", "Ireland", "Italy",
                "Kosovo", "Latvia", "Liechtenstein", "Lithuania", "Luxembourg",
                "Malta", "Moldova", "Monaco", "Montenegro", "Netherlands",
                "North Macedonia", "Norway", "Poland", "Portugal", "Romania",
                "Russia", "San Marino", "Serbia", "Slovakia", "Slovenia",
                "Spain", "Sweden", "Switzerland", "Ukraine", "United Kingdom",
                "Vatican City"
            ],
            
            "Africa": [
                "Algeria", "Angola", "Benin", "Botswana", "Burkina Faso",
                "Burundi", "Cabo Verde", "Cameroon", "Central African Republic", "Chad",
                "Comoros", "Congo (Brazzaville)", "Congo (Kinshasa)", "Cote d'Ivoire", "Djibouti",
                "Egypt", "Equatorial Guinea", "Eritrea", "Eswatini", "Ethiopia",
                "Gabon", "Gambia", "Ghana", "Guinea", "Guinea-Bissau",
                "Kenya", "Lesotho", "Liberia", "Libya", "Madagascar",
                "Malawi", "Mali", "Mauritania", "Mauritius", "Morocco",
                "Mozambique", "Namibia", "Niger", "Nigeria", "Rwanda",
                "Sao Tome and Principe", "Senegal", "Seychelles", "Sierra Leone", "Somalia",
                "South Africa", "South Sudan", "Sudan", "Tanzania", "Togo",
                "Tunisia", "Uganda", "Zambia", "Zimbabwe"
            ],
            
            "Asia": [
                "Afghanistan", "Armenia", "Azerbaijan", "Bahrain", "Bangladesh",
                "Bhutan", "Brunei", "Cambodia", "China", "Cyprus",
                "Georgia", "India", "Indonesia", "Iran", "Iraq",
                "Israel", "Japan", "Jordan", "Kazakhstan", "Kuwait",
                "Kyrgyzstan", "Laos", "Lebanon", "Malaysia", "Maldives",
                "Mongolia", "Myanmar", "Nepal", "North Korea", "Oman",
                "Pakistan", "Palestine", "Philippines", "Qatar", "Saudi Arabia",
                "Singapore", "South Korea", "Sri Lanka", "Syria", "Tajikistan",
                "Thailand", "Timor-Leste", "Turkey", "Turkmenistan", "United Arab Emirates",
                "Uzbekistan", "Vietnam", "Yemen"
            ],
            
            "Australia": [
                "Australia", "Fiji", "Kiribati", "Marshall Islands", "Micronesia",
                "Nauru", "New Zealand", "Palau", "Papua New Guinea", "Samoa",
                "Solomon Islands", "Tonga", "Tuvalu", "Vanuatu"
            ],
            
            "Antarctica": ["Antarctica"]
        ]
        
        for (continent, countries) in continents {
            if countries.contains(country) {
                return continent
            }
        }
        return "Unknown"
    }
    
    private func calculateMostCommonPinType() -> String {
        var typeCounts = [String: Int]()
        
        if let pins = pinRepository.user?.pins {
            for pin in pins {
                let type = pin.type
                if let count = typeCounts[type] {
                    typeCounts[type] = count + 1
                } else {
                    typeCounts[type] = 1
                }
            }
        }
        
        if let mostCommonType = typeCounts.max(by: { $0.value < $1.value })?.key {
            print("Most common pin type: \(mostCommonType)")
            return mostCommonType
        }
        
        return "N/A"
    }
}
