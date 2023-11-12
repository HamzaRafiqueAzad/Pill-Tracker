//
//  PatientVerifyDoseView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 11/8/23.
//

import SwiftUI

struct PatientVerifyDosesView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    @State private var selectedTimeRange: TimeRangeOption = .all
    @State private var selectedMonth: Int = 1 // Default month (January)
    @State private var selectedDate: Date = Date() // Default to today
    
    @State var minStartDate: Date?
    @State var maxEndDate: Date?

    var body: some View {
        ScrollView {
            Section(header: Text("Filters")) {
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRangeOption.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if selectedTimeRange == .month {
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(Calendar.current.monthSymbols[month - 1])
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                } else if selectedTimeRange == .date {
                    DatePicker("Select Date", selection: $selectedDate, in: (minStartDate ?? Date())...(maxEndDate ?? Date()) ,displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding()
                }
            }
            
            Section(header: Text("Doses to Verify")) {
                ForEach($firebaseManager.loggedInPatient.medications, id: \.self) { $medication in
                    ForEach(filteredReminders(for: $medication).filter({ !$0.isVerified && $0.isTaken })) { reminder in
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name: \(medication.name)")
                                    .font(.subheadline)
                                
                                Text("Dosage: \(medication.dosage)")
                                    .font(.subheadline)
                                
                                Text("Frequency: \(medication.frequency) times a day")
                                    .font(.subheadline)
                                Text(Date(timeIntervalSince1970: reminder.doseTime), formatter: DateFormatter.userFriendly)
                                    .font(.subheadline)
                            }
                            Spacer()
                            HStack {
                                Button(action: {
                                    verifyDose(reminder, $medication)
                                }) {
                                    Image("verify")
                                }
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
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.trailing, 30)
            .padding(.leading, 30)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            for medication in firebaseManager.loggedInPatient.medications {
                for reminder in medication.reminders {
                    if !reminder.isVerified {
                        if minStartDate == nil || Date(timeIntervalSince1970: reminder.doseTime) < minStartDate! {
                            minStartDate = Date(timeIntervalSince1970: reminder.doseTime)
                        }
                        if maxEndDate == nil || Date(timeIntervalSince1970: reminder.doseTime) > maxEndDate! {
                            maxEndDate = Date(timeIntervalSince1970: reminder.doseTime)
                        }
                    }
                }
            }
        }
    }
    
    private func filteredReminders(for medication: Binding<Medication>) -> [MedicationReminder] {
        var reminders = medication.wrappedValue.reminders.filter { !$0.isVerified && $0.isTaken }
        
        switch selectedTimeRange {
        case .all:
            break
        case .month:
            reminders = reminders.filter { reminder in
                let reminderMonth = Calendar.current.component(.month, from: Date(timeIntervalSince1970: reminder.doseTime))
                return reminderMonth == selectedMonth
            }
        case .date:
            // Filter reminders based on the selected date
            let startOfDay = Calendar.current.startOfDay(for: selectedDate)
            let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate)!
            
            reminders = reminders.filter { reminder in
                let doseTime = Date(timeIntervalSince1970: reminder.doseTime)
                return doseTime >= startOfDay && doseTime < endOfDay
            }
        }

        return reminders
    }
    
    private func verifyDose(_ reminder: MedicationReminder, _ medication: Binding<Medication>) {
        // Create a mutable copy of the reminder
        var updatedReminder = reminder
        updatedReminder.isVerified = true
        
        // Update the reminder in the medication's reminders array
        if let index = medication.wrappedValue.reminders.firstIndex(where: { $0.id == updatedReminder.id }) {
            medication.wrappedValue.reminders[index] = updatedReminder
            guard let medicationIndex = firebaseManager.loggedInPatient.medications.firstIndex(where: { $0.id == medication.id }) else { return }
            
            firebaseManager.loggedInPatient.medications[medicationIndex] = medication.wrappedValue
            // Update the medication in Firebase
            firebaseManager.updatePatient(firebaseManager.loggedInPatient) { err in
                
            }
        }
    }
}

struct PatientVerifyDosesView_Previews: PreviewProvider {
    static var previews: some View {
        PatientVerifyDosesView(firebaseManager: FirebaseManager())
    }
}


//struct PatientVerifyDosesView: View {
//    @ObservedObject var firebaseManager: FirebaseManager
//
//    var body: some View {
//        NavigationView {
//            List {
//                Section(header: Text("Doses to Verify")) {
//                    ForEach($firebaseManager.loggedInPatient.medications, id: \.self) { $medication in
//                        ForEach(medication.reminders.filter { !$0.isVerified && $0.isTaken }) { reminder in
//                            VStack(alignment: .leading, spacing: 16) {
//                                Text("Medication Details:")
//                                    .font(.headline)
//                                    .padding(.top)
//
//                                Text("Name: \(medication.name)")
//                                    .font(.subheadline)
//
//                                Text("Dosage: \(medication.dosage)")
//                                    .font(.subheadline)
//
//                                Text("Frequency: \(medication.frequency) times a day")
//                                    .font(.subheadline)
//                                HStack {
//                                    Text(medication.name)
//                                    Spacer()
//                                    Button(action: {
//                                        verifyDose(reminder, $medication)
//                                    }) {
//                                        Text("Verify")
//                                            .foregroundColor(.blue)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationBarTitle("Patient Account")
//        }
//    }
//
//    private func verifyDose(_ reminder: MedicationReminder, _ medication: Binding<Medication>) {
//        // Create a mutable copy of the reminder
//        var updatedReminder = reminder
//        updatedReminder.isVerified = true
//
//        // Update the reminder in the medication's reminders array
//        if let index = medication.wrappedValue.reminders.firstIndex(where: { $0.id == updatedReminder.id }) {
//            medication.wrappedValue.reminders[index] = updatedReminder
//            guard let medicationIndex = firebaseManager.loggedInPatient.medications.firstIndex(where: { $0.id == medication.id }) else { return }
//
//            firebaseManager.loggedInPatient.medications[medicationIndex] = medication.wrappedValue
//            // Update the medication in Firebase
//            firebaseManager.updatePatient(firebaseManager.loggedInPatient) { err in
//
//            }
//        }
//    }
//}
//
//struct PatientVerifyDosesView_Previews: PreviewProvider {
//    static var previews: some View {
//        PatientVerifyDosesView(firebaseManager: FirebaseManager())
//    }
//}
