//
//  MedicationDetailView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 8/8/23.
//

import SwiftUI

enum TimeRangeOption: String, CaseIterable {
    case all = "All"
    case month = "Month"
    case date = "Date" // Add this new case

    // Add cases for other time ranges if needed
}

struct NurseMedicationDetailView: View {
    
    @ObservedObject var firebaseManager: FirebaseManager
    
    @State var medication: Medication
    
    @State private var selectedTimeRange: TimeRangeOption = .all
    @State private var selectedMonth: Int = 1 // Default to January
    @State private var selectedDate: Date = Date() // Default to today
    @State private var filteredReminders: [MedicationReminder] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Medication Details:")
                    .font(.headline)
                    .padding(.top)
                
                Text("Name: \(medication.name)")
                    .font(.subheadline)
                
                Text("Dosage: \(medication.dosage)")
                    .font(.subheadline)
                
                Text("Frequency: \(medication.frequency) times a day")
                    .font(.subheadline)
                
                Divider()
                
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
                    DatePicker("Select Date", selection: $selectedDate, in: Date(timeIntervalSince1970: medication.startDate)...Date(timeIntervalSince1970: medication.endDate) ,displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                ForEach($filteredReminders, id: \.self) { reminder in
                    let isDoseTimeWithinRange = isDoseTimeWithinAllowedRange(Date(timeIntervalSince1970: reminder.doseTime.wrappedValue))
                    let isTaken = reminder.isTaken
                    let isVerified = reminder.isVerified
                    let isMissed = isDoseTimeMissed(Date(timeIntervalSince1970: reminder.doseTime.wrappedValue))
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dose Time:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(Date(timeIntervalSince1970: reminder.doseTime.wrappedValue), formatter: DateFormatter.userFriendly)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack {
                            if isDoseTimeWithinRange && !isTaken.wrappedValue {
                                
                                ZStack {
                                    Button(action: {
                                        markDoseGiven(reminder.wrappedValue, $medication)
                                    }) {
                                        
                                    }
                                    Image("take")
                                        .resizable()
                                    //                                    .scaledToFit()
                                    //                                    .frame(width: 30, height: 30) // Adjust the size as needed
                                }
                            } else if isTaken.wrappedValue  && !isVerified.wrappedValue {
                                Image("taken")
                                    .font(.title)
                            } else if isVerified.wrappedValue {
                                Image("verified")
                                    .font(.title)
                            } else if isMissed {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
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
            }
            .padding()
        }
        .navigationBarTitle("Medication Details")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            filterReminders() // Apply initial filtering when view appears
        }
        .onChange(of: firebaseManager.selectedPatient.medications) { newValue in
            guard let _ = firebaseManager.selectedPatient.medications.first(where: { $0.id == medication.id }) else { return }
            medication = firebaseManager.selectedPatient.medications.first(where: { $0.id == medication.id })!
            filterReminders() // Apply filtering when selectedTimeRange changes
        }
        .onChange(of: selectedTimeRange) { newValue in
            filterReminders() // Apply filtering when selectedTimeRange changes
        }
        .onChange(of: selectedMonth) { newValue in
            filterReminders() // Apply filtering when selectedMonth changes
        }
        .onChange(of: selectedDate) { newValue in
            filterReminders() // Apply filtering when selectedMonth changes
        }
    }
    
    private func filterReminders() {
        let currentDate = Date()
        switch selectedTimeRange {
        case .all:
            filteredReminders = medication.reminders
        case .month:
            let components = Calendar.current.dateComponents([.year], from: currentDate)
            let year = components.year!
            let startOfMonth = Calendar.current.date(from: DateComponents(year: year, month: selectedMonth))!
            let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)!
            filteredReminders = medication.reminders.filter { reminder in
                let doseTime = Date(timeIntervalSince1970: reminder.doseTime)
                return doseTime >= startOfMonth && doseTime < nextMonth
            }
        case .date:
            let startOfDay = Calendar.current.startOfDay(for: selectedDate)
            let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate)!
            
            filteredReminders = medication.reminders.filter { reminder in
                let doseTime = Date(timeIntervalSince1970: reminder.doseTime)
                return doseTime >= startOfDay && doseTime <= endOfDay
            }
        }
    }
    
    
    
    private func isDoseTimeWithinAllowedRange(_ doseTime: Date) -> Bool {
        let calendar = Calendar.current
        let currentDateTime = Date()
        let allowedRange = calendar.date(byAdding: .minute, value: 10, to: doseTime)!
        let tenMinutesBeforeDoseTime = calendar.date(byAdding: .minute, value: -10, to: doseTime)!
        
        return currentDateTime >= tenMinutesBeforeDoseTime && currentDateTime <= allowedRange
    }
    
    private func isDoseTimeMissed(_ doseTime: Date) -> Bool {
        let calendar = Calendar.current
        let currentDateTime = Date()
        let allowedRange = calendar.date(byAdding: .minute, value: 10, to: doseTime)
        
        return currentDateTime > allowedRange!
    }
    
    private func markDoseGiven(_ reminder: MedicationReminder, _ medication: Binding<Medication>) {
        // Create a mutable copy of the reminder
        var updatedReminder = reminder
        updatedReminder.isTaken = true
        
        // Update the reminder in the medication's reminders array
        if let index = medication.wrappedValue.reminders.firstIndex(where: { $0.id == updatedReminder.id }) {
            medication.wrappedValue.reminders[index] = updatedReminder
            //            medication.wrappedValue.takenCount += 1
            guard let medicationIndex = firebaseManager.selectedPatient.medications.firstIndex(where: { $0.id == medication.id }) else { return }
            
            firebaseManager.selectedPatient.medications[medicationIndex] = medication.wrappedValue
            // Update the medication in Firebase
            firebaseManager.updatePatient(firebaseManager.selectedPatient) { err in
                
            }
        }
    }
    
    // ... (isDoseTimeWithinAllowedRange and markDoseGiven functions remain the same)
}

struct NurseMedicationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NurseMedicationDetailView(firebaseManager: FirebaseManager(), medication: Medication(id: UUID(), name: "Medication 1", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: true, isVerified: true)], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active))
    }
}
