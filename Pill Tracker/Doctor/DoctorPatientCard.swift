//
//  PatientCard.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import SwiftUI

struct DoctorPatientCard: View {
    @ObservedObject var firebaseManager: FirebaseManager

    var patient: Patient
    var buttonText: String?
    var assignPatient: (Patient) -> Void // Function to assign a patient

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 15) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.blue.opacity(0.2), radius: 5, x: 2, y: 2)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(patient.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Contact Number: \(patient.contactNumber)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                    
                    Text("\(patient.medications.count) Medication/s Assigned")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                    
                    if patient.assignedNurseName != "" {
                        Text("Assigned Nurse: \(patient.assignedNurseName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                if let buttonText = buttonText {
                    Button(action: { assignPatient(patient) }) {
                        Text(buttonText)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                            .shadow(radius: 2)
                    }
                } else {
                    Image(systemName: "chevron.right.circle")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
        )
        .padding(.vertical, 5)
        .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct DoctorPatientCard_Previews: PreviewProvider {
    static var previews: some View {
        let medications = [
            Medication(id: UUID(), name: "Medication 1", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active),
            Medication(id: UUID(), name: "Medication 2", dosage: "5mg", dosageUnit: .mg, forDisease: "", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active)
            // Add more sample medication history entries
        ]
        
        let sampleVitals: [Vital] = [
            Vital(id: UUID(), type: .heartRate, value: 75, date: Date().timeIntervalSince1970),
            Vital(id: UUID(), type: .bloodPressure, value: 120/80, date: Date().timeIntervalSince1970),
            Vital(id: UUID(), type: .bloodSugar, value: 100, date: Date().timeIntervalSince1970)
            // Add more sample vitals data if needed
        ]
        
        let samplePatient = Patient(id: "uid", email: "patient@gmail.com", name: "Patient Doe", contactNumber: "123-456-7890", assignedNurseID: "", assignedNurseName: "", medications: medications,vitals: sampleVitals, doctorSpecializations: [], notes: "")
        DoctorPatientCard(firebaseManager: FirebaseManager(), patient: samplePatient, buttonText: "Assign", assignPatient: { _ in })
    }
}
