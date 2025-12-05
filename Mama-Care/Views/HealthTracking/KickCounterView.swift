//
//  KickCounterView.swift
//  Mama-Care
//
//  Created for competitor feature parity
//

import SwiftUI
import SwiftData

struct KickCounterView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Query(sort: \KickCountSession.startDate, order: .reverse) private var sessions: [KickCountSession]
    
    @State private var currentSession: KickCountSession?
    @State private var sessionStartTime: Date?
    @State private var kickCount: Int = 0
    @State private var timer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    @State private var showHistory = false
    
    private var isSessionActive: Bool {
        currentSession != nil
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
                    // Info Card
                    InfoCardView()
                    
                    // Counter Section
                    VStack(spacing: 20) {
                        // Timer Display
                        VStack(spacing: 8) {
                            Text("Session Time")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(formattedTime)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "00BBA7"))
                        }
                        
                        // Kick Count Display
                        VStack(spacing: 8) {
                            Text("Kicks Counted")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("\(kickCount)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "009966"))
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            if isSessionActive {
                                // Count Kick Button
                                Button(action: countKick) {
                                    HStack {
                                        Image(systemName: "hand.tap.fill")
                                        Text("Count Kick")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "00BBA7"))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                                
                                // Stop Session Button
                                Button(action: stopSession) {
                                    HStack {
                                        Image(systemName: "stop.fill")
                                        Text("End Session")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            } else {
                                // Start Session Button
                                Button(action: startSession) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("Start Counting")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "00BBA7"))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 10)
                    
                    // Recent Sessions
                    if !sessions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Sessions")
                                    .font(.headline)
                                Spacer()
                                Button(action: { showHistory.toggle() }) {
                                    Text(showHistory ? "Hide" : "Show All")
                                        .font(.subheadline)
                                        .foregroundColor(Color(hex: "00BBA7"))
                                }
                            }
                            
                            if showHistory {
                                ForEach(sessions.prefix(10)) { session in
                                    SessionRowView(session: session)
                                }
                            } else {
                                ForEach(sessions.prefix(3)) { session in
                                    SessionRowView(session: session)
                                }
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
            .navigationTitle("Kick Counter")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func startSession() {
        let user = viewModel.currentUser?.toUserProfile()
        let session = KickCountSession(user: user)
        modelContext.insert(session)
        currentSession = session
        sessionStartTime = Date()
        kickCount = 0
        elapsedTime = 0
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    private func countKick() {
        kickCount += 1
        currentSession?.kickCount = kickCount
        try? modelContext.save()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func stopSession() {
        timer?.invalidate()
        timer = nil
        
        currentSession?.endDate = Date()
        try? modelContext.save()
        
        currentSession = nil
        sessionStartTime = nil
        kickCount = 0
        elapsedTime = 0
    }
}

struct InfoCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color(hex: "00BBA7"))
                Text("About Kick Counting")
                    .font(.headline)
            }
            
            Text("Track your baby's movements to monitor their wellbeing. Count 10 kicks within 2 hours during your baby's active time.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Contact your healthcare provider if:")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 4) {
                BulletPoint(text: "You notice a significant decrease in movements")
                BulletPoint(text: "It takes longer than usual to count 10 kicks")
                BulletPoint(text: "You have any concerns about your baby's activity")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(12)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
    }
}

struct SessionRowView: View {
    let session: KickCountSession
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.startDate)
    }
    
    private var duration: String {
        let minutes = Int(session.duration) / 60
        let seconds = Int(session.duration) % 60
        return String(format: "%d min %d sec", minutes, seconds)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.kickCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "00BBA7"))
                
                Text("kicks")
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
    KickCounterView()
        .environmentObject(MamaCareViewModel())
}
