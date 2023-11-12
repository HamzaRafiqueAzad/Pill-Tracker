//
//  PatientMedicationsView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 7/8/23.
//

import SwiftUI

struct DoctorPatientMedicationHistoryView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    
    @State private var selectedTimeRange: TimeRangeOption = .all
    @State private var selectedMonth: Int = 1 // Default to January
    @State private var selectedDate: Date = Date() // Default to today
    @State private var filteredVitals: [Vital] = [] // State variable for filtered and sorted vitals

    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Section(header: Text("Medication History")
                    .font(.headline)
                    .foregroundColor(.primary)) {
                        ForEach(firebaseManager.selectedPatient.medications, id: \.self) { medication in
                            NavigationLink(destination: DoctorMedicationDetailView(firebaseManager: firebaseManager, medication: medication)) {
                                DoctorMedicationRowView(firebaseManager: firebaseManager, entry: medication)
                            }
                        }
                    }
                
                Divider()
                
                Section(header: Text("Vitals")
                    .font(.headline)
                    .foregroundColor(.primary)) {
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
                            if firebaseManager.selectedPatient.vitals.count > 0 {
                                DatePicker("Select Date", selection: $selectedDate, in: Date(timeIntervalSince1970: firebaseManager.selectedPatient.vitals.sorted(by: { vital1, vital2 in
                                    return vital1.date < vital2.date
                                })[0].date)...Date(timeIntervalSince1970: firebaseManager.selectedPatient.vitals.sorted(by: { vital1, vital2 in
                                    return vital1.date < vital2.date
                                }).last!.date) ,displayedComponents: .date)
                                    .datePickerStyle(.compact)
                            }
                        }
                        
                        ForEach(filteredVitals, id: \.self) { vital in
                            DoctorVitalRowView(firebaseManager: firebaseManager, vital: vital)
                        }
                    }
            }
            .padding()
        }
        .navigationBarTitle("\(firebaseManager.selectedPatient.name) History")
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
        }.onChange(of: selectedDate) { newValue in
            filterVitals() // Apply filtering when selectedMonth changes
        }
    }
    
    // Filter and sort vitals based on selectedDateFilter
    private func filterVitals() {
        let currentDate = Date()
        switch selectedTimeRange {
        case .all:
            filteredVitals = firebaseManager.selectedPatient.vitals
        case .month:
            let components = Calendar.current.dateComponents([.year], from: currentDate)
            let year = components.year!
            let startOfMonth = Calendar.current.date(from: DateComponents(year: year, month: selectedMonth))!
            let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: startOfMonth)!
            filteredVitals = firebaseManager.selectedPatient.vitals.filter { vital in
                let vitalTime = Date(timeIntervalSince1970: vital.date)
                return vitalTime >= startOfMonth && vitalTime < nextMonth
            }
            
        case .date:
            let startOfDay = Calendar.current.startOfDay(for: selectedDate)
            let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate)!
            
            filteredVitals = firebaseManager.selectedPatient.vitals.filter { vital in
                let vitalTime = Date(timeIntervalSince1970: vital.date)
                return vitalTime >= startOfDay && vitalTime <= endOfDay
            }
        }
    }
    
//    private func filteredVitals() -> [Vital] {
//        switch selectedFilterOption {
//        case .all:
//            return firebaseManager.selectedPatient.vitals
//        case .last7Days:
//            let last7Days = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
//            return firebaseManager.selectedPatient.vitals.filter { $0.date >= last7Days.timeIntervalSince1970 }
//        case .last30Days:
//            let last30Days = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
//            return firebaseManager.selectedPatient.vitals.filter { $0.date >= last30Days.timeIntervalSince1970 }
//        }
//    }
}

enum DateFilterOption: String, CaseIterable, Identifiable {
    case all = "All"
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    case lastYear = "Last Year"

    var id: String { self.rawValue }
}

enum FilterOption: String, CaseIterable {
    case all = "All"
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
}

struct DoctorPatientMedicationHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorPatientMedicationHistoryView(firebaseManager: FirebaseManager())
    }
}
