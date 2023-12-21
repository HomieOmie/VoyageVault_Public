//
//  User.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/3/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct DBUser: Codable, Equatable{
  let userId: String
  let name: String?
  let email: String?
  let photoUrl: String?
  let dateCreated: Date?
  var pins: [Pin]?
  
  init(auth: AuthDataResultModel) {
    self.userId = auth.uid
    self.name = auth.name
    self.email = auth.email
    self.photoUrl = auth.photoUrl
    self.dateCreated = Date()
    self.pins = auth.pins
  }
  
  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case name = "name"
    case email = "email"
    case photoUrl = "photo_url"
    case dateCreated = "date_created"
    case pins = "pins"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.userId = try container.decode(String.self, forKey: .userId)
    self.name = try container.decodeIfPresent(String.self, forKey: .name)
    self.email = try container.decodeIfPresent(String.self, forKey: .email)
    self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
    self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
    self.pins = try container.decodeIfPresent([Pin].self, forKey: .pins)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.userId, forKey: .userId)
    try container.encodeIfPresent(self.name, forKey: .name)
    try container.encodeIfPresent(self.email, forKey: .email)
    try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
    try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    try container.encodeIfPresent(self.pins, forKey: .pins)
  }
    
  static func == (lhs: DBUser, rhs: DBUser) -> Bool {
    return lhs.userId == rhs.userId &&
        lhs.name == rhs.name &&
        lhs.email == rhs.email &&
        lhs.photoUrl == rhs.photoUrl &&
        lhs.dateCreated == rhs.dateCreated &&
        lhs.pins == rhs.pins
  }
}
