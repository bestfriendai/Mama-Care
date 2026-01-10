//
//  MoreFeaturesView.swift
//  Mama-Care
//
//  Additional features grouped in one tab
//

import SwiftUI

struct MoreFeaturesView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    
    private var isPregnant: Bool {
        viewModel.currentUser?.userType == .pregnant
    }
    
    var body: some View {
        NavigationView {
            List {
                // Health Tracking Section
                Section {
                    NavigationLink(destination: HealthTrackingView()) {
                        FeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Health Tracking",
                            subtitle: "Weight, symptoms & water intake",
                            color: Color(hex: "00BBA7")
                        )
                    }
                } header: {
                    Text("Health & Wellness")
                }
                
                // Pregnancy Tracking (Pregnant users only)
                if isPregnant {
                    Section {
                        NavigationLink(destination: KickCounterView()) {
                            FeatureRow(
                                icon: "hand.tap.fill",
                                title: "Kick Counter",
                                subtitle: "Track baby movements",
                                color: Color(hex: "EC4899")
                            )
                        }
                        
                        NavigationLink(destination: ContractionTimerView()) {
                            FeatureRow(
                                icon: "timer",
                                title: "Contraction Timer",
                                subtitle: "Monitor labor contractions",
                                color: Color(hex: "EF4444")
                            )
                        }
                        
                        NavigationLink(destination: BabySizeView()) {
                            FeatureRow(
                                icon: "figure.child",
                                title: "Baby's Size",
                                subtitle: "See how big your baby is",
                                color: Color(hex: "8B5CF6")
                            )
                        }
                    } header: {
                        Text("Pregnancy Tools")
                    }
                }
                
                // Planning Tools
                Section {
                    NavigationLink(destination: PlanningView()) {
                        FeatureRow(
                            icon: "list.clipboard.fill",
                            title: "Planning",
                            subtitle: "Hospital bag & appointments",
                            color: Color(hex: "F59E0B")
                        )
                    }
                    
                    NavigationLink(destination: PhotoJournalView()) {
                        FeatureRow(
                            icon: "photo.on.rectangle.angled",
                            title: "Photo Journal",
                            subtitle: "Capture pregnancy memories",
                            color: Color(hex: "3B82F6")
                        )
                    }
                } header: {
                    Text("Planning & Memories")
                }
                
                // Information Section
                Section {
                    NavigationLink(destination: PregnancyInfoView()) {
                        FeatureRow(
                            icon: "book.fill",
                            title: "Pregnancy Guide",
                            subtitle: "Week-by-week information",
                            color: Color(hex: "10B981")
                        )
                    }
                } header: {
                    Text("Resources")
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// Placeholder for Photo Journal
struct PhotoJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Query(sort: \MemoryEntry.date, order: .reverse) private var memories: [MemoryEntry]
    
    @State private var showAddMemory = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Add Memory Button
                Button(action: { showAddMemory = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Memory")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "00BBA7"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Memories Grid
                if !memories.isEmpty {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(memories) { memory in
                            MemoryCard(memory: memory)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No memories yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Capture your journey by adding photos and notes")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Photo Journal")
        .sheet(isPresented: $showAddMemory) {
            AddMemoryView(isPresented: $showAddMemory)
        }
    }
}

struct MemoryCard: View {
    let memory: MemoryEntry
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: memory.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder for image
            Rectangle()
                .fill(Color(hex: "E5E7EB"))
                .frame(height: 150)
                .cornerRadius(12)
                .overlay(
                    Image(systemName: memory.memoryType.icon)
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(memory.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let week = memory.weekNumber {
                    Text("Week \(week)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "00BBA7").opacity(0.1))
                        .foregroundColor(Color(hex: "00BBA7"))
                        .cornerRadius(4)
                }
            }
        }
    }
}

extension MemoryType {
    var icon: String {
        switch self {
        case .bumpPhoto: return "figure.stand"
        case .ultrasound: return "waveform.path.ecg"
        case .babyPhoto: return "face.smiling"
        case .milestone: return "star.fill"
        case .other: return "photo"
        }
    }
}

struct AddMemoryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Binding var isPresented: Bool
    
    @State private var title = ""
    @State private var memoryType: MemoryType = .bumpPhoto
    @State private var caption = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Memory Details") {
                    TextField("Title", text: $title)
                    
                    Picker("Type", selection: $memoryType) {
                        ForEach(MemoryType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Caption (Optional)") {
                    TextField("Caption", text: $caption, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Text("Photo upload feature coming soon!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMemory()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveMemory() {
        let user = viewModel.currentUser?.toUserProfile()
        let weekNumber = viewModel.currentUser?.pregnancyWeek
        
        let memory = MemoryEntry(
            date: date,
            title: title,
            memoryType: memoryType,
            caption: caption.isEmpty ? nil : caption,
            weekNumber: weekNumber,
            user: user
        )
        
        modelContext.insert(memory)
        try? modelContext.save()
        isPresented = false
    }
}

// Placeholder for Pregnancy Info
struct PregnancyInfoView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    
    private var currentWeek: Int {
        viewModel.currentUser?.pregnancyWeek ?? 1
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Week \(currentWeek) of Pregnancy")
                    .font(.title2)
                    .fontWeight(.bold)
                
                InfoSection(
                    title: "What's Happening This Week",
                    content: "Your baby continues to grow and develop. At week \(currentWeek), important developmental milestones are occurring."
                )
                
                InfoSection(
                    title: "Your Body",
                    content: "You may be experiencing various pregnancy symptoms. Remember to stay hydrated, eat nutritious foods, and get plenty of rest."
                )
                
                InfoSection(
                    title: "Tips for This Week",
                    content: "• Stay active with pregnancy-safe exercises\n• Attend prenatal appointments\n• Take your prenatal vitamins\n• Get adequate sleep"
                )
                
                InfoSection(
                    title: "Things to Prepare",
                    content: "Start thinking about your birth plan and hospital bag as your due date approaches."
                )
            }
            .padding()
        }
        .navigationTitle("Pregnancy Guide")
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(12)
    }
}

#Preview {
    MoreFeaturesView()
        .environmentObject(MamaCareViewModel())
}
