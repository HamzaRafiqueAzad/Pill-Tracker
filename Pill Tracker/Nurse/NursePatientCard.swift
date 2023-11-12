//
//  NursePatientCard.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 8/8/23.
//

import SwiftUI

struct NursePatientCard: View {
    @Binding var patient: Patient
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(patient.name)
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding(.bottom, 4)
                
                Text("Contact: \(patient.contactNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "pills")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Text("Assigned Medications: \(patient.medications.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if patient.assignedNurseName != "" {
                    Text("Assigned Nurse: \(patient.assignedNurseName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
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
        .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
        .listRowBackground(Color.clear)
    }
}

struct NursePatientCard_Previews: PreviewProvider {
    static var previews: some View {
        NursePatientCard(patient: .constant(Patient(id: "uid", email: "patient@gmail.com", name: "Patient Doe", contactNumber: "123-456-7890", assignedNurseID: "nurseID", assignedNurseName: "NurseName", medications: [], vitals: [], doctorSpecializations: [], notes: "")))
            .previewLayout(.sizeThatFits)
            .padding()
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .edgesIgnoringSafeArea(.all)
//            )
    }
}

