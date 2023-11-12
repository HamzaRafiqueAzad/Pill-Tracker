//
//  MedicationCard.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 9/8/23.
//

import SwiftUI

struct PatientMedicationCard: View {
    var medication: Medication
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("For: \(medication.forDisease)")
                .font(.headline)
                .foregroundColor(Color.primary)
            Text("Medication Name: \(medication.name)")
                .font(.headline)
            Text("Dosage: \(medication.dosage)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Date: \(Date(timeIntervalSince1970: medication.startDate), formatter: DateFormatter.userFriendly)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Text("Taken: \(medication.reminders.filter({ $0.isTaken == true }).count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Remaining: \(medication.reminders.filter({ $0.isTaken == false }).count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.vertical, 5)
    }
}

struct PatientMedicationCard_Previews: PreviewProvider {
    static var previews: some View {
        PatientMedicationCard(medication: Medication(id: UUID(), name: "Medication 1", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active))
    }
}
