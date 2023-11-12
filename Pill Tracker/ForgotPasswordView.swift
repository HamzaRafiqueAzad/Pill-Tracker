//
//  ForgotPasswordView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 17/8/23.
//

import SwiftUI
import Firebase

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isEmailSent = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Forgot Password")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            if isEmailSent {
                Text("An email with reset instructions has been sent to \(email).")
                    .foregroundColor(.primary)
                    .padding(.bottom, 20)
            } else {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom, 20)
            }
            
            CustomTextField(title: "Email", text: $email)
            
            Button("Reset Password") {
                sendPasswordResetEmail()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
    
    private func sendPasswordResetEmail() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                isEmailSent = false
                errorMessage = error.localizedDescription
            } else {
                isEmailSent = true
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
