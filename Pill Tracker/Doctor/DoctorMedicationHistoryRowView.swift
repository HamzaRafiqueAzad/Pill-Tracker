//
//  MedicationHistoryRowView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import SwiftUI

struct DoctorMedicationRowView: View {
    @ObservedObject var firebaseManager: FirebaseManager

    var entry: Medication
    
    var body: some View {
        HStack {
            VStack(alignment: .center, spacing: 8) {
                Text("Date: \( Date(timeIntervalSince1970: entry.startDate), formatter: DateFormatter.dateFriendly)")
                    .font(.headline)
                
                Text("Medication: \(entry.name)")
                    .foregroundColor(.primary)
                
                Text("Dosage: \(entry.dosage)")
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            Image(systemName: "chevron.right.circle")
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
        )
        .padding(.vertical, 5)
        .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)    }
}

struct DoctorMedicationRowView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorMedicationRowView(firebaseManager: FirebaseManager(), entry: Medication(id: UUID(), name: "Medication 1", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active))
    }
}
