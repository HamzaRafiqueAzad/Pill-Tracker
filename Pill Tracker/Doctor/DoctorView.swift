//
//  DoctorVIew.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import SwiftUI
import Firebase

struct DoctorView: View {    
    @ObservedObject var firebaseManager: FirebaseManager
    
    @State private var assignedNurses: [Nurse] = []
    @State private var availableNurses: [Nurse] = []
    
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
                }
                
                Text("Welcome, Dr. \(firebaseManager.loggedInDoctor.name)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                
                Spacer()
                if firebaseManager.loggedInDoctor.specialization != .medicalSpecialist {
                    NavigationLink(destination: DoctorNursesListView(firebaseManager: firebaseManager, assignedNurses: $assignedNurses, availableNurses: $availableNurses)) {
                        Text("Manage Nurses")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.blue)
                            )
                    }
                }
                
                NavigationLink(destination: DoctorPatientsListView(firebaseManager: firebaseManager)) {
                    Text("Manage Patients")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                        )
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Doctor Dashboard")
            .navigationBarHidden(true)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
//        }
        .onAppear {
            firebaseManager.setupDoctorListener()
            setupAssignedListeners()
            setupAvailableListeners()
        }
    }
    
    private func setupAssignedListeners() {
        // Assuming you have a function to get nurse's reference in Firebase
        let doctorsRef = Database.database().reference().child("Doctors")
        let doctorRef = doctorsRef.child(firebaseManager.loggedInDoctor.id)
        doctorRef.child("nurses").observe(.childAdded, with: { snapshot in
            if let nurseId = snapshot.value as? String {
                // Fetch nurse details using nurseId
                fetchAssignedNurses(nurseId: nurseId)
            }
        })
    }
    
    private func fetchAssignedNurses(nurseId: String) {
        let accountRef = Database.database().reference().child("Nurses").child(nurseId)
        
        accountRef.observe(.value, with: { snapshot in
            var tempAssigned: [Nurse] = []
            if let data = snapshot.value as? [String: Any] {
                guard let nurse = Nurse(dictionary: data) else { return }
                if nurse.isAvailable == false {
                    tempAssigned.append(nurse)
                    self.availableNurses.removeAll(where: { $0.id == nurse.id })
                } else {
                    if !self.availableNurses.contains(nurse) {
                        self.availableNurses.append(nurse)
                    }
                }
            }
            
            self.assignedNurses = tempAssigned
        })
    }
    
    private func setupAvailableListeners() {
        // Assuming you have a function to fetch patient details from Firebase
        let nursesRef = Database.database().reference().child("Nurses")
        var nurses: [Nurse] = []

        nursesRef.observe(.childAdded, with: { snapshot in
            if let data = snapshot.value as? [String: Any] {
                guard let nurse = Nurse(dictionary: data) else { return }
                if !(firebaseManager.loggedInDoctor.nurses.contains(nurse.id)) && nurse.isAvailable {
                    if !(nurses.contains(nurse)) {
                        nurses.append(nurse)
                    }
                }
            }
            self.availableNurses = nurses
        })
    }
}

struct DoctorView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorView(firebaseManager: FirebaseManager())
    }
}

