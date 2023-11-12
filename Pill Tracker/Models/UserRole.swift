//
//  UserRole.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import Foundation

enum UserRole: String, CaseIterable, Codable {
    case doctor = "Doctor"
    case nurse = "Nurse"
    case patient = "Patient"
}
