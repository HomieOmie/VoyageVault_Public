//
//  PinRepository.swift
//  VoyageVault
//
//  Created by Matthew Leboffe on 11/2/23.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage


final class PinRepository: ObservableObject {
    static let shared = PinRepository()
    
    // Firestore path and references
    private let path: String = "users"
    internal var db = Firestore.firestore()
    private var userRef: DocumentReference?
    
    @Published var user: DBUser?
    private var cancellables: Set<AnyCancellable> = []
    
    private var userListener: ListenerRegistration?
    
    internal init() {
        // Load current user and set up listener for pins
        Task {
            print("HIT")
            await self.loadCurrentUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.listenForPinChanges()
                print("Now Listening")
            }
        }
    }
    
    private func listenForPinChanges() {
        print(self.userRef)
        guard let userRef = self.userRef else {
            print("User reference is not set.")
            return
        }
        
        // Remove previous listener if it exists
        userListener?.remove()
        
        // Listening to changes
        userListener = userRef.addSnapshotListener { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                do {
                    let fetchedUser = try document.data(as: DBUser.self)
                    DispatchQueue.main.async {
                        self.user = fetchedUser
                    }
                } catch {
                    print("Error decoding user: \(error)")
                }
            } else if let error = error {
                print("Error fetching document: \(error)")
            }
        }
    }
    
    deinit {
        // Remove listener when this object is deinitialized
        userListener?.remove()
    }
    
    private func loadCurrentUser() async {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            let fetchedUser = try await UserManager.shared.getUser(userId: authDataResult.uid)
            let userRef = db.collection(path).document(authDataResult.uid)
            // Dispatching the update to the main thread
            DispatchQueue.main.async {
                self.user = fetchedUser
                self.userRef = userRef
            }
            print("FInished")
        } catch {
            print("Error loading current user: \(error)")
        }
    }
    
    
    // Retrieves all pins for the current user from Firestore
    func getAllPins() {
        guard let userRef = self.userRef else {
            print("User reference is not set.")
            return
        }
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let fetchedUser = try document.data(as: DBUser.self)
                    DispatchQueue.main.async {
                        self.user = fetchedUser
                        print("Data fetched in PinRepository: \(String(describing: self.user))")
                    }
                } catch {
                    print("Error decoding user: \(error)")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func createPin(_ pin: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userRef = self.userRef else {
            print("User reference is not set.")
            completion(.failure(NSError(domain: "PinRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User reference is not set."])))
            return
        }
        
        userRef.updateData([
            "pins": FieldValue.arrayUnion([pin])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updatePin(_ pin: [String: Any], originalPinId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userRef = self.userRef else {
            completion(.failure(NSError(domain: "PinRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User reference is not set."])))
            return
        }
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var existingPins = document.data()?["pins"] as? [[String: Any]] ?? []
                
                // Remove the old pin
                existingPins.removeAll { $0["id"] as? String == originalPinId }
                
                // Add the updated pin
                existingPins.append(pin)
                
                // Update the document with the modified pins array
                userRef.updateData(["pins": existingPins]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NSError(domain: "PinRepository", code: -2, userInfo: [NSLocalizedDescriptionKey: "Document does not exist."])))
            }
        }
    }
    
    
    func deletePin(_ pin: Pin, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userRef = self.userRef else {
            completion(.failure(NSError(domain: "PinRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User reference is not set."])))
            return
        }
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var existingPins = document.data()?["pins"] as? [[String: Any]] ?? []
                
                // Remove the old pin
                existingPins.removeAll { $0["id"] as? String == pin.id }
                
                // Update the document with the modified pins array
                userRef.updateData(["pins": existingPins]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(NSError(domain: "PinRepository", code: -2, userInfo: [NSLocalizedDescriptionKey: "Document does not exist."])))
            }
        }
    }
    
    
    func getLatestPinDateForCountry(country: String) -> Date? {
        let pinsForCountry = getPinsForCountry(country)
        return pinsForCountry.max(by: { pin1, pin2 in
            if let date1 = pin1.datetime, let date2 = pin2.datetime {
                return date1 < date2
            }
            return false
        })?.datetime
    }
    
    func getLatestPinDateForCity(city: String) -> Date? {
        let pinsForCity = getPinsForCity(city)
        return pinsForCity.max(by: { pin1, pin2 in
            if let date1 = pin1.datetime, let date2 = pin2.datetime {
                return date1 < date2
            }
            return false
        })?.datetime
    }
    
    func getPinsForCountry(_ country: String) -> [Pin] {
        return (self.user?.pins ?? []).filter{$0.country == country}
    }
    
    func getPinsForCity(_ city: String) -> [Pin] {
        return (self.user?.pins ?? []).filter{$0.city == city}
    }
    
    func getPins() -> [Pin] {
        return self.user?.pins ?? []
    }
}
