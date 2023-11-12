//
//  SignUpView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import SwiftUI
import Firebase

struct User {
    var uid: String
    var email: String
    var password: String
    var name: String
    var role: UserRole
    var contactNumber: String
    // Add more properties as needed
}

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var contactNumber = ""
    @State private var selectedRole = UserRole.doctor
    @State private var specialization: DoctorSpecialization = .medicalSpecialist
    
    
    @State private var isPasswordMatch = true
    @State private var isValidEmail = true
    @State private var isValidPassword = true
    @State private var isValidContact = true
    @State private var isSignedUp = false
    @State private var isLoading = false
    
    @State private var rememberMe = false
    @State private var errorMessage = ""
    
    @State private var showErrorAlert = false
    
    @ObservedObject var firebaseManager: FirebaseManager
    
    
    var body: some View {
        if isSignedUp {
            switch selectedRole {
            case .doctor:
                DoctorView(firebaseManager: firebaseManager)
            case .nurse:
                NurseView(firebaseManager: firebaseManager)
            case .patient:
                PatientView(firebaseManager: firebaseManager)
            }
        } else {
            NavigationView {
                ScrollView {
                    VStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 20) {
                            VStack {
                                CustomTextField(title: "Full Name", text: $name)
                                
                                CustomTextField(title: "Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .onChange(of: email, perform: { newValue in
                                        isValidEmail(email)
                                    })
                                if !isValidEmail {
                                    Text("Email format not correct.")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                
                                CustomSecureField(title: "Password", text: $password)
                                    .onChange(of: password, perform: { newValue in
                                        isValidPassword(password)
                                    })
                                if !isValidPassword {
                                    Text("Passwords must be 8 characters long and must contain uppercase and lowercase letters.")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                
                                CustomSecureField(title: "Confirm Password", text: $confirmPassword)
                                    .onChange(of: confirmPassword, perform: { newValue in
                                        validatePassword()
                                    })
                                    .foregroundColor(isPasswordMatch ? Color.primary : Color.red)
                                if !isPasswordMatch {
                                    Text("Passwords do not match")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                
                                CustomTextField(title: "Contact Number", text: $contactNumber)
                                    .keyboardType(.phonePad)
                                    .onChange(of: contactNumber, perform: { newValue in
                                        isValidContactNumber(contactNumber)
                                    })
                                if !isValidContact {
                                    Text("Contact not valid format.")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                            
                            
                            Picker("Role", selection: $selectedRole) {
                                ForEach(UserRole.allCases, id: \.self) { role in
                                    Text(role.rawValue).tag(role)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            if selectedRole == .doctor {
                                HStack {
                                    Text("Specialization: ")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Picker("Specialization", selection: $specialization) {
                                        ForEach(DoctorSpecialization.allCases) { specialization in
                                            Text(specialization.rawValue)
                                                .font(.subheadline)
                                                .foregroundColor(Color.secondary)
                                                .tag(specialization)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                    )
                                    .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
                                }
                            }
                            
                            Toggle("Remember Me", isOn: $rememberMe)
                                .foregroundColor(.primary)
                                .padding(.top, 8)
                            
                            if errorMessage != "" {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.bottom, 20)
                            }
                            
                            Button {
                                signUp()
                            } label: {
                                Text("Sign Up")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill((isLoading || password != confirmPassword || name.isEmpty || email.isEmpty || password.isEmpty || contactNumber.isEmpty || !isValidEmail || !isValidPassword || !isValidContact) ? Color.blue.opacity(0.2) : Color.blue)
                                            .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                                    )
                                    .foregroundColor(.white)
                            }
                            .disabled(isLoading || password != confirmPassword || name.isEmpty || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || email.isEmpty || password.isEmpty || contactNumber.isEmpty || !isValidEmail || !isValidPassword || !isValidContact)
                            
                        }
                        .padding(20)
                        Spacer()
                    }
                }
                .navigationBarTitle("Sign Up")
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .edgesIgnoringSafeArea(.all)
                )
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .overlay {
                if isLoading {
                    ProgressView("Signing Up...")
                }
            }
            .disabled(isLoading)
        }
    }
    
    func isValidEmail(_ email: String) {
        // Regular expression pattern to validate email format
        let emailPattern = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        isValidEmail = emailPredicate.evaluate(with: email)
    }
    
    func isValidContactNumber(_ contact: String) {
            // Regular expression pattern to validate contact number format
            let contactNumberPattern = "^[0-9]{11}$" // Assuming contact number is 10 digits
            let contactNumberPredicate = NSPredicate(format: "SELF MATCHES %@", contactNumberPattern)
            isValidContact =  contactNumberPredicate.evaluate(with: contact)
        }

    func isValidPassword(_ password: String) {
            // Regular expression pattern to validate password format
            let passwordPattern = "^(?=.*[a-z])(?=.*[A-Z]).{8,}$" // At least 8 characters with both upper and lower case
            let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordPattern)
            isValidPassword = passwordPredicate.evaluate(with: password)
        }
    
    func validatePassword() {
        isPasswordMatch = password == confirmPassword
    }
    
    func signUp() {
        isLoading = true
        if password != confirmPassword || name.isEmpty || email.isEmpty || password.isEmpty || contactNumber.isEmpty {
            // Handle password mismatch error
            errorMessage = "Password mismatch"
            isLoading = false
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle signup error
                errorMessage = "Signup Error: \(error.localizedDescription)"
                isLoading = false
                return
            }
            errorMessage = ""
            // Save user's "Remember Me" preference if they want to be remembered
            if rememberMe {
                UserDefaults.standard.set(email, forKey: "rememberedEmail")
                UserDefaults.standard.set(password, forKey: "rememberedPassword")
            }
            
            // Signup successful, save user details to Realtime Database and navigate to respective view
            if let uid = authResult?.user.uid {
                // Prepare user data
                let userData: [String: Any] = [
                    "email": email,
                    "role": selectedRole.rawValue
                    // Add other user-specific data here
                ]
                // Add the user ID to the "Users" collection for tracking
                let database = Database.database().reference()
                let usersRef = database.child("Users")
                usersRef.child(uid).setValue(userData) { error, _ in
                    if let error = error {
                        print("Error: \(error)")
                    } else {
                        print("Success")
                    }
                }
                let newUser = createUserFromSelectedRole(uid: uid)
                switch newUser {
                case is Doctor:
                    saveUserToRealtimeDatabase(newUser as! Doctor, branchName: "Doctors", uid)
                    break
                case is Nurse:
                    saveUserToRealtimeDatabase(newUser as! Nurse, branchName: "Nurses", uid)
                    break
                case is Patient:
                    saveUserToRealtimeDatabase(newUser as! Patient, branchName: "Patients", uid)
                    break
                default:
                    return
                }
            }
        }
    }
    
    func createUserFromSelectedRole(uid: String) -> Any {
        switch selectedRole {
        case .doctor:
            return Doctor(id: uid, email: email, name: name, contactNumber: contactNumber, specialization: specialization, nurses: [], patients: [])
        case .nurse:
            return Nurse(id: uid, email: email, name: name, contactNumber: contactNumber, isAvailable: true, patients: [])
        case .patient:
            return Patient(id: uid, email: email, name: name, contactNumber: contactNumber, assignedNurseID: "", assignedNurseName: "", medications: [], vitals: [], doctorSpecializations: [], notes: "")
        }
    }
    
    func saveUserToRealtimeDatabase<T: Codable>(_ user: T, branchName: String,_ uid: String) {
        let database = Database.database().reference()
        let usersRef = database.child(branchName)
        
        let userRef = usersRef.child(uid)
        
        do {
            let userJSON = try JSONEncoder().encode(user)
            if let userDict = try JSONSerialization.jsonObject(with: userJSON, options: []) as? [String: Any] {
                userRef.setValue(userDict) { error, _ in
                    if let error = error {
                        print("Error saving user to Realtime Database: \(error.localizedDescription)")
                    } else {
                        print("User saved to Realtime Database successfully")
                        // Navigate to respective dashboard based on user's role
                        switch selectedRole {
                        case .doctor:
                            firebaseManager.fetchDoctorData(uid: uid) { err in
                                if err == nil {
                                    isLoading = false
                                    isSignedUp = true
                                } else {
                                    // If an error occurs:
                                    isLoading = false
                                    showErrorAlert = true
                                    errorMessage = "Failed to fetch data. Please try again."
                                }
                            }
                        case .nurse:
                            firebaseManager.fetchNurseData(uid: uid) { err in
                                if err == nil {
                                    isLoading = false
                                    isSignedUp = true
                                } else {
                                    // If an error occurs:
                                    isLoading = false
                                    showErrorAlert = true
                                    errorMessage = "Failed to fetch data. Please try again."
                                }
                            }
                        case .patient:
                            firebaseManager.fetchPatientData(uid: uid) { err in
                                if err == nil {
                                    isLoading = false
                                    isSignedUp = true
                                } else {
                                    // If an error occurs:
                                    isLoading = false
                                    showErrorAlert = true
                                    errorMessage = "Failed to fetch data. Please try again."
                                }
                            }
                        }
                    }
                }
            }
            
        } catch {
            print("Error encoding user to JSON: \(error.localizedDescription)")
        }
        
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(firebaseManager: FirebaseManager())
    }
}
