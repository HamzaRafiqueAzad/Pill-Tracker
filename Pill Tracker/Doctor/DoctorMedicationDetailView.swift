//
//  DoctorMedicationDetailView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 16/8/23.
//

import SwiftUI

struct DoctorMedicationDetailView: View {
    
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
                    let isTaken = reminder.isTaken
                    let isVerified = reminder.isVerified
                    let isMissed = isDoseTimeMissed(Date(timeIntervalSince1970: reminder.doseTime.wrappedValue))

                    HStack {
                        Text("Dose Time: \(Date(timeIntervalSince1970: reminder.doseTime.wrappedValue), formatter: DateFormatter.userFriendly)")
                            .font(.subheadline)

                        Spacer()
                        
                        if isTaken.wrappedValue  && !isVerified.wrappedValue {
                            Image("taken")
                                .font(.title)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 30, height: 30) // Adjust the size as needed
                        } else if isVerified.wrappedValue {
                            Image("verified")
                                .font(.title)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 30, height: 30) // Adjust the size as needed
                        } else if isMissed {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
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
        .navigationViewStyle(.stack)
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

    private func isDoseTimeMissed(_ doseTime: Date) -> Bool {
        let calendar = Calendar.current
        let currentDateTime = Date()
        let allowedRange = calendar.date(byAdding: .minute, value: 10, to: doseTime)
        
        return currentDateTime > allowedRange!
    }
}

struct DoctorMedicationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorMedicationDetailView(firebaseManager: FirebaseManager(), medication: Medication(id: UUID(), name: "Medication 1", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active))
    }
}
