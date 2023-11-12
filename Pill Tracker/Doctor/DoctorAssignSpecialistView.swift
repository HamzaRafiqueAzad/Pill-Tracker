//
//  DoctorAssignSpecialistView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 16/8/23.
//

import SwiftUI

struct DoctorAssignSpecialistView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    @State private var selectedSpecialization: DoctorSpecialization = .heartSpecialist // Default selected specialization
    
    @State private var specializations: [DoctorSpecialization] = []
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    var body: some View {
        VStack {
            Text("Assign Diseases")
                .foregroundColor(.primary)
                .font(.title)
                .bold()
                .padding(.bottom, 20)
            
            VStack(spacing: 20) {
                if specializations.count != 0 {
                    HStack {
                        
                        Picker("Select Disease", selection: $selectedSpecialization) {
                            
                            ForEach(specializations, id: \.self) { specialization in
                                Text(specialization.rawValue).tag(specialization.rawValue)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.bottom, 20)
                        
                        Button(action: {
                            addSpecialization()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.blue)
                        }
                    }
                }
                
                ForEach(firebaseManager.selectedPatient.doctorSpecializations, id: \.self) { specialization in
                    HStack {
                        Text(specialization.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .onTapGesture {
                                removeSpecialization(specialization)
                            }
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
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            specializations = DoctorSpecialization.allCases.filter { !firebaseManager.selectedPatient.doctorSpecializations.contains($0) && $0 != .medicalSpecialist }
            if specializations.count > 0 {
                selectedSpecialization = specializations[0]
            }
        }
    }
    
    func removeSpecialization(_ specialization: DoctorSpecialization) {
        if firebaseManager.selectedPatient.doctorSpecializations.contains(specialization) {
            firebaseManager.selectedPatient.doctorSpecializations.removeAll(where: { $0 == specialization })
            specializations.append(specialization)
            firebaseManager.updatePatient(firebaseManager.selectedPatient) { err in
                if err == nil {
                    // Handle successful removal
                } else {
                    // If an error occurs:
                    showErrorAlert = true
                    errorMessage = "Failed to save data. Please try again."
                }
            }
        } else {
            
        }
        
    }
    
    func addSpecialization() {
        firebaseManager.selectedPatient.doctorSpecializations.append(selectedSpecialization)
        specializations.removeAll(where: { $0 == selectedSpecialization })
        print(specializations)
        if specializations.count != 0 {
            selectedSpecialization = specializations[0]
        }
        firebaseManager.updatePatient(firebaseManager.selectedPatient) { err in
            if err == nil {
                // Handle successful addition
            } else {
                // If an error occurs:
                showErrorAlert = true
                errorMessage = "Failed to save data. Please try again."
            }
        }
    }
}

struct DoctorAssignSpecialistView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorAssignSpecialistView(firebaseManager: FirebaseManager())
    }
}
