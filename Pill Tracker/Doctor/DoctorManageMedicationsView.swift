//
//  ManageMedicationsView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 7/8/23.
//

import SwiftUI

struct DoctorManageMedicationsView: View {
    @ObservedObject var firebaseManager: FirebaseManager

    @State private var showAddMedicationSheet = false
    @State private var showEditMedicationSheet = false
    @State private var selectedMedication: Medication?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: {
                        showAddMedicationSheet.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 20)
                }
                
                Text("Medications")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.primary)
                
                ForEach(firebaseManager.selectedPatient.medications, id: \.self) { medication in
                    DoctorMedicationCardView(firebaseManager: firebaseManager, medication: medication)
                        .onTapGesture {
                            firebaseManager.selectedMedication = medication
                            showEditMedicationSheet.toggle()
                        }
                }
            }
            .padding()
        }
        .navigationBarTitle("Manage Medications")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .sheet(isPresented: $showAddMedicationSheet, content: {
            DoctorAddMedicationView(firebaseManager: firebaseManager)
        })
        .sheet(isPresented: $showEditMedicationSheet, content: {
            DoctorEditMedicationView(firebaseManager: firebaseManager)
        })
    }
}

struct DoctorManageMedicationsView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorManageMedicationsView(firebaseManager: FirebaseManager())
    }
}
