////
////  PieChartView.swift
////  Pill Tracker
////
////  Created by Hamza Rafique Azad on 11/8/23.
////
//import SwiftUI
//struct PieSliceData {
//    let startAngle: Angle
//    let endAngle: Angle
//    let color: Color
//}
//
//
//struct PieSlice: Shape {
//    var startAngle: Angle
//    var endAngle: Angle
//
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        path.move(to: center)
//
//        let radius = min(rect.width, rect.height) / 2
//        let start = CGPoint(
//            x: center.x + radius * CGFloat(cos(startAngle.radians)),
//            y: center.y + radius * CGFloat(sin(startAngle.radians))
//        )
//
//        path.addLine(to: start)
//        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
//        path.addLine(to: center)
//
//        return path
//    }
//}
//
//struct PieChart: View {
//    var slices: [PieSliceData]
//    var onTap: () -> Void
//
//    var body: some View {
//        ZStack {
//            ForEach(0..<slices.count, id: \.self) { index in
//                PieSlice(startAngle: slices[index].startAngle, endAngle: slices[index].endAngle)
//                    .fill(slices[index].color)
//            }
//        }
//        .onTapGesture {
//            onTap()
//        }
//    }
//}
//
//struct MedicationPieChartView: View {
//    var medications: [Medication]
//    @State private var showIndividualCharts = false
//
//    var body: some View {
//        VStack {
//            if showIndividualCharts {
//                ForEach(medications) { medication in
//                    VStack {
//                        Text(medication.name)
//                            .font(.headline)
//                        MedicationPieChartViewSingle(medication: medication)
//                    }
//                }
//            } else {
//                let takenCount = medications.reduce(0) { result, medication in
//                    result + medication.reminders.filter({ $0.isTaken }).count
//                }
//
//                let remainingCount = medications.reduce(0) { result, medication in
//                    result + medication.reminders.filter({ $0.isTaken == false }).count
//                }
//
//                let takenSlice = PieSliceData(startAngle: .degrees(0), endAngle: .degrees(Double(takenCount) / Double(takenCount + remainingCount) * 360), color: .green)
//                let remainingSlice = PieSliceData(startAngle: .degrees(Double(takenCount) / Double(takenCount + remainingCount) * 360), endAngle: .degrees(360), color: .gray)
//
//                PieChart(slices: [takenSlice, remainingSlice], onTap: {
//                    showIndividualCharts.toggle()
//                })
//                .frame(width: 150, height: 150)
//            }
//        }
//    }
//}
//
//struct MedicationPieChartViewSingle: View {
//    var medication: Medication
//
//    var body: some View {
//        let takenSlice = PieSliceData(startAngle: .degrees(0), endAngle: .degrees(Double(medication.reminders.filter({ $0.isTaken == true }).count) / Double(medication.reminders.filter({ $0.isTaken == true }).count + medication.reminders.filter({ $0.isTaken == false }).count) * 360), color: .green)
//        let remainingSlice = PieSliceData(startAngle: .degrees(Double(medication.reminders.filter({ $0.isTaken == true }).count) / Double(medication.reminders.filter({ $0.isTaken == true }).count + medication.reminders.filter({ $0.isTaken == false }).count) * 360), endAngle: .degrees(360), color: .gray)
//
//        PieChart(slices: [takenSlice, remainingSlice], onTap: {})
//            .frame(width: 100, height: 100)
//    }
//}
//
//struct MedicationPieChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        MedicationPieChartView(medications: [Medication(id: UUID(), name: "Medication 1", dosage: "10mg", reminders: [MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: true, isVerified: true)], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970), Medication(id: UUID(), name: "Medication 1", dosage: "10mg", reminders: [MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: true, isVerified: true)], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970), Medication(id: UUID(), name: "Medication 1", dosage: "10mg", reminders: [MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: false, isVerified: false)], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970), Medication(id: UUID(), name: "Medication 1", dosage: "10mg", reminders: [MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: false, isVerified: false)], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970), Medication(id: UUID(), name: "Medication 1", dosage: "10mg", reminders: [MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: false, isVerified: false)], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970)])
//    }
//}
//
import SwiftUI
import SwiftUICharts


struct MedicationDonutChartView: View {
    var medications: [Medication]
    var body: some View {
        HStack {
            VStack {
                let totalTakenCount = medications.reduce(0) { result, medication in
                    result + medication.reminders.filter({ $0.isTaken }).count
                }
                
                let totalMissedCount = medications.reduce(0) { result, medication in
                    result + medication.reminders.filter({isDoseTimeMissed(Date(timeIntervalSince1970: $0.doseTime)) }).count
                }
                let totalRemainingCount = medications.reduce(0) { result, medication in
                    result + medication.reminders.filter({ $0.isTaken == false }).count
                }
                
                // Calculate total values
                let totalValues = totalTakenCount + totalRemainingCount
                let totalTakenPercentage = Double(totalTakenCount) / Double(totalValues)
                let lineWidthFactor = 0.5 / Double(medications.count) // Adjust the scaling factor as needed

                ZStack {
                    let hue = Double(totalTakenCount + totalMissedCount) / Double(totalTakenCount + totalRemainingCount)
                    let color = Color(hue: hue, saturation: 0.7, brightness: 0.9)
                    ZStack {
                        Circle()
                            .trim(from: CGFloat(totalTakenPercentage), to: 1)
                            .stroke(Color.gray, lineWidth: 60 * lineWidthFactor)
                        Circle()
                            .trim(from: 0, to: CGFloat(totalTakenPercentage))
                            .stroke(color, lineWidth: 60 * lineWidthFactor)
                    }
                    .frame(width: 340, height: 340)
                    
                    ForEach(medications.indices, id: \.self) { index in
                        let medication = medications[index]
                        let scaleFactor = CGFloat(index * 40) // Adjust the scaling factor as needed
                        VStack {
                            let takenCount = medication.reminders.filter({ $0.isTaken }).count
                            let missedCount = medication.reminders.filter( { isDoseTimeMissed(Date(timeIntervalSince1970: $0.doseTime)) }).count
                            let remainingCount = medication.reminders.count - takenCount
                            let medicationTotal = takenCount + remainingCount
                            let takenPercentage = Double(takenCount) / Double(medicationTotal)
                            
                            let hue = Double(takenCount+missedCount) / Double(medication.reminders.count)
                            let color = Color(hue: hue, saturation: 0.7, brightness: 0.9)
                            
                            ZStack {
                                
                                Circle()
                                    .trim(from: CGFloat(takenPercentage), to: 1)
                                    .stroke(Color.gray, lineWidth: 60 * lineWidthFactor)
                                Circle()
                                    .trim(from: 0, to: CGFloat(takenPercentage))
                                    .stroke(color, lineWidth: 60 * lineWidthFactor)
                            }
                        }
                        .frame(maxWidth: 300 - (scaleFactor), maxHeight: 300 - (scaleFactor))
                    }
                }
                ScrollView(.horizontal) {
                    VStack(alignment: .leading, spacing: 10) {
                        let hue = Double(totalTakenCount) / Double(totalTakenCount + totalRemainingCount)
                        let totalcolor = Color(hue: hue, saturation: 0.7, brightness: 0.9)
                        HStack {
                            Circle()
                                .foregroundColor(totalcolor)
                                .frame(width: 10, height: 10)
                            Text("Total: \(medications.count)")
                                .foregroundColor(.primary)
                            ForEach(medications.indices, id: \.self) { index in
                                let medication = medications[index]
                                let takenCount = medication.reminders.filter({ $0.isTaken }).count
                                let verifiedCount = medication.reminders.filter({ $0.isVerified }).count
                                let missedCount = medication.reminders.filter( { isDoseTimeMissed(Date(timeIntervalSince1970: $0.doseTime)) }).count
                                let remainingCount = medication.reminders.count - takenCount
                                
                                let hue = Double(takenCount+missedCount) / Double(medication.reminders.count)
                                let color = Color(hue: hue, saturation: 0.7, brightness: 0.9)
                                
                                VStack {
                                    Circle()
                                        .foregroundColor(color)
                                        .frame(width: 10, height: 10)
                                    Text(medication.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("Taken: \(takenCount)")
                                        .foregroundColor(.primary)
                                    Text("Verified: \(verifiedCount)")
                                        .foregroundColor(.primary)
                                    Text("Missed: \(missedCount)")
                                        .foregroundColor(.primary)
                                    Text("Remaining: \(remainingCount)")
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .font(.caption)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .padding()
    }
    
    private func isDoseTimeMissed(_ doseTime: Date) -> Bool {
        let calendar = Calendar.current
        let currentDateTime = Date()
        let allowedRange = calendar.date(byAdding: .minute, value: 10, to: doseTime)
        
        return currentDateTime > allowedRange!
    }
}

//struct MedicationDonutChartView: View {
//    var medications: [Medication]
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                ForEach(medications.indices, id: \.self) { index in
//                    let medication = medications[index]
//                    let takenCount = medication.reminders.filter({ $0.isTaken }).count
//                    let remainingCount = medication.reminders.count - takenCount
//                    let medicationTotal = takenCount + remainingCount
//                    let takenPercentage = Double(takenCount) / Double(medicationTotal)
//
//                    let hue = Double(index) / Double(medications.count)
//                    let color = Color(hue: hue, saturation: 0.7, brightness: 0.9)
//
//                    VStack {
//                        ZStack {
//                            Circle()
//                                .trim(from: CGFloat(takenPercentage), to: 1)
//                                .stroke(color, lineWidth: 30)
//                            Circle()
//                                .trim(from: 0, to: CGFloat(takenPercentage))
//                                .stroke(Color.gray, lineWidth: 30)
//                        }
//                    }
//                    .frame(maxWidth: 300 / (CGFloat(index) + 1.1), maxHeight: 400 / (CGFloat(index) + 1.1))
//                }
//            }
//            VStack(alignment: .leading, spacing: 10) {
//                Text("Total: \(medications.count)")
//                    .foregroundColor(.primary)
//                ForEach(medications.indices, id: \.self) { index in
//                    let medication = medications[index]
//                    let takenCount = medication.reminders.filter({ $0.isTaken }).count
//                    let remainingCount = medication.reminders.count - takenCount
//
//                    let hue = Double(index) / Double(medications.count)
//                    let color = Color(hue: hue, saturation: 0.7, brightness: 0.9)
//
//                    HStack {
//                        Circle()
//                            .foregroundColor(color)
//                            .frame(width: 10, height: 10)
//                        Text(medication.name)
//                            .foregroundColor(.primary)
//                        Spacer()
//                        Text("Taken: \(takenCount)")
//                            .foregroundColor(.primary)
//                        Text("Remaining: \(remainingCount)")
//                            .foregroundColor(.primary)
//                    }
//                }
//            }
//        }
//        .padding()
//    }
//}


struct MedicationDonutChartView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationDonutChartView(medications: [Medication(id: UUID(), name: "Medication 1", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: true, isVerified: true)], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active), Medication(id: UUID(), name: "Medication 2", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: true, isVerified: true)], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active), Medication(id: UUID(), name: "Medication 3", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: false, isVerified: false)], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active), Medication(id: UUID(), name: "Medication 4", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: true, isVerified: false), MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: true, isVerified: false)], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active), Medication(id: UUID(), name: "Medication 5", dosage: "10mg", dosageUnit: .mg, forDisease: "", reminders: [MedicationReminder(name: "", doseTime: TimeInterval(), isTaken: false, isVerified: false)], frequency: 0, startDate: Date().timeIntervalSince1970, endDate: Date().timeIntervalSince1970, medicationState: .active)]) // Provide sample medications here
    }
}
