//
//  PatientView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 7/8/23.
//

import SwiftUI
import Firebase

struct PatientView: View {
    
    @ObservedObject var firebaseManager: FirebaseManager
    
    @State var dosesToVerify: Bool = false
    
    var body: some View {
//        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // Perform logout action here
                        firebaseManager.logout()
                    }) {
                        Image(systemName: "arrow.forward.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    .padding()
                }
                Text("Welcome, \(firebaseManager.loggedInPatient.name)")
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                
                Spacer()
                
                VStack(spacing: 20) {
                    DashboardButton(destination: PatientMedicationsView(firebaseManager: firebaseManager), title: "View Medication History")
                    DashboardButton(destination: PatientVitalsView(firebaseManager: firebaseManager), title: "View Vitals")
//                    DashboardButton(destination: PatientGraphView(firebaseManager: firebaseManager), title: "View Graph")
                    
                    if dosesToVerify {
                        DashboardButton(destination: PatientVerifyDosesView(firebaseManager: firebaseManager), title: "Verify Doses")
                    }
                    
                    DashboardButton(destination: PatientMedicalHistoryReportView(firebaseManager: firebaseManager), title: "Generate Report")
                }
                .padding()
                
                Spacer()
                
            }
            .navigationBarTitle("Patient Dashboard")
//            .navigationBarItems(trailing: Button(action: {
//                // Perform logout action here
//                firebaseManager.logout()
//            }) {
//                Text("Logout")
//                    .foregroundColor(.blue)
//            })
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
//        }
        .navigationBarHidden(true)
        .onAppear {
            createMedicationReminders(of: firebaseManager.loggedInPatient.medications)
            checkForDosesToVerify()
            firebaseManager.setupPatientListener()
        }
        .onChange(of: firebaseManager.loggedInPatient.medications) { newValue in
            createMedicationReminders(of: firebaseManager.loggedInPatient.medications)
            DispatchQueue.global().async  {
                checkForDosesToVerify()
            }
        }
    }
    
//    private func checkForDosesToVerify() {
//        for medication in $firebaseManager.loggedInPatient.medications {
//            if medication.reminders.filter( { $0.wrappedValue.isTaken == true && $0.wrappedValue.isVerified == false }).count != 0 {
//                dosesToVerify = true
//                return
//            }
//        }
//        dosesToVerify = false
//    }
    
    private func checkForDosesToVerify() {
        var ver = false
        for medication in $firebaseManager.loggedInPatient.medications {
            let reminders = medication.reminders.filter({ $0.wrappedValue.isTaken == true && $0.wrappedValue.isVerified == false })
            for reminderToVerify in reminders {
                ver = true
                if UserDefaults.standard.bool(forKey: reminderToVerify.id.uuidString) == false {
                    scheduleVerificationNotification(medicationName: medication.name.wrappedValue, reminderID: reminderToVerify.id)
                    //                    return
                }
            }
        }
        dosesToVerify = ver
    }

    
    private func scheduleVerificationNotification(medicationName: String, reminderID: UUID) {
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "The nurse has given you a dose of \(medicationName). Please verify it in the app."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: reminderID.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                // Store the reminder's identifier in UserDefaults
                UserDefaults.standard.set(true, forKey: reminderID.uuidString)
            }
        }
    }
    
    private func createMedicationReminders(of medications: [Medication]) {
        for medication in medications {
            let notificationIDs = UserDefaults.standard.value(forKey: medication.id.uuidString) as? [String] ?? []
            firebaseManager.removeNotifications(for: notificationIDs)
            if medication.medicationState == .active {
                firebaseManager.scheduleNotifications(of: medication)
            }
        }
    }

}

struct DashboardButton<Destination: View>: View {
    let destination: Destination
    let title: String
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)
        }
    }
}

struct PatientView_Previews: PreviewProvider {
    static var previews: some View {
        PatientView(firebaseManager: FirebaseManager())
    }
}
