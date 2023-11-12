//
//  MedicationCardView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 7/8/23.
//

import SwiftUI

struct DoctorMedicationCardView: View {
    @ObservedObject var firebaseManager: FirebaseManager

    var medication: Medication
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text("For: \(medication.forDisease)")
                    .font(.headline)
                    .foregroundColor(Color.primary)
                Text("Medication: \(medication.name)")
                    .font(.headline)
                    .foregroundColor(Color.primary)
                Text("Dosage: \(medication.dosage)")
                    .foregroundColor(Color.secondary)
                Text("Start Date: \(Date(timeIntervalSince1970: medication.startDate), formatter: DateFormatter.userFriendly)")
                    .foregroundColor(Color.secondary)
                
            }
            Spacer()
            
            VStack {
                if medication.medicationState == .active {
                    Button {
                        firebaseManager.pauseMedication(medication) {  err in
                            if err == nil {
                            }  else {
                                // If an error occurs:
                                showErrorAlert = true
                                errorMessage = "Failed to pause medication. Please try again."
                            }
                        }
                    } label: {
                        Text("Pause")
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
                } else {
                    Button {
                        firebaseManager.resumeMedication(medication) { err in
                            if err == nil {
                            } else {
                                // If an error occurs:
                                showErrorAlert = true
                                errorMessage = "Failed to resume medication. Please try again."
                            }
                        }
                    } label: {
                        Text("Resume")
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
                }
                
                Spacer()
                
                Image(systemName: "chevron.right.circle")
                    .foregroundColor(.blue)
                
                Spacer()
            }
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
        )
        .padding(.vertical, 5)
        .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct DoctorMedicationCardView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorMedicationCardView(firebaseManager: FirebaseManager(), medication: Medication(id: UUID(), name: "Medication 1", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active))
    }
}
