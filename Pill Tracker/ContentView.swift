//
//  ContentView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @ObservedObject var firebaseManager: FirebaseManager = FirebaseManager()
    
    @State var email = ""
    @State var password = ""
    
    @State private var userRole: UserRole?

    
    @State private var isLoggedIn = false
    @State private var isLoading = false
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""


    
    var body: some View {
        if isLoggedIn {
            switch userRole {
            case .doctor:
                NavigationView {
                    DoctorView(firebaseManager: firebaseManager)
                }
            case .nurse:
                NavigationView {
                    NurseView(firebaseManager: firebaseManager)
                }
            case .patient:
                NavigationView {
                    PatientView(firebaseManager: firebaseManager)
                }
            case .none:
                Text("Error")
            }
        } else {
            NavigationView {
                VStack(spacing: 20) {
                    Image("appLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color.blue)
                        .padding(.top, 20)
                    
                    Text("Welcome to")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                    
                    Text("Pill Tracker")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                    
                    Text("Your Medical Companion")
                        .font(.subheadline)
                        .foregroundColor(Color.secondary)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        NavigationLink(destination: LoginView(firebaseManager: firebaseManager)) {
                            Text("Log In")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.blue)
                                        .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                                )
                        }
                        
                        NavigationLink(destination: SignupView(firebaseManager: firebaseManager)) {
                            Text("Sign Up")
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white)
                                        .shadow(color: Color.white.opacity(0.2), radius: 5, x: -5, y: -5)
                                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
                                )
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationBarHidden(true)
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
            .onAppear {
                email = UserDefaults.standard.string(forKey: "rememberedEmail") ?? ""
                password = UserDefaults.standard.string(forKey: "rememberedPassword") ?? ""
                
                if email != "" && password != "" {
                    login()
            }
            }
        }
    }
    
    
    func login() {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle login error
                print("Login Error: \(error.localizedDescription)")
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
                
                // Navigate to respective dashboard based on user's role
                userRole = role
                switch role {
                case .doctor:
                    firebaseManager.fetchDoctorData(uid: user.uid) {  err in
                        if err == nil {
                            isLoading = false
                            isLoggedIn = true
                        } else {
                            // If an error occurs:
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
                            showErrorAlert = true
                            errorMessage = "Failed to fetch data. Please try again."
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
