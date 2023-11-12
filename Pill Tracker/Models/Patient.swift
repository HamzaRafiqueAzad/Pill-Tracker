//
//  Patient.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import Foundation

struct Patient: Identifiable, Codable {
    var id: String
    let email: String
    let name: String
    let contactNumber: String
    var assignedNurseID: String // Reference to the assigned nurse's ID
    var assignedNurseName: String
    var medications: [Medication] // Array of medication history entries
    var vitals: [Vital]
    var doctorSpecializations: [DoctorSpecialization] // Array of allowed doctor specializations
    var notes: String
    // Add more properties specific to patients
    
    init(id: String, email: String, name: String, contactNumber: String, assignedNurseID: String, assignedNurseName: String, medications: [Medication], vitals: [Vital], doctorSpecializations: [DoctorSpecialization], notes: String) {
        self.id = id
        self.email = email
        self.name = name
        self.contactNumber = contactNumber
        self.assignedNurseID = assignedNurseID
        self.assignedNurseName = assignedNurseID
        self.medications = medications
        self.vitals = vitals
        self.doctorSpecializations = doctorSpecializations
        self.notes = notes
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
        self.assignedNurseID = dictionary["assignedNurseID"] as? String ?? ""
        self.assignedNurseName = dictionary["assignedNurseName"] as? String ?? ""
        self.medications = []
        self.vitals = []
        self.notes = dictionary["notes"] as? String ?? ""
        
        if let meds = dictionary["medications"] as? [[String: Any]] {
            self.medications = meds.compactMap { Medication(dictionary: $0) }
        }
        
        if let vits = dictionary["vitals"] as? [[String: Any]] {
            self.vitals = vits.compactMap { Vital(dictionary: $0) }
        }
        
        if let specializationStrings = dictionary["doctorSpecializations"] as? [String] {
            let doctorSpecializations = specializationStrings.compactMap { specializationString -> DoctorSpecialization? in
                return DoctorSpecialization(rawValue: specializationString)
            }
            self.doctorSpecializations = doctorSpecializations
        } else {
            self.doctorSpecializations = []
        }
    }
}
