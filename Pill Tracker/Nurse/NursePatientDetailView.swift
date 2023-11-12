//
//  NursePatientDetailView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 8/8/23.
//
import SwiftUI
import Firebase

struct NursePatientDetailView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    @Binding var patient: Patient

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            NavigationLink(destination: NurseMedicationsView(firebaseManager: firebaseManager)) {
                Text("View Medication History")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                            .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                    )
                    .foregroundColor(.white)
            }
            
            NavigationLink(destination: NurseVitalsHistoryView(firebaseManager: firebaseManager)) {
                Text("View Vitals")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                            .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                    )
                    .foregroundColor(.white)
            }
            
            NavigationLink(destination: NurseGenerateReportView(firebaseManager: firebaseManager)) {
                Text("Generate Report")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green)
                            .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                    )
            }
            
            VStack {
                Text("Doctor's Notes for this Patient:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(firebaseManager.selectedPatient.notes)
                    .padding()
                    .foregroundColor(.primary)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.vertical, 5)
                    .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .frame(width: .infinity)
        }
        .padding()
        .frame(maxHeight: .infinity)
        .navigationBarTitle("Patient Details")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            firebaseManager.selectedPatient = patient
            firebaseManager.setupSelectedPatientListener()
        }
    }
}


struct NursePatientDetailView_Previews: PreviewProvider {
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
        NursePatientDetailView(firebaseManager: FirebaseManager(), patient: .constant(samplePatient))
    }
}

