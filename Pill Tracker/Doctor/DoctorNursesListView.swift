import SwiftUI
import Firebase

struct DoctorNursesListView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    @Binding var assignedNurses: [Nurse]
    @Binding var availableNurses: [Nurse]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                Section(header: Text("Assigned Nurses").font(.headline)) {
                    if assignedNurses.count != 0 {
                        ForEach($assignedNurses, id: \.self) { $nurse in
                            DoctorNurseCard(firebaseManager: firebaseManager, nurse: $nurse)
                        }
                    } else {
                        Text("No Nurses Assigned At The Moment.")
                    }
                }
                
                Section(header: Text("Available Nurses").font(.headline)) {
                    if availableNurses.count != 0 {
                        ForEach($availableNurses, id: \.self) { $nurse in
                            DoctorNurseCard(firebaseManager: firebaseManager, nurse: $nurse)
                        }
                    } else {
                        Text("No Nurses Available At The Moment.")
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .navigationBarTitle("Manage Nurses")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
}

struct DoctorNursesListView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorNursesListView(firebaseManager: FirebaseManager(), assignedNurses: .constant([]), availableNurses: .constant([]))
    }
}
