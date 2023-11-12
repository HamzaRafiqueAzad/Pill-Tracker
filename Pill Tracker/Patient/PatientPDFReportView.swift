////
////  PDFReportView.swift
////  Pill Tracker
////
////  Created by Hamza Rafique Azad on 7/8/23.
////
//
//import SwiftUI
//import PDFKit
//
//struct PDFReport: UIViewRepresentable {
//    let pdfData: Data
//    
//    func makeUIView(context: Context) -> PDFView {
//        let pdfView = PDFView()
//        pdfView.document = PDFDocument(data: pdfData)
//        return pdfView
//    }
//    
//    func updateUIView(_ uiView: PDFView, context: Context) {
//        uiView.document = PDFDocument(data: pdfData)
//    }
//}
//
//struct PatientPDFReportView: View {
//    @State private var isPDFGenerated = false
//    
//    @State var patient: Patient
//    
//    var body: some View {
//        VStack {
//            Text("Generate PDF Report")
//                .font(.largeTitle)
//                .padding()
//            
//            Button("Generate PDF") {
//                isPDFGenerated.toggle()
//            }
//            
//            if isPDFGenerated {
//                PDFReport(pdfData: generatePDF())
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//        }
//    }
//    
//    private func generatePDF() -> Data {
//        let pdfDocument = PDFDocument()
//        
//        // Create PDF content using patient data
//        var pdfText = ""
//        pdfText += "Patient Name: \(patient.name)\n"
//        pdfText += "Contact Number: \(patient.contactNumber)\n"
//        pdfText += "Medication History:\n"
//        for medication in patient.medications {
//            pdfText += "- \(medication.name), Dosage: \(medication.dosage), Taken: \(medication.takenCount), Remaining: \(medication.remainingCount)\n"
//        }
//        pdfText += "Vitals:\n"
//        for vital in patient.vitals {
//            pdfText += "- \(vital.type.rawValue): \(vital.value)\n"
//        }
//        
//        let pdfPageBounds = CGRect(x: 0, y: 0, width: 612, height: 792)
//        let pdfData = pdfText.data(using: .utf8)!
//        let pdfString = NSMutableAttributedString(string: pdfText)
//        let pdfAttributedString = try? NSAttributedString(data: pdfData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
//        pdfString.setAttributedString(pdfAttributedString ?? NSAttributedString())
//        
//        UIGraphicsBeginPDFContextToData(pdfData as! NSMutableData, pdfPageBounds, nil)
//        UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
//        let context = UIGraphicsGetCurrentContext()!
//        
//        pdfString.draw(in: pdfPageBounds)
//        
//        UIGraphicsEndPDFContext()
//        
//        return pdfData
//    }
//
//}
//
//
//struct PatientPDFReportView_Previews: PreviewProvider {
//    static var previews: some View {
//        let medications = [
//            Medication(id: UUID(), name: "Medication 1", dosage: "10mg", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, takenCount: 2, remainingCount: 9),
//            Medication(id: UUID(), name: "Medication 2", dosage: "5mg", reminders: [], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, takenCount: 2, remainingCount: 9)
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
//        PatientPDFReportView(patient: samplePatient)
//    }
//}
