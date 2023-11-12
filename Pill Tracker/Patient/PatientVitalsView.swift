//
//  VitalsView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 7/8/23.
//

import SwiftUI

struct PatientVitalsView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    
    @State private var selectedTimeRange: TimeRangeOption = .all
    @State private var selectedMonth: Int = 1 // Default to January
    @State private var selectedDate: Date = Date() // Default to today
    @State private var filteredVitals: [Vital] = [] // State variable for filtered and sorted vitals
    
    var body: some View {
        ScrollView {
            VStack {
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
                    if firebaseManager.loggedInPatient.vitals.count > 0 {
                        DatePicker("Select Date", selection: $selectedDate, in: Date(timeIntervalSince1970: firebaseManager.loggedInPatient.vitals.sorted(by: { vital1, vital2 in
                            return vital1.date < vital2.date
                        })[0].date)...Date(timeIntervalSince1970: firebaseManager.loggedInPatient.vitals.sorted(by: { vital1, vital2 in
                            return vital1.date < vital2.date
                        }).last!.date), displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                }
                
                ForEach($filteredVitals, id: \.self) { $vital in
                    PatientVitalRowView(vital: $vital)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .navigationBarTitle("Vitals History")
        .foregroundColor(Color.secondary)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            filterVitals() // Filter vitals when the view appears
        }
        .onChange(of: selectedTimeRange) { newValue in
            filterVitals() // Apply filtering when selectedTimeRange changes
        }
        .onChange(of: selectedMonth) { newValue in
            filterVitals() // Apply filtering when selectedMonth changes
        }
        .onChange(of: selectedDate) { newValue in
            filterVitals() // Apply filtering when selectedMonth changes
        }
    }
    
    // Filter and sort vitals based on selectedDateFilter
    private func filterVitals() {
        let currentDate = Date()
        switch selectedTimeRange {
        case .all:
            filteredVitals = firebaseManager.loggedInPatient.vitals
        case .month:
            let components = Calendar.current.dateComponents([.year], from: currentDate)
            let year = components.year!
            let startOfMonth = Calendar.current.date(from: DateComponents(year: year, month: selectedMonth))!
            let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)!
            filteredVitals = firebaseManager.loggedInPatient.vitals.filter { vital in
                let vitalTime = Date(timeIntervalSince1970: vital.date)
                return vitalTime >= startOfMonth && vitalTime < nextMonth
            }
        case .date:
            let startOfDay = Calendar.current.startOfDay(for: selectedDate)
            let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate)!
            
            filteredVitals = firebaseManager.loggedInPatient.vitals.filter { vital in
                let vitalTime = Date(timeIntervalSince1970: vital.date)
                return vitalTime >= startOfDay && vitalTime <= endOfDay
            }
        }
    }
}

struct PatientVitalsView_Previews: PreviewProvider {
    static var previews: some View {
        
        return PatientVitalsView(firebaseManager: FirebaseManager())
    }
}


