//
//  File.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 7/8/23.
//

import Foundation
import Firebase
import SwiftUI

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager() // Singleton instance
    
    @Published var loggedInDoctor: Doctor = Doctor(id: "", email: "", name: "", contactNumber: "", specialization: .medicalSpecialist, nurses: [], patients: [])
    
    @Published var loggedInNurse: Nurse = Nurse(id: "", email: "", name: "", contactNumber: "", isAvailable: false, patients: [])
    
    @Published var loggedInPatient: Patient = Patient(id: "", email: "", name: "", contactNumber: "", assignedNurseID: "", assignedNurseName: "", medications: [], vitals: [], doctorSpecializations: [], notes: ""
    )
    
    @Published var selectedPatient: Patient = Patient(id: "", email: "", name: "", contactNumber: "", assignedNurseID: "", assignedNurseName: "", medications: [], vitals: [], doctorSpecializations: [], notes: "")
    
    @Published var selectedNurse: Nurse = Nurse(id: "", email: "", name: "", contactNumber: "", isAvailable: false, patients: [])
    
    @Published var selectedMedication: Medication = Medication(id: UUID(), name: "", dosage: "", dosageUnit: .mg, forDisease: "", reminders: [], frequency: 0, startDate: TimeInterval(), endDate: TimeInterval(), medicationState: .active)
    
    @Published var PDFUrl: URL?
    @Published var showShareSheet: Bool = false
    
    var accountListener: DatabaseHandle = DatabaseHandle()
    
    var miscellaneousListener: DatabaseHandle = DatabaseHandle()
    
    
    func fetchDoctorData(uid: String, completion: @escaping (Error?) -> Void) {
        // Fetch Doctor's data using uid from the realtime database
        // Example:
        let database = Database.database().reference()
        let doctorsRef = database.child("Doctors")
        
        doctorsRef.child(uid).observe(.value, with: { snapshot in
            if let doctorData = snapshot.value as? [String: Any] {
                guard let doctor = Doctor(dictionary: doctorData) else { return }
                // Navigate to DoctorView with the fetched doctor data
                self.loggedInDoctor = doctor
                completion(nil)
//                isLoading = false
//                isLoggedIn = true
            }
        }) { (error) in
            completion(error)
        }
    }
    
    func fetchNurseData(uid: String, completion: @escaping (Error?) -> Void) {
        // Fetch Nurse's data using uid from the realtime database
        // Example:
        let database = Database.database().reference()
        let nursesRef = database.child("Nurses")
        
        nursesRef.child(uid).observe(.value, with: { snapshot in
            if let nurseData = snapshot.value as? [String: Any] {
                guard let nurse = Nurse(dictionary: nurseData) else { return }
                // Navigate to NurseView with the fetched nurse data
                
                self.loggedInNurse = nurse
                completion(nil)
//                isLoading = false
//                isLoggedIn = true
            }
        }) { (error) in
            completion(error)
        }
    }
    
    func fetchPatientData(uid: String, completion: @escaping (Error?) -> Void) {
        // Fetch Patient's data using uid from the realtime database
        // Example:
        let database = Database.database().reference()
        let patientsRef = database.child("Patients")
        
        patientsRef.child(uid).observe(.value, with: { snapshot in
            if let patientData = snapshot.value as? [String: Any] {
                guard let patient = Patient(dictionary: patientData) else { return }
                // Navigate to PatientView with the fetched patient data
                
                self.loggedInPatient = patient
                completion(nil)
//                isLoading = false
//                isLoggedIn = true
            }
        }) { (error) in
            completion(error)
        }
    }
    
    func setupPatientListener() {
        let accountRef = Database.database().reference().child("Patients").child(loggedInPatient.id)
        accountListener = accountRef.observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String: Any] {
                guard let patient = Patient(dictionary: data) else { return }
                self.loggedInPatient = patient
            }
        })
    }
    
    func setupNurseListener() {
        let accountRef = Database.database().reference().child("Nurses").child(loggedInNurse.id)
        accountListener = accountRef.observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String: Any] {
                guard let nurse = Nurse(dictionary: data) else { return }
                self.loggedInNurse = nurse
            }
        })
    }
    
    func setupDoctorListener() {
        let accountRef = Database.database().reference().child("Doctors").child(loggedInDoctor.id)
        accountListener = accountRef.observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String: Any] {
                guard let doctor = Doctor(dictionary: data) else { return }
                self.loggedInDoctor = doctor
            }
        })
    }
    
    func setupSelectedPatientListener() {
        let accountRef = Database.database().reference().child("Patients").child(selectedPatient.id)
        miscellaneousListener = accountRef.observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String: Any] {
                guard let patient = Patient(dictionary: data) else { return }
                self.selectedPatient = patient
            }
        })
    }
    
    func setupSelectedNurseListener() {
        let accountRef = Database.database().reference().child("Nurses").child(selectedNurse.id)
        miscellaneousListener = accountRef.observe(.value, with: { snapshot in
            if let data = snapshot.value as? [String: Any] {
                guard let nurse = Nurse(dictionary: data) else { return }
                self.selectedNurse = nurse
            }
        })
    }
    
    func removeListeners() {
        if loggedInDoctor.id != "" {
            Database.database().reference().child("Doctors").child(loggedInDoctor.id).removeAllObservers()
            Database.database().reference().child("Doctors").child("nurses").removeAllObservers()
            Database.database().reference().child("Patients").removeAllObservers()
            for nurse in loggedInDoctor.nurses {
                Database.database().reference().child("Nurses").child(nurse).removeAllObservers()
            }
        }
        if loggedInNurse.id != "" {
            Database.database().reference().child("Nurses").child(loggedInNurse.id).removeAllObservers()
            Database.database().reference().child("Nurses").child("patients").removeAllObservers()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            for patient in loggedInNurse.patients {
                Database.database().reference().child("Patients").child(patient).removeAllObservers()
            }
        }
        if loggedInPatient.id != "" {
            Database.database().reference().child("Patients").child(loggedInPatient.id).removeAllObservers()
        }
        
        Database.database().reference().removeObserver(withHandle: miscellaneousListener)
    }
    
    // Update patient data on Firebase
    func updatePatient(_ patient: Patient, completion: @escaping (Error?) -> Void) {
        // Your code to update patient data in Firebase
        do {
            let patientData = try convertToDictionary(patient)
            
            let patientId = patient.id
            
            let patientsRef = Database.database().reference().child("Patients")
            let patientRef = patientsRef.child(patientId)
            
            patientRef.updateChildValues(patientData) { error, _ in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    // Update nurse data on Firebase
    func updateNurse(_ nurse: Nurse, completion: @escaping (Error?) -> Void) {
        // Your code to update nurse data in Firebase
        do {
            let nurseData = try convertToDictionary(nurse)
            
            let nurseId = nurse.id
            
            let nursesRef = Database.database().reference().child("Nurses")
            let nurseRef = nursesRef.child(nurseId)
            
            nurseRef.updateChildValues(nurseData) { error, _ in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    // Update doctor data on Firebase
    func updateDoctor(_ doctor: Doctor, completion: @escaping (Error?) -> Void) {
        // Your code to update doctor data in Firebase
        do {
            let doctorData = try convertToDictionary(doctor)
            
            let doctorId = doctor.id
            
            let doctorsRef = Database.database().reference().child("Doctors")
            let doctorRef = doctorsRef.child(doctorId)
            
            doctorRef.updateChildValues(doctorData) { error, _ in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    func pauseMedication(_ medication: Medication, completion: @escaping (Error?) -> Void) {
        guard let index = selectedPatient.medications.firstIndex(of: medication) else {
            return
        }
        
        
        // Update the medication in Firebase
        updatePatient(selectedPatient) { error in
            if error == nil {
                // Medication paused successfully
                self.selectedPatient.medications[index].medicationState = .paused
            } else {
                print("Error pausing medication: \(error?.localizedDescription ?? "")")
            }
        }
    }

    func resumeMedication(_ medication: Medication, completion: @escaping (Error?) -> Void) {
        guard let index = selectedPatient.medications.firstIndex(of: medication) else {
            return
        }
        
        selectedPatient.medications[index].medicationState = .active
        // Update the medication in Firebase
        updatePatient(selectedPatient) { error in
            if error == nil {
                // Medication resumed successfully
                self.selectedPatient.medications[index].medicationState = .active
            } else {
                print("Error resuming medication: \(error?.localizedDescription ?? "")")
            }
        }
    }

    
    func updateMedication(_ medication: Medication, patient: Patient, completion: @escaping (Error?) -> Void) {
        let patientId = patient.id
        
        let patientsRef = Database.database().reference().child("Patients")
        let patientRef = patientsRef.child(patientId)
        let medRef = patientRef.child("medications").child(medication.id.uuidString)
        
            
            let medicationDict: [String: Any] = [
                "name": medication.name,
                "dosage": medication.dosage,
                "reminders": medication.reminders.map { reminder in
                    [
                        "name": reminder.name,
                        "doseTime": reminder.doseTime,
                        "isTaken": reminder.isTaken
                    ]
                },
                "frequency": medication.frequency,
                "startDate": medication.startDate,
                "endDate": medication.endDate,
            ]
            
            medRef.updateChildValues(medicationDict) { error, _ in
                completion(error)
            }
        }
    
    // Add more functions as needed for different entities
    
    func convertToDictionary<T: Codable>(_ object: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(object)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "com.yourapp", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert object to dictionary"])
        }
        return dictionary
    }
    
    private func isDoseTimeMissed(_ doseTime: Date) -> Bool {
        let calendar = Calendar.current
        let currentDateTime = Date()
        let allowedRange = calendar.date(byAdding: .minute, value: 10, to: doseTime)
        
        return currentDateTime > allowedRange!
    }
    
    func scheduleNotifications(for patient: Patient? = nil, of medication: Medication){
        let center = UNUserNotificationCenter.current()
        var notificationIDs: [String] = []
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting authorization for notifications: \(error.localizedDescription)")
                return
            }
            if granted {
                
                let content = UNMutableNotificationContent()
                if patient != nil {
                    content.title = "Medication Reminder for \(patient!.name)"
                    content.body = "Please give \(medication.name) with a dosage of \(medication.dosage)"
                    content.sound = .default
                } else {
                    content.title = "Medication Reminder for \(medication.name)"
                    content.body = "Please ask your nurse to give \(medication.name) with a dosage of \(medication.dosage) if not already given."
                    content.sound = .default
//                    let reminders = medication.reminders.filter({ $0.isTaken == true && $0.isVerified == false })
//                    for reminderToVerify in reminders {
//                        if UserDefaults.standard.bool(forKey: reminderToVerify.id.uuidString) == false {
//                            let content = UNMutableNotificationContent()
//                            content.title = "Medication Reminder"
//                            content.body = "The nurse has given you a dose of \(medication.name). Please verify it in the app."
//                            content.sound = UNNotificationSound.default
//
//                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
//                            let request = UNNotificationRequest(identifier: reminderToVerify.id.uuidString, content: content, trigger: trigger)
//
//                            UNUserNotificationCenter.current().add(request) { error in
//                                if let error = error {
//                                    print("Error scheduling notification: \(error.localizedDescription)")
//                                } else {
//                                    // Store the reminder's identifier in UserDefaults
//                                    print("Notification scheduled for dose verification")
//                                    UserDefaults.standard.set(true, forKey: reminderToVerify.id.uuidString)
//                                }
//                            }
//                        }
//                    }
                }
                
                let calendar = Calendar.current
                
                var count = 0
                for reminder in medication.reminders {
                    if reminder.isTaken || self.isDoseTimeMissed(Date(timeIntervalSince1970: reminder.doseTime)) {
                        continue
                    }
                    count += 1
                    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date(timeIntervalSince1970: reminder.doseTime))
                    let triggerDateComponents = DateComponents(year: components.year,
                                                               month: components.month,
                                                               day: components.day,
                                                               hour: components.hour,
                                                               minute: components.minute)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
                    let notificationID = UUID().uuidString
                    notificationIDs.append(notificationID)
                    let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
                    center.add(request) { error in
                        if let error = error {
                            print("Error scheduling notification: \(error.localizedDescription)")
                        } else {
                            UserDefaults.standard.set(notificationIDs, forKey: medication.id.uuidString)
                        }
                    }
                }
            }
            
        }
        
    }
    
    func removeNotifications(for notificationIDs: [String]) {
        // Remove the notification for the reminder
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIDs)
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            
//            loggedInDoctor = nil
//            loggedInNurse = nil
//            loggedInPatient = nil
            // Navigate to ContentView
            UserDefaults.standard.removeObject(forKey: "rememberedEmail")
            UserDefaults.standard.removeObject(forKey: "rememberedPassword")
            removeListeners()
            let allScenes = UIApplication.shared.connectedScenes
            let scene = allScenes.first { $0.activationState == .foregroundActive }
                                    
            if let windowScene = scene as? UIWindowScene {
                     windowScene.keyWindow?.rootViewController? = UIHostingController(rootView: ContentView())
            }
//            UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: ContentView())
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    // Private initializer to prevent external instantiation
    init() { }
}

extension DateFormatter {
    static var userFriendly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static var dateFriendly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

