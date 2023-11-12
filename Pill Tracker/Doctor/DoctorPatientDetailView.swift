//
//  PatientDetailView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import SwiftUI

struct DoctorPatientDetailView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    
    @State var patient: Patient
    
    @State private var isAssigningSpecialization = false
    
    @State private var patientNotes = ""
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Patient Details")
                    .font(.title)
                    .bold()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Name:")
                        .font(.headline)
                    Text(firebaseManager.selectedPatient.name)
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Email:")
                        .font(.headline)
                    Text(firebaseManager.selectedPatient.email)
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Contact Number:")
                        .font(.headline)
                    Text(firebaseManager.selectedPatient.contactNumber)
                        .font(.subheadline)
                }
                
                Divider()
                
                if firebaseManager.loggedInDoctor.specialization == .medicalSpecialist {
                    Button("Assign Diseases", action: {
                        isAssigningSpecialization.toggle()
                    })
                    .sheet(isPresented: $isAssigningSpecialization) {
                        DoctorAssignSpecialistView(firebaseManager: firebaseManager)
                    }
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                            .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                    )
                    
                    NavigationLink(destination: DoctorManageMedicationsView(firebaseManager: firebaseManager)) {
                        Text("Manage Medications")
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
                    
                } else {
                    HStack {
                        Spacer()
                        if firebaseManager.loggedInDoctor.patients.contains(firebaseManager.selectedPatient.id) {
                            VStack(spacing: 20) {
                                
                                Button {
                                    firebaseManager.loggedInDoctor.patients.removeAll(where: { $0 == firebaseManager.selectedPatient.id })
                                    firebaseManager.updateDoctor(firebaseManager.loggedInDoctor) { err in
                                        if err == nil {
                                            
                                        } else {
                                            // If an error occurs:
                                            showErrorAlert = true
                                            errorMessage = "Failed to save data. Please try again."
                                        }
                                    }
                                } label: {
                                    Text("Unassign")
                                        .font(.headline)
                                        .padding()
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.blue)
                                                .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                                        )
                                }
                                
                                NavigationLink(destination: DoctorPatientMedicationHistoryView(firebaseManager: firebaseManager)) {
                                    Text("View Medication and Vitals History")
                                        .font(.headline)
                                        .padding()
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color.blue)
                                                .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                                        )
                                }
                                
                                NavigationLink(destination: DoctorManageMedicationsView(firebaseManager: firebaseManager)) {
                                    Text("Manage Medications")
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
                                
                                NavigationLink(destination: DoctorGenerateReportView(firebaseManager: firebaseManager)) {
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
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 10) {
//                                    Text("Patient Notes:")
//                                        .font(.headline)
//                                    TextEditor(text: $patientNotes)
//                                        .font(.subheadline)
                                    
                                    Text("Notes for Nurse about this Patient:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    TextEditor(text: $patientNotes)
                                        .padding(10)
                                        .cornerRadius(20)
//                                        .background(Color.red)
                                        .foregroundColor(.primary)
                                        .font(.body)
                                    
                                    Button("Save Patient Notes", action: {
                                        updatePatientNotes()
                                    })
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
                            }
                        } else {
                            
                            Button {
                                firebaseManager.loggedInDoctor.patients.append(firebaseManager.selectedPatient.id)
                                firebaseManager.updateDoctor(firebaseManager.loggedInDoctor) { err in
                                    if err == nil {
                                        
                                    } else {
                                        // If an error occurs:
                                        showErrorAlert = true
                                        errorMessage = "Failed to save data. Please try again."
                                    }
                                }
                            } label: {
                                Text("Assign to Me")
                                    .font(.headline)
                                    .padding()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.blue)
                                            .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                                    )
                            }
                        }
                    }
                }

            }
            .padding()
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle(firebaseManager.selectedPatient.name)
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
            firebaseManager.selectedPatient = patient
            patientNotes = patient.notes
            firebaseManager.setupSelectedPatientListener()
        }
        .onDisappear() {
           UITextView.appearance().backgroundColor = nil
         }
    }
    
    private func updatePatientNotes() {
        firebaseManager.selectedPatient.notes = patientNotes
        firebaseManager.updatePatient(firebaseManager.selectedPatient) { error in
            if error == nil {
                // Successfully updated patient notes
            } else {
                print("Error updating patient notes: \(error?.localizedDescription ?? "")")
            }
        }
    }
}

struct DoctorPatientDetailView_Previews: PreviewProvider {
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
        DoctorPatientDetailView(firebaseManager: FirebaseManager(), patient: samplePatient)
    }
}
