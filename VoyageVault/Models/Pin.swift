//
//  Pin.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/2/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Pin: Identifiable, Comparable, Codable, Hashable {
    var id: String
    var name: String
    var coordinates: GeoPoint
    @ServerTimestamp var datetime: Date?
    var notes: String
    var type: String
    var city: String
    var country: String
    var image: String?
    
    static func ==(lhs: Pin, rhs: Pin) -> Bool {
        return lhs.country == rhs.country && lhs.city == rhs.city && lhs.name == rhs.name
    }
    
    static func <(lhs: Pin, rhs: Pin) -> Bool {
        if lhs.country != rhs.country { return lhs.country < rhs.country }
        else if lhs.city != rhs.city { return lhs.city < rhs.city }
        else { return lhs.name < rhs.name }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}


// To convert Pin to a dictionary for easier Firestore interaction.
extension Pin: DictionaryRepresentable {
    var dictionary: [String: Any] {
        let data: [String: Any?] = [
            "id": id,
            "name": name,
            "coordinates": GeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude),
            "datetime": datetime,
            "notes": notes,
            "type": type,
            "city": city,
            "country": country,
            "image": image
        ]
        return data.compactMapValues { $0 }
    }
}

protocol DictionaryRepresentable {
    var dictionary: [String: Any] { get }
}
