//
//  Nurse.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import Foundation

struct Nurse: Identifiable, Codable, Hashable {
    let id: String
    let email: String
    let name: String
    let contactNumber: String
    var isAvailable: Bool = false
    var patients: [String]
    // Add more properties specific to nurses
    
    init(id: String, email: String, name: String, contactNumber: String, isAvailable: Bool, patients: [String]) {
        self.id = id
        self.email = email
        self.name = name
        self.contactNumber = contactNumber
        self.isAvailable = isAvailable
        self.patients = patients
    }
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let email = dictionary["email"] as? String,
              let name = dictionary["name"] as? String,
              let contactNumber = dictionary["contactNumber"] as? String,
              let isAvailable = dictionary["isAvailable"] as? Bool
        else {
            return nil
        }
        
        self.id = id
        self.email = email
        self.name = name
        self.contactNumber = contactNumber
        self.isAvailable = isAvailable
        self.patients = dictionary["patients"] as? [String] ?? []
    }
}
