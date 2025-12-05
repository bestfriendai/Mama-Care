//
//  HealthTrackingView.swift
//  Mama-Care
//
//  Created for competitor feature parity - aggregates weight, symptoms, water intake
//

import SwiftUI
import SwiftData
import Charts

struct HealthTrackingView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Health Tracking", selection: $selectedTab) {
                    Text("Weight").tag(0)
                    Text("Symptoms").tag(1)
                    Text("Water").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    WeightTrackerView()
                        .tag(0)
                    
                    SymptomTrackerView()
                        .tag(1)
                    
                    WaterIntakeView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Health Tracking")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Weight Tracker

struct WeightTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Query(sort: \WeightEntry.date, order: .reverse) private var entries: [WeightEntry]
    
    @State private var showAddEntry = false
    @State private var newWeight = ""
    @State private var selectedUnit = "kg"
    
    private var chartData: [WeightEntry] {
        Array(entries.reversed().suffix(30))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Weight Card
                if let latest = entries.first {
                    VStack(spacing: 8) {
                        Text("Current Weight")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", latest.weight))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                            Text(latest.unit)
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        
                        if entries.count >= 2 {
                            let change = latest.weight - entries[1].weight
                            HStack(spacing: 4) {
                                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                Text(String(format: "%.1f %@ since last entry", abs(change), latest.unit))
                            }
                            .font(.caption)
                            .foregroundColor(change >= 0 ? .green : .red)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "F9FAFB"))
                    .cornerRadius(12)
                }
                
                // Chart
                if !chartData.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weight Trend")
                            .font(.headline)
                        
                        Chart(chartData) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Weight", entry.weight)
                            )
                            .foregroundStyle(Color(hex: "00BBA7"))
                            
                            PointMark(
                                x: .value("Date", entry.date),
                                y: .value("Weight", entry.weight)
                            )
                            .foregroundStyle(Color(hex: "00BBA7"))
                        }
                        .frame(height: 200)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                }
                
                // Add Entry Button
                Button(action: { showAddEntry = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Log Weight")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "00BBA7"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                // Recent Entries
                if !entries.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Entries")
                            .font(.headline)
                        
                        ForEach(entries.prefix(10)) { entry in
                            WeightEntryRow(entry: entry, onDelete: {
                                modelContext.delete(entry)
                            })
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showAddEntry) {
            AddWeightEntryView(isPresented: $showAddEntry)
        }
    }
}

struct WeightEntryRow: View {
    let entry: WeightEntry
    let onDelete: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(String(format: "%.1f %@", entry.weight, entry.unit))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "00BBA7"))
        }
        .padding()
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(8)
        .swipeActions {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddWeightEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Binding var isPresented: Bool
    
    @State private var weight = ""
    @State private var unit = "kg"
    @State private var notes = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Weight") {
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        
                        Picker("Unit", selection: $unit) {
                            Text("kg").tag("kg")
                            Text("lbs").tag("lbs")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Notes (Optional)") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(weight.isEmpty)
                }
            }
        }
    }
    
    private func saveEntry() {
        guard let weightValue = Double(weight) else { return }
        
        let user = viewModel.currentUser?.toUserProfile()
        let entry = WeightEntry(
            date: date,
            weight: weightValue,
            unit: unit,
            notes: notes.isEmpty ? nil : notes,
            user: user
        )
        
        modelContext.insert(entry)
        try? modelContext.save()
        isPresented = false
    }
}

// MARK: - Symptom Tracker

struct SymptomTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SymptomEntry.date, order: .reverse) private var entries: [SymptomEntry]
    
    @State private var showAddEntry = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Info Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Color(hex: "00BBA7"))
                        Text("Track Your Symptoms")
                            .font(.headline)
                    }
                    
                    Text("Log pregnancy symptoms to share with your healthcare provider.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(hex: "F9FAFB"))
                .cornerRadius(12)
                
                // Add Entry Button
                Button(action: { showAddEntry = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Log Symptom")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "00BBA7"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                // Recent Entries
                if !entries.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Symptoms")
                            .font(.headline)
                        
                        ForEach(entries.prefix(20)) { entry in
                            SymptomEntryRow(entry: entry)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No symptoms logged yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Tap the button above to log your first symptom")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showAddEntry) {
            AddSymptomEntryView(isPresented: $showAddEntry)
        }
    }
}

struct SymptomEntryRow: View {
    @Environment(\.modelContext) private var modelContext
    let entry: SymptomEntry
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        HStack {
            Image(systemName: entry.symptomType.icon)
                .font(.title2)
                .foregroundColor(entry.severity.color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.symptomType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Text(entry.severity.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(entry.severity.color.opacity(0.2))
                        .foregroundColor(entry.severity.color)
                        .cornerRadius(4)
                    
                    if let duration = entry.duration {
                        Text(duration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(8)
        .swipeActions {
            Button(role: .destructive) {
                modelContext.delete(entry)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddSymptomEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedSymptom: SymptomType = .nausea
    @State private var selectedSeverity: SymptomSeverity = .mild
    @State private var duration = ""
    @State private var notes = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Symptom") {
                    Picker("Type", selection: $selectedSymptom) {
                        ForEach(SymptomType.allCases, id: \.self) { symptom in
                            HStack {
                                Image(systemName: symptom.icon)
                                Text(symptom.rawValue)
                            }
                            .tag(symptom)
                        }
                    }
                    
                    Picker("Severity", selection: $selectedSeverity) {
                        ForEach(SymptomSeverity.allCases, id: \.self) { severity in
                            Text(severity.rawValue).tag(severity)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    DatePicker("Date & Time", selection: $date)
                }
                
                Section("Details (Optional)") {
                    TextField("Duration (e.g., '2 hours')", text: $duration)
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                }
            }
        }
    }
    
    private func saveEntry() {
        let user = viewModel.currentUser?.toUserProfile()
        let entry = SymptomEntry(
            date: date,
            symptomType: selectedSymptom,
            severity: selectedSeverity,
            notes: notes.isEmpty ? nil : notes,
            duration: duration.isEmpty ? nil : duration,
            user: user
        )
        
        modelContext.insert(entry)
        try? modelContext.save()
        isPresented = false
    }
}

// MARK: - Water Intake Tracker

struct WaterIntakeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Query private var allEntries: [WaterIntakeEntry]
    
    @State private var selectedUnit = "ml"
    
    private var todayEntries: [WaterIntakeEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return allEntries.filter { calendar.isDate($0.date, inSameDayAs: today) }
    }
    
    private var todayTotal: Double {
        todayEntries.reduce(0) { $0 + $1.amountInMl }
    }
    
    private let dailyGoalMl: Double = 2000 // 2 liters
    
    private var progress: Double {
        min(todayTotal / dailyGoalMl, 1.0)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Daily Goal Card
                VStack(spacing: 16) {
                    Text("Today's Water Intake")
                        .font(.headline)
                    
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "E5E7EB"), lineWidth: 20)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color(hex: "00BBA7"),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(), value: progress)
                        
                        VStack(spacing: 4) {
                            Text("\(Int(todayTotal))")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                            Text("ml")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Text("/ \(Int(dailyGoalMl)) ml")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 200, height: 200)
                    
                    Text("\(Int(progress * 100))% of daily goal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(hex: "F9FAFB"))
                .cornerRadius(16)
                
                // Quick Add Buttons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Add")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickAddButton(amount: 250, unit: "ml", action: addWater)
                        QuickAddButton(amount: 500, unit: "ml", action: addWater)
                        QuickAddButton(amount: 8, unit: "oz", action: addWater)
                        QuickAddButton(amount: 16, unit: "oz", action: addWater)
                    }
                }
                
                // Today's Log
                if !todayEntries.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Log")
                            .font(.headline)
                        
                        ForEach(todayEntries.sorted(by: { $0.date > $1.date })) { entry in
                            WaterEntryRow(entry: entry)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func addWater(amount: Double, unit: String) {
        let user = viewModel.currentUser?.toUserProfile()
        let entry = WaterIntakeEntry(
            amount: amount,
            unit: unit,
            user: user
        )
        
        modelContext.insert(entry)
        try? modelContext.save()
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct QuickAddButton: View {
    let amount: Double
    let unit: String
    let action: (Double, String) -> Void
    
    var body: some View {
        Button(action: { action(amount, unit) }) {
            VStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .font(.title2)
                
                Text("\(Int(amount)) \(unit)")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "00BBA7"))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

struct WaterEntryRow: View {
    @Environment(\.modelContext) private var modelContext
    let entry: WaterIntakeEntry
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        HStack {
            Image(systemName: "drop.fill")
                .foregroundColor(Color(hex: "00BBA7"))
            
            Text(formattedTime)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(Int(entry.amount)) \(entry.unit)")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(8)
        .swipeActions {
            Button(role: .destructive) {
                modelContext.delete(entry)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    HealthTrackingView()
        .environmentObject(MamaCareViewModel())
}
