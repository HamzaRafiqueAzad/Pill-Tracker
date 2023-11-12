////
////  PatientGraphView.swift
////  Pill Tracker
////
////  Created by Hamza Rafique Azad on 10/8/23.
////
//
//import SwiftUI
//import Charts
//
//struct PatientGraphView: View {
//    
//    @ObservedObject var firebaseManager: FirebaseManager
//    
//    @State private var heartRate: [Vital] = []
//    @State private var bloodPressure: [Vital] = []
//    @State private var bloodSugar: [Vital] = []
//    
//    @State private var vitalsData: [(type: String, data: [Vital])] = [
//        (type: "Heart Rate", data: []),
//        (type: "Blood Pressure", data: []),
//        (type: "Blood Sugar", data: []),
//    ]
//
//    
//    @State private var meds: [Double] = []
//    
//    @State private var names: [String] = []
//
//    
//    var body: some View {
//        VStack {
//            GroupBox ("Line Graph - Medications") {
////                PieChartView(values: meds, names: firebaseManager.loggedInPatient.medications.map({ $0.name }), formatter: {value in String(format: "$%.2f", value)})
//            }
////            .frame(height: 300)
//            
//            GroupBox ("Bar Graph - Vitals") {
//                Chart {
//                    ForEach($vitalsData.wrappedValue, id: \.type) { vitals in
//                        ForEach(vitals.data) { vital in
//                            BarMark (
//                                x: .value("Date", formattedDate(Date(timeIntervalSince1970: vital.date))),
//                                y: .value("Value", Int(vital.value))
//                            )
//                        }
//                        .foregroundStyle(by: .value("Type", vitals.type))
//                        .position(by: .value("Type", vitals.type))
//                    }
//                }
//            }
//            .frame(height: 300)
//
//
////            Chart(vitalsData, id: \.period) { steps in
////                ForEach(steps.data) {
////                    BarMark(
////                        x: .value("Date", $0.date),
////                        y: .value("Value", $0.value)
////                    )
////                    .foregroundStyle(by: .value("Type", steps.period))
////                }
////            }
////            .frame(height: 300)
//        }
//        .padding()
//        .onAppear{
//            sortVitals()
//        }
//        .onChange(of: firebaseManager.loggedInPatient.vitals) { _ in
//            sortVitals()
//        }
//    }
//    
//    private func sortVitals() {
//        heartRate = firebaseManager.loggedInPatient.vitals.filter({ $0.type.rawValue == "Heart Rate"})
//        bloodPressure = firebaseManager.loggedInPatient.vitals.filter({ $0.type.rawValue == "Blood Pressure"})
//        bloodSugar = firebaseManager.loggedInPatient.vitals.filter({ $0.type.rawValue == "Blood Sugar"})
//        
//        vitalsData = [
//            (type: "Heart Rate", data: heartRate),
//            (type: "Blood Pressure", data: bloodPressure),
//            (type: "Blood Sugar", data: bloodSugar),
//        ]
////        let takenReminderCounts = firebaseManager.loggedInPatient.medications.map { medication in
////            return medication.reminders.filter { $0.isTaken }.count
////        }
//        firebaseManager.loggedInPatient.medications.forEach { medication in
//            meds.append(Double(medication.reminders.count))
//        }
//        
//
//    }
//    
//    private func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
//}
//
//
//struct PatientGraphView_Previews: PreviewProvider {
//    static var previews: some View {
//        PatientGraphView(firebaseManager: FirebaseManager())
//    }
//}
