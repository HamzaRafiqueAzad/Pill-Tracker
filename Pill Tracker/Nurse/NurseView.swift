//
//  NurseView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import SwiftUI
import Firebase

struct NurseView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    
    @State private var patients: [Patient] = []
    
    var body: some View {
//        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        // Perform logout action here
                        firebaseManager.logout()
                    }) {
                        Image(systemName: "arrow.forward.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 20)
                }
                Text("Welcome, Nurse \(firebaseManager.loggedInNurse.name)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                
                Spacer()
                
                VStack(spacing: 20) {
                    Section(header: Text("Assigned Patients")) {
                        ScrollView {
                            ForEach(patients.indices, id: \.self) { index in
                                let binding = Binding(
                                    get: { patients[index] },
                                    set: { patients[index] = $0 }
                                )
                                NavigationLink(destination: NursePatientDetailView(firebaseManager: firebaseManager, patient: binding)) {
                                    NursePatientCard(patient: binding)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Nurse Dashboard")
//            .navigationBarItems(trailing: Button(action: {
//                // Perform logout action here
//                firebaseManager.logout()
//            }) {
//                Text("Logout")
//                    .foregroundColor(.blue)
//            })
//        }
        .navigationBarHidden(true)
        .onAppear {
            firebaseManager.setupNurseListener()
            setupFirebaseListeners()
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
    
    private func setupFirebaseListeners() {
        // Assuming you have a function to get nurse's reference in Firebase
        let nursesRef = Database.database().reference().child("Nurses")
        let nurseRef = nursesRef.child(firebaseManager.loggedInNurse.id)
        nurseRef.child("patients").observe(.childAdded) { snapshot in
            if let patientId = snapshot.value as? String {
                fetchPatientAndCreateReminders(patientId: patientId)
            }
        }
    }
    
    private func fetchPatientAndCreateReminders(patientId: String) {
        // Assuming you have a function to fetch patient details from Firebase
        let patientsRef = Database.database().reference().child("Patients")
        
        patientsRef.child(patientId).observe(.value, with: { snapshot in
            var pats: [Patient] = []
            if let data = snapshot.value as? [String: Any] {
                guard let patient = Patient(dictionary: data) else { return }
                pats.append(patient)
                createMedicationReminders(for: patient, of: patient.medications)
            }
            self.patients = pats
        })
    }
    
    private func createMedicationReminders(for patient: Patient, of medications: [Medication]) {
        for medication in medications {
            let notificationIDs = UserDefaults.standard.value(forKey: medication.id.uuidString) as? [String] ?? []
            firebaseManager.removeNotifications(for: notificationIDs)
            if medication.medicationState == .active {
                firebaseManager.scheduleNotifications(for: patient, of: medication)
            }
        }
    }
}

struct NurseView_Previews: PreviewProvider {
    static var previews: some View {
        NurseView(firebaseManager: FirebaseManager())
    }
}
