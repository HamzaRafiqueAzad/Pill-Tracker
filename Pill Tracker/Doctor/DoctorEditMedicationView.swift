//
//  EditMedicationView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 7/8/23.
//

import SwiftUI
import Firebase

struct DoctorEditMedicationView: View {
    @ObservedObject var firebaseManager: FirebaseManager

//    @Binding var medication: Medication
    @Environment(\.presentationMode) var presentationMode
    
    init(firebaseManager: FirebaseManager) {
            _firebaseManager = ObservedObject(wrappedValue: firebaseManager)
        _doseTimes = State(initialValue: firebaseManager.selectedMedication.reminders.map { Date(timeIntervalSince1970: $0.doseTime) })
        }
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var forDisease = ""
    @State private var frequency = 0
    
    @State private var doseTimes: [Date] = []
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
    
    var body: some View {
        ScrollView {
            VStack {
                Section(header: Text("Medication Details")) {
                    CustomTextField(title: "For", text: $firebaseManager.selectedMedication.forDisease)
                    CustomTextField(title: "Name", text: $firebaseManager.selectedMedication.name)
                    
                    HStack {
                            Text("Dosage")
                        Stepper("\(firebaseManager.selectedMedication.dosage) \(firebaseManager.selectedMedication.dosageUnit.rawValue)", onIncrement: {
                            if Int(firebaseManager.selectedMedication.dosage)! < 100 {
                                firebaseManager.selectedMedication.dosage = "\(Int(firebaseManager.selectedMedication.dosage)! + 1)"
                            }
                        }, onDecrement: {
                            if Int(firebaseManager.selectedMedication.dosage)! > 0 {
                                firebaseManager.selectedMedication.dosage = "\(Int(firebaseManager.selectedMedication.dosage)! - 1)"
                            }
                        })
                        Picker("", selection: $firebaseManager.selectedMedication.dosageUnit) {
                            ForEach(DosageUnit.allCases) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 80) // Adjust the width as needed
                    }
//                    CustomTextField(title: "Dosage", text: $firebaseManager.selectedMedication.dosage)
                    Stepper("Frequency: \(firebaseManager.selectedMedication.frequency) times a day", onIncrement: {
                        if firebaseManager.selectedMedication.frequency < 10 {
                            firebaseManager.selectedMedication.frequency += 1
                            doseTimes.append(Date())
                        }
                    }, onDecrement: {
                        if firebaseManager.selectedMedication.frequency > 0 {
                            firebaseManager.selectedMedication.frequency -= 1
                            doseTimes.removeLast()
                        }
                    })
                    ForEach(0..<firebaseManager.selectedMedication.frequency, id: \.self) { index in
                        VStack {
                            DatePicker("Dose \(index+1)", selection: $doseTimes[index], displayedComponents: .hourAndMinute)
                        }
                    }
                }
                Section(header: Text("Schedule")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Spacer(minLength: 50)
                
                
                Button {
                    updateMedication()
                } label: {
                    Text("Save")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(firebaseManager.selectedMedication.name.isEmpty || firebaseManager.selectedMedication.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || firebaseManager.selectedMedication.dosage.isEmpty || firebaseManager.selectedMedication.frequency == 0 ? Color.blue.opacity(0.2) : Color.blue )
                                .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                        )
                        .foregroundColor(.white)
                        .disabled(firebaseManager.selectedMedication.name.isEmpty || firebaseManager.selectedMedication.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || firebaseManager.selectedMedication.dosage.isEmpty || firebaseManager.selectedMedication.frequency == 0)
                }

                
                Spacer(minLength: 20)
                
                Button {
                    presentationMode.wrappedValue.dismiss()

                } label: {
                    Text("Cancel")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.red.opacity(0.8))
                                .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                        )
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .navigationBarTitle("Edit Pill: \(firebaseManager.selectedMedication.name)")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            startDate = Date(timeIntervalSince1970: firebaseManager.selectedMedication.startDate)
            endDate = Date(timeIntervalSince1970: firebaseManager.selectedMedication.endDate)
        }
    }
    
    private func updateMedication() {
        let calendar = Calendar.current
        var reminders: [MedicationReminder] = []
        var uniqueDoseTimes: Set<Date> = []
        print(startDate)
        print(endDate)
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
                }
            }
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }

        firebaseManager.selectedMedication.reminders = reminders
        firebaseManager.selectedMedication.startDate = startDate.timeIntervalSince1970
        firebaseManager.selectedMedication.endDate = endDate.timeIntervalSince1970
        
        // Update the medication in Firebase
        guard let ind = firebaseManager.selectedPatient.medications.firstIndex(where: { $0.id == firebaseManager.selectedMedication.id }) else { return }
        firebaseManager.selectedPatient.medications[ind] = firebaseManager.selectedMedication
        firebaseManager.updatePatient(firebaseManager.selectedPatient) { error in
            if error == nil {
                presentationMode.wrappedValue.dismiss()
            } else {
                print("Error updating medication: \(error?.localizedDescription ?? "")")
            }
        }
    }
}

struct DoctorEditMedicationView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorEditMedicationView(firebaseManager: FirebaseManager())
    }
}
