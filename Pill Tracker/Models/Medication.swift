//
//  Medication.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import Foundation

enum DosageUnit: String, CaseIterable, Identifiable, Codable {
    case mg = "mg"
    case μg = "μg"
    case ml = "ml"
    case IU = "IU"
    case tablets = "tablets"
    
    var id: String { self.rawValue }
}

enum MedicationState: String, Identifiable, Codable {
    case active
    case paused
    
    var id: String { self.rawValue }
}

struct Medication: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var dosage: String
    var dosageUnit: DosageUnit
    var forDisease: String
    var reminders: [MedicationReminder]
    var frequency: Int // Frequency of taking the medication
    var startDate: TimeInterval // Start date of the medication course
    var endDate: TimeInterval
    var medicationState: MedicationState // Add this property for medication state
    // Add more properties as needed

    init(id: UUID, name: String, dosage: String, dosageUnit: DosageUnit, forDisease: String, reminders: [MedicationReminder], frequency: Int, startDate: TimeInterval, endDate: TimeInterval, medicationState: MedicationState) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.dosageUnit = dosageUnit
        self.forDisease = forDisease
        self.reminders = reminders
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.medicationState = medicationState
    }

    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let name = dictionary["name"] as? String,
              let dosage = dictionary["dosage"] as? String,
              let forDisease = dictionary["forDisease"] as? String,
              let remindersArray = dictionary["reminders"] as? [[String: Any]], // Use [[String: Any]] type
              let frequency = dictionary["frequency"] as? Int,
              let startDateTimestamp = dictionary["startDate"] as? TimeInterval,
              let endDateTimestamp = dictionary["endDate"] as? TimeInterval
        else {
            return nil
        }

        self.id = UUID(uuidString: id) ?? UUID()
        self.name = name
        self.dosage = dosage
        self.dosageUnit = DosageUnit(rawValue: dictionary["dosageUnit"] as? String ?? "") ?? .mg
        self.forDisease = forDisease
        
        self.medicationState = MedicationState(rawValue: dictionary["medicationState"] as? String ?? "") ?? .paused
        
        
        // Decode the reminders array directly
        self.reminders = remindersArray.compactMap { reminderDict in
            guard let reminderData = try? JSONSerialization.data(withJSONObject: reminderDict),
                  let reminder = try? JSONDecoder().decode(MedicationReminder.self, from: reminderData)
            else {
                return nil
            }
            return reminder
        }
        
        self.frequency = frequency
        self.startDate = startDateTimestamp
        self.endDate = endDateTimestamp
    }
}

struct MedicationReminder: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var doseTime: TimeInterval
    var isTaken: Bool
    var isVerified: Bool
}
