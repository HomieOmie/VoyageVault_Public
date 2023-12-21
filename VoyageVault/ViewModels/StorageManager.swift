//
//  StorageManager.swift
//  VoyageVault
//
//  Created by Deep Chandra on 06/11/2023.
//

import Foundation
import FirebaseStorage

class StorageManager {
  
  static let shared = StorageManager()
  
  private init() {}
  
  private let storage = Storage.storage().reference()
  
  private func storagePinReference(userId: String, pinId: String) -> StorageReference {
    storage.child("users").child(userId).child(pinId)
  }
  
  func getUrlForImage(path: String) async throws -> URL {
    try await storage.child(path).downloadURL()
  }
  
  func getImageData(path: String) async throws -> Data? {
    return try await withCheckedThrowingContinuation { continuation in
      storage.child(path).getData(maxSize: 5 * 1024 * 1024) { data, error in
        if let error = error {
          print("getImageData Error: \(error)")
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: data)
        }
      }
    }
  }
  
  func saveImage(data: Data, userId: String?, pinId: String) async throws -> String {
    let meta = StorageMetadata()
    meta.contentType = "image/jpeg"
    
    let fileName = "\(UUID().uuidString).jpeg"
    let resolvedUserId = userId ?? "defaultUserId"
    let returnedMetaData = try await storagePinReference(userId: resolvedUserId, pinId: pinId).child(fileName).putDataAsync(data, metadata: meta)
    
    guard let returnedPath = returnedMetaData.path else {
      throw URLError(.badServerResponse)
    }
    
    return returnedPath
  }
  
  func deleteImage(path: String) async throws {
    storage.child(path).delete { error in
      if let error = error {
        print("Error deleting image: \(error)")
      } else {
        print("File deleted successfully")
      }
    }
  }
}
