////
////  ReportView.swift
////  Pill Tracker
////
////  Created by Hamza Rafique Azad on 7/8/23.
////
//
//import SwiftUI
//
//struct PatientReportView: View {
//    @State var patient: Patient
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                Text("Patient Report")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding(.bottom, 10)
//                
//                Text("Patient Name: \(patient.name)")
//                    .font(.headline)
//                Text("Contact Number: \(patient.contactNumber)")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                
//                Spacer()
//                    .frame(height: 10)
//                
//                Text("Medication History")
//                    .font(.headline)
//                ForEach(patient.medications) { medication in
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text("Medication: \(medication.name)")
//                        Text("Dosage: \(medication.dosage)")
//                        Text("Date: \(Date(timeIntervalSince1970: medication.startDate), formatter: DateFormatter.userFriendly)")
//                        Text("Taken Count: \(medication.reminders.filter({ $0.isTaken == true }).count)")
//                        Text("Remaining Count: \(medication.reminders.filter({ $0.isTaken == false }).count)")
//                    }
//                    .padding(10)
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    .shadow(radius: 3)
//                }
//                
//                Spacer()
//                    .frame(height: 10)
//                
//                Text("Vital Signs")
//                    .font(.headline)
//                ForEach(patient.vitals) { vital in
//                    VStack(alignment: .leading, spacing: 5) {
//                        Text("Type: \(vital.type.rawValue)")
//                        Text("Value: \(vital.value)")
//                        Text("Date: \(Date(timeIntervalSince1970: vital.date), formatter: DateFormatter.userFriendly)")
//                    }
//                    .padding(10)
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    .shadow(radius: 3)
//                }
//                
//                NavigationLink(destination: PatientPDFReportView(patient: patient)) {
//                    Text("Generate PDF Report")
//                        .font(.headline)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//
//
//struct PatientReportView_Previews: PreviewProvider {
//    static var previews: some View {
//        let medications = [
//            Medication(id: UUID(), name: "Medication 1", dosage: "10mg", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970,),
//            Medication(id: UUID(), name: "Medication 2", dosage: "5mg", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970)
//            // Add more sample medication history entries
//        ]
//        
//        let sampleVitals: [Vital] = [
//            Vital(id: UUID(), type: .heartRate, value: 75, date: Date().timeIntervalSince1970),
//            Vital(id: UUID(), type: .bloodPressure, value: 120/80, date: Date().timeIntervalSince1970),
//            Vital(id: UUID(), type: .bloodSugar, value: 100, date: Date().timeIntervalSince1970)
//            // Add more sample vitals data if needed
//        ]
//        
//        let samplePatient = Patient(id: "uid", email: "patient@gmail.com", name: "Patient Doe", contactNumber: "123-456-7890", assignedNurseID: "", medications: medications,vitals: sampleVitals, doctorSpecializations: [])
//        PatientReportView(patient: samplePatient)
//    }
//}
