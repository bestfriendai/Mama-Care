//
//  ContractionTimerView.swift
//  Mama-Care
//
//  Created for competitor feature parity
//

import SwiftUI
import SwiftData

struct ContractionTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Query(sort: \Contraction.startDate, order: .reverse) private var contractions: [Contraction]
    
    @State private var currentContraction: Contraction?
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private var isTimingContraction: Bool {
        currentContraction != nil
    }
    
    private var recentContractions: [Contraction] {
        Array(contractions.filter { $0.endDate != nil }.prefix(10))
    }
    
    private var averageInterval: TimeInterval? {
        guard recentContractions.count >= 2 else { return nil }
        
        var intervals: [TimeInterval] = []
        for i in 0..<(recentContractions.count - 1) {
            let interval = recentContractions[i].startDate.timeIntervalSince(recentContractions[i + 1].startDate)
            intervals.append(abs(interval))
        }
        
        return intervals.reduce(0, +) / Double(intervals.count)
    }
    
    private var averageDuration: TimeInterval? {
        guard !recentContractions.isEmpty else { return nil }
        let total = recentContractions.reduce(0.0) { $0 + $1.duration }
        return total / Double(recentContractions.count)
    }
    
    private var shouldGoToHospital: Bool {
        // 5-1-1 rule: Contractions 5 minutes apart, lasting 1 minute, for 1 hour
        guard let avgInterval = averageInterval,
              let avgDuration = averageDuration,
              recentContractions.count >= 12 else { // At least 12 contractions (1 hour worth)
            return false
        }
        
        return avgInterval <= 5 * 60 && avgDuration >= 60
    }
    
    private var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Warning Banner
                    if shouldGoToHospital {
                        HospitalWarningBanner()
                    }
                    
                    // Timer Section
                    VStack(spacing: 20) {
                        Text(isTimingContraction ? "Contraction in Progress" : "Ready to Time")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // Timer Display
                        Text(formattedTime)
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(isTimingContraction ? Color(hex: "EF4444") : Color(hex: "00BBA7"))
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            if isTimingContraction {
                                Button(action: stopContraction) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "stop.circle.fill")
                                            .font(.system(size: 40))
                                        Text("End")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(Color(hex: "EF4444"))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Button(action: startContraction) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 40))
                                        Text("Start")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(Color(hex: "00BBA7"))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                    
                    // Statistics
                    if !recentContractions.isEmpty {
                        StatsView(
                            averageInterval: averageInterval,
                            averageDuration: averageDuration,
                            totalCount: recentContractions.count
                        )
                    }
                    
                    // Info Card
                    ContractionInfoCard()
                    
                    // Recent Contractions
                    if !recentContractions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Contractions")
                                .font(.headline)
                            
                            ForEach(recentContractions) { contraction in
                                ContractionRowView(
                                    contraction: contraction,
                                    previousContraction: previousContraction(for: contraction)
                                )
                            }
                        }
                        .padding(16)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 10)
                    }
                }
                .padding()
            }
            .navigationTitle("Contraction Timer")
            .navigationBarTitleDisplayMode(.large)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Time to Go to Hospital!"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func startContraction() {
        let user = viewModel.currentUser?.toUserProfile()
        let contraction = Contraction(user: user)
        modelContext.insert(contraction)
        currentContraction = contraction
        elapsedTime = 0
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func stopContraction() {
        timer?.invalidate()
        timer = nil
        
        currentContraction?.endDate = Date()
        currentContraction?.duration = elapsedTime
        try? modelContext.save()
        
        currentContraction = nil
        elapsedTime = 0
        
        // Check if should alert
        if shouldGoToHospital {
            alertMessage = "Your contractions are 5 minutes apart, lasting 1 minute or more, for at least an hour. It's time to contact your healthcare provider or go to the hospital."
            showAlert = true
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func previousContraction(for contraction: Contraction) -> Contraction? {
        guard let index = recentContractions.firstIndex(where: { $0.id == contraction.id }),
              index < recentContractions.count - 1 else {
            return nil
        }
        return recentContractions[index + 1]
    }
}

struct HospitalWarningBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                Text("Time to Go to Hospital")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text("Your contractions match the 5-1-1 rule. Contact your healthcare provider.")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "EF4444"))
        .cornerRadius(12)
    }
}

struct StatsView: View {
    let averageInterval: TimeInterval?
    let averageDuration: TimeInterval?
    let totalCount: Int
    
    private func formatInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Avg Interval",
                value: averageInterval != nil ? formatInterval(averageInterval!) : "--",
                icon: "timer"
            )
            
            StatCard(
                title: "Avg Duration",
                value: averageDuration != nil ? formatInterval(averageDuration!) : "--",
                icon: "clock.fill"
            )
            
            StatCard(
                title: "Total",
                value: "\(totalCount)",
                icon: "number"
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(hex: "00BBA7"))
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(12)
    }
}

struct ContractionInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color(hex: "00BBA7"))
                Text("5-1-1 Rule")
                    .font(.headline)
            }
            
            Text("Call your healthcare provider when contractions are:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                RulePoint(number: "5", text: "Minutes apart")
                RulePoint(number: "1", text: "Minute or longer in duration")
                RulePoint(number: "1", text: "Hour of this pattern")
            }
        }
        .padding()
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(12)
    }
}

struct RulePoint: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "00BBA7"))
                .frame(width: 40)
            
            Text(text)
                .font(.subheadline)
        }
    }
}

struct ContractionRowView: View {
    let contraction: Contraction
    let previousContraction: Contraction?
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: contraction.startDate)
    }
    
    private var durationText: String {
        let seconds = Int(contraction.duration)
        return "\(seconds)s"
    }
    
    private var intervalText: String? {
        guard let previous = previousContraction else { return nil }
        let interval = abs(contraction.startDate.timeIntervalSince(previous.startDate))
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return "\(minutes)m \(seconds)s"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedTime)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let interval = intervalText {
                    Text("Interval: \(interval)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(durationText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "00BBA7"))
                
                Text("duration")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(8)
    }
}

#Preview {
    ContractionTimerView()
        .environmentObject(MamaCareViewModel())
}
