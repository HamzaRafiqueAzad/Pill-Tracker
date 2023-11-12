//
//  NurseVitalRowView.swift
//  Pill Tracker
//
//  Created by Hamza Rafique Azad on 9/8/23.
//

import SwiftUI

struct NurseVitalRowView: View {
    @Binding var vital: Vital
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(spacing: 5) {
                
                Text("Type: \(vital.type.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
                                
                Image(vital.type.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30) // Adjust the size as needed
                    .padding(.top, -10)
            }
            
            Text("Value: \(Int(vital.value))")
                .font(.subheadline)
                .foregroundColor(Color.primary)
            
            Text("Date: \(Date(timeIntervalSince1970: vital.date), formatter: DateFormatter.userFriendly)")
                .font(.subheadline)
                .foregroundColor(Color.secondary)
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
}

struct NurseVitalRowView_Previews: PreviewProvider {
    static var previews: some View {
        NurseVitalRowView(vital: .constant(Vital(id: UUID(), type: .bloodSugar, value: 100, date: Date().timeIntervalSince1970)))
    }
}
