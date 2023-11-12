//
//  PatientsListView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import SwiftUI
import Firebase

//struct DoctorPatientsListView: View {
//    @ObservedObject var firebaseManager: FirebaseManager
//
//    @State private var patients: [Patient] = [] // Store patients here
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                Section(header: Text("Unassigned Patients").font(.headline).foregroundColor(.primary)) {
//                    ForEach(unassignedPatients, id: \.id) { patient in
//                        NavigationLink(destination: DoctorPatientDetailView(firebaseManager: firebaseManager, patient: patient)) {
//                            DoctorPatientCard(firebaseManager: firebaseManager, patient: patient, assignPatient: { _ in })
//                                .listRowBackground(Color.clear)
//                        }
//                    }
//                }
//
//                Section(header: Text("Assigned Patients").font(.headline).foregroundColor(.primary)) {
//                    ForEach(assignedPatients, id: \.id) { patient in
//                        NavigationLink(destination: DoctorPatientDetailView(firebaseManager: firebaseManager, patient: patient)) {
//                            DoctorPatientCard(firebaseManager: firebaseManager, patient: patient, assignPatient: { _ in })
//                                .listRowBackground(Color.clear)
//                        }
//                    }
//                }
//            }
//            .padding()
//        }
//        .frame(maxWidth: .infinity)
//        .background(
//            LinearGradient(
//                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .edgesIgnoringSafeArea(.all)
//        )
//        .navigationBarTitle("Manage Patients")
//        .onAppear {
//            fetchPatients()
//        }
//    }
//
//    var unassignedPatients: [Patient] {
//        patients.filter { $0.assignedNurseID == "" }
//    }
//
//    var assignedPatients: [Patient] {
//        patients.filter { $0.assignedNurseID != "" }
//    }
//
//    func fetchPatients() {
//        let database = Database.database().reference()
//        let patientsRef = database.child("Patients")
//
//        patientsRef.observe(.value, with:  { snapshot in
//            var newPatients: [Patient] = []
//
//            for child in snapshot.children {
//                if let childSnapshot = child as? DataSnapshot,
//                   let data = childSnapshot.value as? [String: Any] {
//
//                    guard let patient = Patient(dictionary: data) else { return }
//
//                    newPatients.append(patient)
//                }
//            }
//
//            self.patients = newPatients
//        })
//    }
//}

struct DoctorPatientsListView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    @State private var patients: [Patient] = [] // Store patients here
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if firebaseManager.loggedInDoctor.specialization == .medicalSpecialist {
                    // Show both unassigned and assigned patients for medical specialists
                    Section(header: Text("Unassigned Patients").font(.headline).foregroundColor(.primary)) {
                        ForEach(unassignedPatients, id: \.id) { patient in
                            NavigationLink(destination: DoctorPatientDetailView(firebaseManager: firebaseManager, patient: patient)) {
                                DoctorPatientCard(firebaseManager: firebaseManager, patient: patient, assignPatient: { _ in })
                                    .listRowBackground(Color.clear)
                            }
                        }
                    }
                    
                    Section(header: Text("Assigned Patients").font(.headline).foregroundColor(.primary)) {
                        ForEach(assignedPatients, id: \.id) { patient in
                            NavigationLink(destination: DoctorPatientDetailView(firebaseManager: firebaseManager, patient: patient)) {
                                DoctorPatientCard(firebaseManager: firebaseManager, patient: patient, assignPatient: { _ in })
                                    .listRowBackground(Color.clear)
                            }
                        }
                    }
                } else {
                    // Show only unassigned patients with matching specialization
                    Section(header: Text("Unassigned Patients").font(.headline).foregroundColor(.primary)) {
                        ForEach(unassignedPatients.filter({ $0.doctorSpecializations.contains(firebaseManager.loggedInDoctor.specialization)}), id: \.id) { patient in
                            NavigationLink(destination: DoctorPatientDetailView(firebaseManager: firebaseManager, patient: patient)) {
                                DoctorPatientCard(firebaseManager: firebaseManager, patient: patient, assignPatient: { _ in })
                                    .listRowBackground(Color.clear)
                            }
                        }
                    }
                    
                    Section(header: Text("Assigned Patients").font(.headline).foregroundColor(.primary)) {
                        ForEach(assignedPatients, id: \.id) { patient in
                            NavigationLink(destination: DoctorPatientDetailView(firebaseManager: firebaseManager, patient: patient)) {
                                DoctorPatientCard(firebaseManager: firebaseManager, patient: patient, assignPatient: { _ in })
                                    .listRowBackground(Color.clear)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle("Manage Patients")
        .onAppear {
            fetchPatients()
        }
    }
    
    var unassignedPatients: [Patient] {
        patients.filter { patient in
            if firebaseManager.loggedInDoctor.specialization == .medicalSpecialist {
                return patient.assignedNurseID == ""
            } else {
                return !(firebaseManager.loggedInDoctor.patients.contains(patient.id)) && patient.doctorSpecializations.contains(firebaseManager.loggedInDoctor.specialization)
            }
        }
    }

    var assignedPatients: [Patient] {
        patients.filter { patient in
            if firebaseManager.loggedInDoctor.specialization == .medicalSpecialist {
                return patient.assignedNurseID != ""
            } else {
                return firebaseManager.loggedInDoctor.patients.contains(patient.id) && patient.doctorSpecializations.contains(firebaseManager.loggedInDoctor.specialization)
            }
        }
    }

    func fetchPatients() {
        let database = Database.database().reference()
        let patientsRef = database.child("Patients")
        
        patientsRef.observe(.value, with:  { snapshot in
            var newPatients: [Patient] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let data = childSnapshot.value as? [String: Any] {
                    
                    guard let patient = Patient(dictionary: data) else { return }
                    
                    newPatients.append(patient)
                }
            }
            
            self.patients = newPatients
        })
    }
}


struct DoctorPatientsListView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorPatientsListView(firebaseManager: FirebaseManager())
    }
}
