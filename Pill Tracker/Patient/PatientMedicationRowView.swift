//
//  PatientMedicationRowView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 9/8/23.
//

import SwiftUI

struct PatientMedicationRowView: View {
    @ObservedObject var firebaseManager: FirebaseManager

    let medication: Binding<Medication>
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                
                Text("For: \(medication.forDisease.wrappedValue)")
                    .font(.headline)
                    .foregroundColor(Color.primary)
                
                Text(medication.name.wrappedValue)
                    .font(.headline)
                Text("Dosage: \(medication.dosage.wrappedValue)")
                    .font(.subheadline)
                
                Text("Start Date: \(Date(timeIntervalSince1970: medication.startDate.wrappedValue), formatter: DateFormatter.dateFriendly)")
                    .font(.subheadline)
                
                Text("End Date: \(Date(timeIntervalSince1970: medication.endDate.wrappedValue), formatter: DateFormatter.dateFriendly)")
                    .font(.subheadline)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right.circle")
                .foregroundColor(.blue)
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.2))
                .shadow(color: Color.blue.opacity(0.5), radius: 5, x: 2, y: 2)
                .shadow(color: Color.blue, radius: 5, x: -2, y: -2)
        )
        .padding(.vertical, 5)
        .foregroundColor(.primary)
    }
}

struct PatientMedicationRowView_Previews: PreviewProvider {
    static var previews: some View {
        PatientMedicationRowView(firebaseManager: FirebaseManager(), medication: .constant(Medication(id: UUID(), name: "Medication 1", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active)))
    }
}
