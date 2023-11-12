//
//  NurseAddVitalReadingView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 8/8/23.
//
import SwiftUI

struct NurseAddVitalReadingView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var firebaseManager: FirebaseManager

    @State private var vitalType = VitalType.heartRate
    @State private var value: Double = 0
    @State private var date = Date()
    
    @State private var showWarning = false
    @State private var warningMessage = ""
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var valueRange: ClosedRange<Double> {
        switch vitalType {
        case .heartRate:
            return 0...200
        case .bloodPressure:
            return 60...220
        case .bloodSugar:
            return 0...300
        // Add more cases for other vital types if needed
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Section(header: Text("Vital Information")) {
                Picker("Vital", selection: $vitalType) {
                    ForEach(VitalType.allCases, id: \.self) { vital in
                        Text(vital.rawValue).tag(vital)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: vitalType) { newValue in
                    // Update value based on selected vital type
                    switch newValue {
                    case .bloodPressure:
                        value = 60
                    default:
                        value = 0
                    }
                }
                
                HStack(spacing: 8) {
                    Text("Select Value:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker(selection: $value, label: Text("Value")) {
                        ForEach(Int(valueRange.lowerBound)...Int(valueRange.upperBound), id: \.self) { intValue in
                            Text("\(intValue)")
                                .foregroundColor(.primary)
                                .font(.subheadline)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 80, height: 100) // Adjust the height to your preference
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.1))
                            .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 3)
                    )
                    .padding(.horizontal)
                }
            }
            
            Section {
                Button(action: {
                    addVitalReading()
                }) {
                    Text("Add Vital Reading")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationBarTitle("Add Vital Reading")
        .alert(isPresented: $showWarning) {
            Alert(title: Text("Warning"),
                  message: Text(warningMessage),
                  dismissButton: .default(Text("OK")) {
                    firebaseManager.updatePatient(firebaseManager.selectedPatient) { err in
                        if err == nil {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            // If an error occurs:
                            showErrorAlert = true
                            errorMessage = "Failed to save data. Please try again."
                        }
                    }
            })
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
    
    private func addVitalReading() {
        let newVital = Vital(id: UUID(), type: vitalType, value: value, date: Date().timeIntervalSince1970)
        
        firebaseManager.selectedPatient.vitals.append(newVital)
        
        (showWarning, warningMessage) = isValueTooHighOrTooLow(vitalType: vitalType, value: value)
        
        if !showWarning {
            firebaseManager.updatePatient(firebaseManager.selectedPatient) { err in
                if err == nil {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    // If an error occurs:
                    showErrorAlert = true
                    errorMessage = "Failed to save data. Please try again."
                }
            }
        }
    }
    
    private func isValueTooHighOrTooLow(vitalType: VitalType, value: Double) -> (Bool, String) {
            switch vitalType {
            case .heartRate:
                if value < 50 {
                    return (true, "Heart Rate is too low. Please inform the doctor.")
                } else if value > 120 {
                    return (true, "Heart Rate is too high. Please inform the doctor.")
                }
                return (false, "")
            case .bloodPressure:
                if value < 60 {
                    return (true, "Blood Pressure is too low. Please inform the doctor.")
                } else if value > 140 {
                    return (true, "Blood Pressure is too high. Please inform the doctor.")
                }
                return (false, "")
            case .bloodSugar:
                if value < 70 {
                    return (true, "Blood Sugar is too low. Please inform the doctor.")
                } else if value > 180 {
                    return (true, "Blood Sugar is too high. Please inform the doctor.")
                }
                return (false, "")
            }
        }
}

struct NurseAddVitalReadingView_Previews: PreviewProvider {
    static var previews: some View {
        NurseAddVitalReadingView(firebaseManager: FirebaseManager())
    }
}
