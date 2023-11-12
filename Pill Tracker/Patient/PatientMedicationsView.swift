//
//  MedicationHistoryView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 7/8/23.
//

import SwiftUI
import Firebase

struct PatientMedicationsView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach($firebaseManager.loggedInPatient.medications, id: \.self) { $medication in
                    if medication.medicationState == .active {
                        NavigationLink(destination: PatientMedicationDetailView(firebaseManager: firebaseManager, medication: medication)) {
                            PatientMedicationRowView(firebaseManager: firebaseManager, medication: $medication)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationBarTitle("Medication History")
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

struct PatientMedicationsView_Previews: PreviewProvider {
    static var previews: some View {
        return PatientMedicationsView(firebaseManager: FirebaseManager())
    }
}
