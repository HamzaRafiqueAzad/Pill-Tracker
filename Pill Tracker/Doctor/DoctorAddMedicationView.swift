//
//  AddMedicationView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 7/8/23.
//

import SwiftUI
import Firebase

struct DoctorAddMedicationView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var dosage = "0"
    @State private var forDisease = ""

    @State private var frequency = 0
    
    @State private var doseTimes: [Date] = [] // Initialize with current time
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(60 * 60 * 24 * 30) // default end date is 30 days from now
    
    @State private var selectedDosageUnit = DosageUnit.mg

    
    var body: some View {
        ScrollView {
            VStack {
                Section(header: Text("Medication Details")) {
                    CustomTextField(title: "For", text: $forDisease)
                    CustomTextField(title: "Name", text: $name)
                    HStack {
                            Text("Dosage")
                        Stepper("\(dosage) \(selectedDosageUnit.rawValue)", onIncrement: {
                            if Int(dosage)! < 100 {
                                dosage = "\(Int(dosage)! + 1)"
                            }
                        }, onDecrement: {
                            if Int(dosage)! > 0 {
                                dosage = "\(Int(dosage)! - 1)"
                            }
                        })
                        Picker("", selection: $selectedDosageUnit) {
                            ForEach(DosageUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 80) // Adjust the width as needed
                    }
                    Stepper("Frequency: \(frequency) times a day", onIncrement: {
                        if frequency < 10 {
                            frequency += 1
                            doseTimes.append(Date())
                        }
                    }, onDecrement: {
                        if frequency > 0 {
                            frequency -= 1
                            doseTimes.removeLast()
                        }
                    })
                    ForEach(0..<frequency, id: \.self) { index in
                        VStack {
                            DatePicker("Dose \(index+1)", selection: $doseTimes[index], displayedComponents: .hourAndMinute)
                        }
                    }
                }
                Section(header: Text("Schedule")) {
                    DatePicker("Start Date", selection: $startDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                }
                
                Spacer(minLength: 50)
                
                Button {
                    saveMedication()
                } label: {
                    Text("Save")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(name.isEmpty || dosage == "0" || frequency == 0 ? Color.blue.opacity(0.2) : Color.blue )
                                .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                        )
                        .foregroundColor(.white)
                }
                .disabled(name.isEmpty || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || dosage == "0" || frequency == 0)
            }
            .padding()
        }
        .navigationBarTitle("New Reminder")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
    
    private func saveMedication() {
        let calendar = Calendar.current
        var reminders: [MedicationReminder] = []
        
        var uniqueDoseTimes: Set<Date> = []

        var currentDate = startDate
        while currentDate <= endDate {
            for doseTime in doseTimes {
                let dateComp = calendar.dateComponents([.year, .month, .day], from: currentDate)
                let timeComp = calendar.dateComponents([.hour, .minute], from: doseTime)
                var newDate = DateComponents()
                newDate.year = dateComp.year
                newDate.month = dateComp.month
                newDate.day = dateComp.day
                newDate.hour = timeComp.hour
                newDate.minute = timeComp.minute
                guard let da = calendar.date(from: newDate) else { continue }
                // Check if the dose time is already in the set, if not, add it to the set and reminders
                if !uniqueDoseTimes.contains(da) {
                    uniqueDoseTimes.insert(da)
                    reminders.append(MedicationReminder(name: name, doseTime: da.timeIntervalSince1970, isTaken: false, isVerified: false))
                } else {
                    frequency -= 1
                }
//                reminders.append(MedicationReminder(name: name, doseTime: da.timeIntervalSince1970, isTaken: false, isVerified: false))
            }
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        let medication = Medication(id: UUID(), name: name, dosage: dosage, dosageUnit: selectedDosageUnit, forDisease: forDisease, reminders: reminders, frequency: frequency, startDate: startDate.timeIntervalSince1970, endDate: endDate.timeIntervalSince1970, medicationState: .active)
        firebaseManager.selectedPatient.medications.append(medication)
        
        // Update the patient's medications on Firebase
        firebaseManager.updatePatient(firebaseManager.selectedPatient) { error in
            if error == nil {
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Error updating patient: \(error?.localizedDescription ?? "")")
            }
        }
    }}

struct DoctorAddMedicationView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorAddMedicationView(firebaseManager: FirebaseManager())
    }
}
