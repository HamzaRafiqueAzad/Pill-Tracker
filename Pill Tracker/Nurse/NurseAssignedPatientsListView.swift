//
//  AssignedPatientsListView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 6/8/23.
//

import SwiftUI
import Firebase

struct NurseAssignedPatientsListView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    
    @Binding var patients: [Patient]
    
    var body: some View {
        ScrollView {
            ForEach(patients.indices, id: \.self) { index in
                let binding = Binding(
                    get: { patients[index] },
                    set: { patients[index] = $0 }
                )
                NavigationLink(destination: NursePatientDetailView(firebaseManager: firebaseManager, patient: binding)) {
                    NursePatientCard(patient: binding)
                        .listRowBackground(Color.clear)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                                .shadow(color: Color.white.opacity(0.7), radius: 5, x: -5, y: -5)
                        )
                        .padding(.vertical, 8)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
}

struct NurseAssignedPatientsListView_Previews: PreviewProvider {
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
        NurseAssignedPatientsListView(firebaseManager: FirebaseManager(), patients: .constant([samplePatient]))
    }
}
