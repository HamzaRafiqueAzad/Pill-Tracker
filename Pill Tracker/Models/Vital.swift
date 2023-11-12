//
//  Vital.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import Foundation

enum VitalType: String, CaseIterable, Codable {
    case heartRate = "Heart Rate"
    case bloodPressure = "Blood Pressure"
    case bloodSugar = "Blood Sugar"
    // Add more vital types as needed
}

struct Vital: Identifiable, Codable, Hashable {
    var id: UUID
    var type: VitalType
    var value: Double
    var date: TimeInterval
    // Add more properties as needed
    // ...
    
    init(id: UUID, type: VitalType, value: Double, date: TimeInterval) {
        self.id = id
        self.type = type
        self.value = value
        self.date = date
    }
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let typeRawValue = dictionary["type"] as? String,
              let type = VitalType(rawValue: typeRawValue),
              let value = dictionary["value"] as? Double,
              let date = dictionary["date"] as? TimeInterval
        else {
            return nil
        }
        
        self.id = UUID(uuidString: id) ?? UUID()
        self.type = type
        self.value = value
        self.date = date
    }
}
