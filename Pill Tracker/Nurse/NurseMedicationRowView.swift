//
//  MedicationReminderRowView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 8/8/23.
//

import SwiftUI

struct NurseMedicationRowView: View {
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
            VStack {
                if medication.wrappedValue.medicationState == .active {
                    Text("Active")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                                .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                        )
                } else {
                    Text("Paused")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                    
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue)
                                .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                        )
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.circle")
                    .foregroundColor(.blue)
                
                Spacer()
            }
            
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

struct NurseMedicationRowView_Previews: PreviewProvider {
    static var previews: some View {
        NurseMedicationRowView(firebaseManager: FirebaseManager(), medication: .constant(Medication(id: UUID(), name: "Medication 1", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active)))
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.gray.opacity(0.2))
    }
}
