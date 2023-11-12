//
//  PatientMedicalHistoryReportView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 10/8/23.
//

import SwiftUI
import PDFKit
import SwiftUICharts


extension View {
    
    func convertToScrollView<Content: View>(@ViewBuilder content: @escaping ()->Content)->UIScrollView {
        let scrollView = UIScrollView()
        
        let hostingController = UIHostingController(rootView: content()).view!
        hostingController.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            hostingController.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            hostingController.widthAnchor.constraint(equalToConstant: screenBounds().width)
        ]
        
        scrollView.addSubview(hostingController)
        scrollView.addConstraints(constraints)
        
        scrollView.layoutIfNeeded()
        
        
        
        return scrollView
    }
    
    func exportPDF<Content: View>(@ViewBuilder content: @escaping ()->Content, completion: @escaping (Bool, URL?)->()) {
        
        
        let documentDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let formattedDate = dateFormatter.string(from: Date())
        let outputFileURL = documentDirectory.appendingPathComponent("\(formattedDate).pdf")
        
        let pdfView = convertToScrollView {
            content()
        }
        pdfView.tag = 1009
        let size = pdfView.contentSize
        pdfView.frame = CGRect(x: 0, y: getSafeArea().top, width: size.width, height: size.height)
        
        getRootController().view.insertSubview(pdfView, at: 0)
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        do {
            try renderer.writePDF(to: outputFileURL, withActions: { context in
                context.beginPage()
                pdfView.layer.render(in: context.cgContext)
            })
            
            completion(true, outputFileURL)
        } catch {
            completion(false, nil)
            print(error.localizedDescription)
        }
        
        getRootController().view.subviews.forEach { view in
            if view.tag == 1009 {
                print("Removed")
                view.removeFromSuperview()
            }
        }
    }
    
    func screenBounds()->CGRect {
        return UIScreen.main.bounds
    }
    
    func getRootController()->UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
    
    func getSafeArea()->UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        
        return safeArea
    }
    
}

struct PatientMedicalHistoryReportView: View {
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
                        MedicationDonutChartView(medications: firebaseManager.loggedInPatient.medications)
                    }
                    ForEach(firebaseManager.loggedInPatient.medications) { medication in
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
                    ForEach(firebaseManager.loggedInPatient.vitals) { vital in
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
        .onChange(of: firebaseManager.loggedInPatient.vitals) { _ in
            sortVitals()
        }

    }
    
    private func sortVitals() {
        heartRate = firebaseManager.loggedInPatient.vitals.filter({ $0.type.rawValue == "Heart Rate"})
        bloodPressure = firebaseManager.loggedInPatient.vitals.filter({ $0.type.rawValue == "Blood Pressure"})
        bloodSugar = firebaseManager.loggedInPatient.vitals.filter({ $0.type.rawValue == "Blood Sugar"})
        
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

struct PatientMedicalHistoryReportView_Previews: PreviewProvider {
    static var previews: some View {
        PatientMedicalHistoryReportView(firebaseManager: FirebaseManager())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var urls: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: urls, applicationActivities: nil)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        
    }
}
