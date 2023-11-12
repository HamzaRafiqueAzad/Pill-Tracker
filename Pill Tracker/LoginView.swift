//
//  LoginView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import SwiftUI
import Firebase

struct CustomTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField("", text: $text)
                .padding(10)
                .background(Color.primary.opacity(0.05))
                .cornerRadius(10)
                .foregroundColor(.primary)
                .font(.body)
        }
    }
}

struct CustomSecureField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            SecureField("", text: $text)
                .padding(10)
                .background(Color.primary.opacity(0.05))
                .cornerRadius(10)
                .foregroundColor(.primary)
                .font(.body)
        }
    }
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isInvalidCredentials = false
    
    @State private var isLoggedIn = false
    @State private var userRole: UserRole?
    @State private var isLoading = false
    
    @State private var rememberMe = false
    
    @State private var showForgotPassword = false
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    
    @ObservedObject var firebaseManager: FirebaseManager
    
    var body: some View {
        if isLoggedIn {
            switch userRole {
            case .doctor:
                DoctorView(firebaseManager: firebaseManager)
            case .nurse:
                NurseView(firebaseManager: firebaseManager)
            case .patient:
                PatientView(firebaseManager: firebaseManager)
            case .none:
                Text("Error")
            }
        } else {
            NavigationView {
                ScrollView {
                    VStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 20) {
                            CustomTextField(title: "Email", text: $email)
                            CustomSecureField(title: "Password", text: $password)
                            
                            if isInvalidCredentials {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                            }
                            
                            Button {
                                showForgotPassword.toggle()
                            } label: {
                                Text("Forgot Password?")
                            }

                            
//                            Button("Forgot Password?", action: showForgotPassword = true)
//                                .foregroundColor(.blue)
                            
                            Toggle("Remember Me", isOn: $rememberMe)
                                .foregroundColor(.primary)
                                .padding(.top, 8)
                            
                            Button {
                                login()
                            } label: {
                                Text("Login")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.blue)
                                            .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                                    )
                                    .foregroundColor(.white)
                                    .disabled(isLoading)
                            }
                                
                        }
                        .padding(20)
                        Spacer()
                    }
                }
                .navigationBarTitle("Login")
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
                    ProgressView("Logging In...")
                }
            }
            .disabled(isLoading)
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
    
    func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // Handle reset password error
                print("Reset Password Error: \(error.localizedDescription)")
                return
            }
            
            // Password reset email sent successfully
            print("Password reset email sent successfully")
        }
    }
    
    
    func login() {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle login error
                errorMessage = error.localizedDescription
                isInvalidCredentials = true
                isLoading = false
                return
            }
            
            // Successful login, get user's role
            guard let user = authResult?.user else {
                return
            }
            
            let database = Database.database().reference()
            let usersRef = database.child("Users")
            
            usersRef.child(user.uid).observeSingleEvent(of: .value) { snapshot in
                guard let data = snapshot.value as? [String: Any],
                      let roleRawValue = data["role"] as? String,
                      let role = UserRole(rawValue: roleRawValue) else {
                    print("Invalid user data")
                    isLoading = false
                    return
                }
                
                // Save user's "Remember Me" preference if they want to be remembered
                if rememberMe {
                    UserDefaults.standard.set(email, forKey: "rememberedEmail")
                    UserDefaults.standard.set(password, forKey: "rememberedPassword")
                }
                
                // Navigate to respective dashboard based on user's role
                userRole = role
                switch role {
                case .doctor:
                    firebaseManager.fetchDoctorData(uid: user.uid) { err in
                        if err == nil {
                            isLoading = false
                            isLoggedIn = true
                        } else {
                            // If an error occurs:
                            isLoading = false
                            showErrorAlert = true
                            errorMessage = "Failed to fetch data. Please try again."
                        }
                    }
                case .nurse:
                    firebaseManager.fetchNurseData(uid: user.uid) { err in
                        if err == nil {
                            isLoading = false
                            isLoggedIn = true
                        } else {
                            // If an error occurs:
                            isLoading = false
                            showErrorAlert = true
                            errorMessage = "Failed to fetch data. Please try again."
                        }
                    }
                case .patient:
                    firebaseManager.fetchPatientData(uid: user.uid) { err in
                        if err == nil {
                            isLoading = false
                            isLoggedIn = true
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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(firebaseManager: FirebaseManager())
    }
}

