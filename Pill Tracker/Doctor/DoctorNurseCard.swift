//
//  NurseCard.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 4/8/23.
//

import SwiftUI

struct DoctorNurseCard: View {
    @ObservedObject var firebaseManager: FirebaseManager
    @Binding var nurse: Nurse
    
    var body: some View {
        NavigationLink(destination: DoctorNursePatientsListView(firebaseManager: firebaseManager, nurse: nurse)) {
            HStack(spacing: 15) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.blue.opacity(0.2), radius: 5, x: 2, y: 2)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(nurse.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Contact Number: \(nurse.contactNumber)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                    
                    Text("\(nurse.patients.count) Patient/s Assigned")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
                
                Image(systemName: "chevron.right.circle")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.blue.opacity(0.2))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
            )
            .padding(.vertical, 5)
            .shadow(color: Color.blue.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DoctorNurseCard_Previews: PreviewProvider {
    static var previews: some View {
        DoctorNurseCard(firebaseManager: FirebaseManager(), nurse: .constant(Nurse(id: "uid", email: "nurse@gmail.com", name: "Nurse Doe", contactNumber: "123-456-7890", isAvailable: true, patients: [])))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
