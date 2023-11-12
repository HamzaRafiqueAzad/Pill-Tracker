//
//  Doctor.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import Foundation

enum DoctorSpecialization: String, CaseIterable, Identifiable, Codable {
    case medicalSpecialist = "Medical Specialist"
    case heartSpecialist = "Heart Specialist"
    case brainSpecialist = "Brain Specialist"
    case orthopedicSurgeon = "Orthopedic Surgeon"
    case dermatologist = "Dermatologist"
    case pediatrician = "Pediatrician"
    case ophthalmologist = "Opthalmologist"
    // Add more specializations as needed
    
    var id: String { self.rawValue }
}

struct Doctor: Codable {
    let id: String
    let email: String
    let name: String
    let contactNumber: String
    var specialization: DoctorSpecialization
    var nurses: [String]
    var patients: [String]
    // Add more properties specific to doctors
    init(id: String, email: String, name: String, contactNumber: String, specialization: DoctorSpecialization, nurses: [String], patients: [String]) {
        self.id = id
        self.email = email
        self.name = name
        self.contactNumber = contactNumber
        self.nurses = nurses
        self.patients = patients
        self.specialization = specialization
    }
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let email = dictionary["email"] as? String,
              let name = dictionary["name"] as? String,
              let contactNumber = dictionary["contactNumber"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.email = email
        self.name = name
        self.contactNumber = contactNumber
        self.specialization = DoctorSpecialization(rawValue: dictionary["specialization"] as? String ?? "") ?? .medicalSpecialist
        self.nurses = dictionary["nurses"] as? [String] ?? []
        self.patients = dictionary["patients"] as? [String] ?? []
    }
}
