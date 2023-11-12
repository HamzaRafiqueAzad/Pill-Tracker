//
//  NurseGenerateReportView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 23/8/23.
//

import SwiftUI

struct NurseGenerateReportView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    
    @State var PDFUrl: URL?
    @State var showShareSheet: Bool = false
    
    @State private var vitalsData: [(type: String, data: [Vital])] = [
        (type: "Heart Rate", data: []),
        (type: "Blood Pressure", data: []),
        (type: "Blood Sugar", data: []),
    ]
    
    @State private var heartRate: [Vital] = []
    @State private var bloodPressure: [Vital] = []
    @State private var bloodSugar: [Vital] = []
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Medical History Report")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)
                
                Section(header: Text("Medications")
                    .font(.headline)
                    .foregroundColor(Color.red)) {
                    VStack {
                        MedicationDonutChartView(medications: firebaseManager.selectedPatient.medications)
                    }
                    ForEach(firebaseManager.selectedPatient.medications) { medication in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Medication: \(medication.name)")
                                .font(.headline)
                            Text("Dosage: \(medication.dosage)")
                            Text("Start Date: \(formattedDate(Date(timeIntervalSince1970: medication.startDate)))")
                            Text("End Date: \(formattedDate(Date(timeIntervalSince1970: medication.endDate)))")
                            Text("Taken Count: \(medication.reminders.filter({ $0.isTaken == true }).count)")
                            Text("Remaining Count: \(medication.reminders.filter({ $0.isTaken == false }).count)")
                            Divider()
                        }
                    }
                }
                
                Spacer()
                
                Section(header: Text("Vital Signs")
                    .font(.headline)
                    .foregroundColor(Color.red)) {
                    ForEach(firebaseManager.selectedPatient.vitals) { vital in
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Type: \(vital.type.rawValue)")
                                .font(.headline)
                            Text("Value: \(Int(vital.value))")
                            Text("Date: \(formattedDate(Date(timeIntervalSince1970: vital.date)))")
                            Divider()
                        }
                    }
                }
                
            }
            .padding(20)
        }
        .navigationBarItems(trailing: Button(action: {
            exportPDF {
                self.environmentObject(firebaseManager)
            } completion: { status, url in
                if let url = url, status {
                    firebaseManager.PDFUrl = url
                    firebaseManager.showShareSheet.toggle()
                } else {
                    print("Failed")
                }
            }
        }) {
            Image(systemName: "square.and.arrow.up.fill")
                .font(.title2)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $firebaseManager.showShareSheet) {
            firebaseManager.PDFUrl = nil
        } content: {
            if let PDFUrl = firebaseManager.PDFUrl {
                ShareSheet(urls: [PDFUrl])
            }
        }
        .onAppear{
            sortVitals()
        }
        .onChange(of: firebaseManager.selectedPatient.vitals) { _ in
            sortVitals()
        }

    }
    
    private func sortVitals() {
        heartRate = firebaseManager.selectedPatient.vitals.filter({ $0.type.rawValue == "Heart Rate"})
        bloodPressure = firebaseManager.selectedPatient.vitals.filter({ $0.type.rawValue == "Blood Pressure"})
        bloodSugar = firebaseManager.selectedPatient.vitals.filter({ $0.type.rawValue == "Blood Sugar"})
        
        vitalsData = [
            (type: "Heart Rate", data: heartRate),
            (type: "Blood Pressure", data: bloodPressure),
            (type: "Blood Sugar", data: bloodSugar),
        ]
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct NurseGenerateReportView_Previews: PreviewProvider {
    static var previews: some View {
        NurseGenerateReportView(firebaseManager: FirebaseManager())
    }
}

