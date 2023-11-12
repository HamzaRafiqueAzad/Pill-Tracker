//
//  UnassignedPatientsListView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import SwiftUI
import Firebase

struct DoctorNursePatientsListView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var firebaseManager: FirebaseManager
    @State var nurse: Nurse // Nurse selected from NursesListView
    
    @State private var unassignedPatients: [Patient] = [] // Store unassigned patients here
    
    @State private var assignedPatients: [Patient] = [] // Store assigned patients here
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    
    var body: some View {
        ScrollView {
            Section(header: Text("Patients with no nurses").font(.headline).foregroundColor(.primary)) {
                if unassignedPatients.count != 0 {
                    ForEach(unassignedPatients, id: \.id) { patient in
                        DoctorPatientCard(firebaseManager: firebaseManager, patient: patient, buttonText: "Assign", assignPatient: assignPatient)
                            .listRowBackground(Color.clear)
                    }
                } else {
                    Text("No Patients Available To Assign.")
                        .foregroundColor(.secondary)
                    
                }
            }
            
            Section(header: Text("Patients assigned to this nurse").font(.headline).foregroundColor(.primary)) {
                if assignedPatients.count != 0 {
                    ForEach(assignedPatients, id: \.id) { patient in
                        DoctorPatientCard(firebaseManager: firebaseManager, patient: patient, buttonText: "Unassign", assignPatient: unassignPatient)
                            .listRowBackground(Color.clear)
                    }
                } else {
                    Text("No Patients Assigned To This Nurse.")
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
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
        .navigationBarTitle("Patients")
        .onAppear {
            fetchUnassignedPatients()
        }
    }
    
    func unassignPatient(_ patient: Patient) {
        // Update the patient's assignedNurseID to nil
        var updatedPatient = patient
        updatedPatient.assignedNurseID = ""
        updatedPatient.assignedNurseName = ""
        // Update the patient in the Realtime Database
        firebaseManager.updatePatient(updatedPatient) { err in
            if err != nil {
                updatedPatient.assignedNurseID = patient.assignedNurseID
                updatedPatient.assignedNurseName = patient.assignedNurseName
                return
            }
            
            // Update the nurse's patients list in the Realtime Database
            firebaseManager.updateNurse(nurse) { err in
                if err != nil {
                    updatedPatient.assignedNurseID = patient.assignedNurseID
                    updatedPatient.assignedNurseName = patient.assignedNurseName
                    // If an error occurs:
                    showErrorAlert = true
                    errorMessage = "Failed to unassign patient. Please try again."
                    return
                } else {
                    // Remove the patient's ID from the nurse's patients list
                    nurse.patients.removeAll { $0 == updatedPatient.id }
                    nurse.isAvailable = true
                }
                if nurse.patients.count == 0 {
                    
                    
                    // Update the doctor's nurse list in the Realtime Database
                    firebaseManager.updateDoctor(firebaseManager.loggedInDoctor) { err in
                        if err == nil {
                            firebaseManager.loggedInDoctor.nurses.removeAll { $0 == nurse.id }
//                            presentationMode.wrappedValue.dismiss()
                        } else {
                            // If an error occurs:
                            showErrorAlert = true
                            errorMessage = "Failed to unassign patient. Please try again."
                        }
                    }
                }
            }
        }
    }
    
    func assignPatient(_ patient: Patient) {
        // Update the patient's isAssigned property to true
        var updatedPatient = patient
        updatedPatient.assignedNurseID = nurse.id
        updatedPatient.assignedNurseName = nurse.name

        // Update the patient in the Realtime Database
        firebaseManager.updatePatient(updatedPatient) { err in
            if err != nil {
                return
            }
            // Add the patient's ID to the nurse's patients list
            nurse.patients.append(updatedPatient.id)
            nurse.isAvailable = false
            // Update the nurse's patients list in the Realtime Database
            firebaseManager.updateNurse(nurse) { err in
                if err != nil {
                    return
                }
            }
            firebaseManager.loggedInDoctor.nurses.append(nurse.id)
            
            // Update the doctor's nurse list in the Realtime Database
            firebaseManager.updateDoctor(firebaseManager.loggedInDoctor) { err in
                if err == nil {
//                    presentationMode.wrappedValue.dismiss()
                } else {
                    // If an error occurs:
                    showErrorAlert = true
                    errorMessage = "Failed to unassign patient. Please try again."
                }
            }
        }
    }
    
    func fetchUnassignedPatients() {
        let database = Database.database().reference()
        let patientsRef = database.child("Patients")
        patientsRef.observe(.value, with:  { snapshot in
            var tempAssigned: [Patient] = []
            var tempUnassigned: [Patient] = []
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any] {
                    
                    guard let patient = Patient(dictionary: data) else { return }
                    
                    if patient.assignedNurseID == "" {
                        tempUnassigned.append(patient)
                    } else if patient.assignedNurseID == nurse.id {
                        tempAssigned.append(patient)
                    }
                }
            }
            
            tempUnassigned = tempUnassigned.filter { patient in
                return firebaseManager.loggedInDoctor.patients.contains(patient.id)
            }
            
            tempAssigned = tempAssigned.filter { patient in
                return firebaseManager.loggedInDoctor.patients.contains(patient.id) || patient.assignedNurseID == nurse.id
            }
            
            self.unassignedPatients = tempUnassigned.filter { patient in
//                if firebaseManager.loggedInDoctor.specialization == .medicalSpecialist {
//                    return patient.assignedNurseID == ""
//                } else {
                    return patient.assignedNurseID == "" && patient.doctorSpecializations.contains(firebaseManager.loggedInDoctor.specialization)
//                }
            }
            self.assignedPatients = tempAssigned.filter { patient in
//                if firebaseManager.loggedInDoctor.specialization == .medicalSpecialist {
//                    return patient.assignedNurseID != ""
//                } else {
                return patient.assignedNurseID == nurse.id && patient.doctorSpecializations.contains(firebaseManager.loggedInDoctor.specialization)
//                }
            }
        }) { (error) in
            // If an error occurs:
            showErrorAlert = true
            errorMessage = "Failed to unassign patient. Please try again."
        }
    }
}

struct DoctorNursePatientsListView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorNursePatientsListView(firebaseManager: FirebaseManager(), nurse: Nurse(id: "uid", email: "nurse@gmail.com", name: "Nurse Doe", contactNumber: "123-456-7890", isAvailable: true, patients: []))
    }
}
