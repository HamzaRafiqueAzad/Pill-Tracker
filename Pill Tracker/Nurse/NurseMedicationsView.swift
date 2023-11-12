//
//  MedicationHistoryView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 7/8/23.
//

import SwiftUI
import Firebase

struct NurseMedicationsView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach($firebaseManager.selectedPatient.medications, id: \.self) { $medication in
                    NavigationLink(destination: NurseMedicationDetailView(firebaseManager: firebaseManager, medication: medication)) {
                        NurseMedicationRowView(firebaseManager: firebaseManager, medication: $medication)
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

struct NurseMedicationsView_Previews: PreviewProvider {
    static var previews: some View {
        let medications = [
            Medication(id: UUID(), name: "Medication 1", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active),
            Medication(id: UUID(), name: "Medication 2", dosage: "5mg", dosageUnit: .mg, forDisease: "", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active)
            // Add more sample medication history entries
        ]
        return NurseMedicationsView(firebaseManager: FirebaseManager())
    }
}
