//
//  PlanningView.swift
//  Mama-Care
//
//  Hospital bag checklist and appointment tracker
//

import SwiftUI
import SwiftData

struct PlanningView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Planning", selection: $selectedTab) {
                    Text("Hospital Bag").tag(0)
                    Text("Appointments").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    HospitalBagChecklistView()
                        .tag(0)
                    
                    AppointmentTrackerView()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Planning")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Hospital Bag Checklist

struct HospitalBagChecklistView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Query private var items: [HospitalBagItem]
    
    @State private var showAddItem = false
    
    private var itemsByCategory: [ChecklistCategory: [HospitalBagItem]] {
        Dictionary(grouping: items, by: { $0.category })
    }
    
    private var packedCount: Int {
        items.filter { $0.isPacked }.count
    }
    
    private var totalCount: Int {
        items.count
    }
    
    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(packedCount) / Double(totalCount)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress Card
                VStack(spacing: 12) {
                    Text("Packing Progress")
                        .font(.headline)
                    
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "E5E7EB"), lineWidth: 15)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color(hex: "00BBA7"),
                                style: StrokeStyle(lineWidth: 15, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(), value: progress)
                        
                        VStack(spacing: 4) {
                            Text("\(packedCount)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                            Text("of \(totalCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 120, height: 120)
                    
                    Text("\(Int(progress * 100))% Complete")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "F9FAFB"))
                .cornerRadius(16)
                
                // Initialize default items button
                if items.isEmpty {
                    Button(action: initializeDefaultItems) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Load Default Checklist")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "00BBA7"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                
                // Categories
                ForEach(ChecklistCategory.allCases, id: \.self) { category in
                    if let categoryItems = itemsByCategory[category], !categoryItems.isEmpty {
                        ChecklistCategoryView(category: category, items: categoryItems)
                    }
                }
                
                // Add Custom Item Button
                Button(action: { showAddItem = true }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Custom Item")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "00BBA7"))
                }
                .padding()
            }
            .padding()
        }
        .sheet(isPresented: $showAddItem) {
            AddHospitalBagItemView(isPresented: $showAddItem)
        }
    }
    
    private func initializeDefaultItems() {
        let user = viewModel.currentUser?.toUserProfile()
        
        let defaultItems: [(String, ChecklistCategory)] = [
            // For Mom
            ("Comfortable clothes for labor", .forMom),
            ("Nursing bras", .forMom),
            ("Maternity pads", .forMom),
            ("Toiletries", .forMom),
            ("Slippers", .forMom),
            ("Phone charger", .forMom),
            ("Going-home outfit", .forMom),
            
            // For Baby
            ("Baby clothes (newborn & 0-3 months)", .forBaby),
            ("Diapers", .forBaby),
            ("Baby wipes", .forBaby),
            ("Receiving blankets", .forBaby),
            ("Car seat", .forBaby),
            ("Going-home outfit", .forBaby),
            
            // For Partner
            ("Snacks and drinks", .forPartner),
            ("Change of clothes", .forPartner),
            ("Entertainment (books, tablet)", .forPartner),
            ("Camera", .forPartner),
            
            // Documents
            ("ID and insurance cards", .documents),
            ("Birth plan (if you have one)", .documents),
            ("Hospital paperwork", .documents),
            ("Pediatrician contact info", .documents)
        ]
        
        for (name, category) in defaultItems {
            let item = HospitalBagItem(
                name: name,
                category: category,
                isCustom: false,
                user: user
            )
            modelContext.insert(item)
        }
        
        try? modelContext.save()
    }
}

struct ChecklistCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    let category: ChecklistCategory
    let items: [HospitalBagItem]
    
    private var packedCount: Int {
        items.filter { $0.isPacked }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(category.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Text("\(packedCount)/\(items.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(items) { item in
                ChecklistItemRow(item: item)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct ChecklistItemRow: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: HospitalBagItem
    
    var body: some View {
        HStack {
            Button(action: { item.isPacked.toggle(); try? modelContext.save() }) {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(item.isPacked ? Color(hex: "00BBA7") : .gray)
            }
            .buttonStyle(.plain)
            
            Text(item.name)
                .font(.subheadline)
                .strikethrough(item.isPacked)
                .foregroundColor(item.isPacked ? .secondary : .primary)
            
            Spacer()
            
            if item.isCustom {
                Button(action: { deleteItem() }) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func deleteItem() {
        modelContext.delete(item)
        try? modelContext.save()
    }
}

struct AddHospitalBagItemView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Binding var isPresented: Bool
    
    @State private var itemName = ""
    @State private var selectedCategory: ChecklistCategory = .forMom
    
    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Item name", text: $itemName)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ChecklistCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveItem()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        let user = viewModel.currentUser?.toUserProfile()
        let item = HospitalBagItem(
            name: itemName,
            category: selectedCategory,
            isCustom: true,
            user: user
        )
        
        modelContext.insert(item)
        try? modelContext.save()
        isPresented = false
    }
}

// MARK: - Appointment Tracker

struct AppointmentTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Appointment.date) private var appointments: [Appointment]
    
    @State private var showAddAppointment = false
    
    private var upcomingAppointments: [Appointment] {
        appointments.filter { $0.isUpcoming }
    }
    
    private var pastAppointments: [Appointment] {
        appointments.filter { $0.isPast || $0.isCompleted }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Add Appointment Button
                Button(action: { showAddAppointment = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Appointment")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "00BBA7"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                // Upcoming Appointments
                if !upcomingAppointments.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming")
                            .font(.headline)
                        
                        ForEach(upcomingAppointments) { appointment in
                            AppointmentRow(appointment: appointment)
                        }
                    }
                }
                
                // Past Appointments
                if !pastAppointments.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Past")
                            .font(.headline)
                        
                        ForEach(pastAppointments.prefix(10)) { appointment in
                            AppointmentRow(appointment: appointment)
                        }
                    }
                }
                
                if appointments.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No appointments yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Tap the button above to add your first appointment")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(40)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showAddAppointment) {
            AddAppointmentView(isPresented: $showAddAppointment)
        }
    }
}

struct AppointmentRow: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var appointment: Appointment
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: appointment.date)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: appointment.appointmentType.icon)
                .font(.title2)
                .foregroundColor(Color(hex: "00BBA7"))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(appointment.appointmentType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(hex: "00BBA7").opacity(0.1))
                    .foregroundColor(Color(hex: "00BBA7"))
                    .cornerRadius(4)
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let location = appointment.location, !location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(location)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if appointment.isUpcoming {
                Button(action: { 
                    appointment.isCompleted = true
                    try? modelContext.save()
                }) {
                    Image(systemName: appointment.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(appointment.isCompleted ? .green : .gray)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(12)
        .swipeActions {
            Button(role: .destructive) {
                modelContext.delete(appointment)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct AddAppointmentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Binding var isPresented: Bool
    
    @State private var title = ""
    @State private var appointmentType: AppointmentType = .prenatal
    @State private var date = Date()
    @State private var location = ""
    @State private var doctorName = ""
    @State private var notes = ""
    @State private var reminderEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appointment Details") {
                    TextField("Title", text: $title)
                    
                    Picker("Type", selection: $appointmentType) {
                        ForEach(AppointmentType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    
                    DatePicker("Date & Time", selection: $date)
                }
                
                Section("Optional Details") {
                    TextField("Location", text: $location)
                    TextField("Doctor/Provider", text: $doctorName)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Toggle("Reminder", isOn: $reminderEnabled)
                }
            }
            .navigationTitle("Add Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAppointment()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveAppointment() {
        let user = viewModel.currentUser?.toUserProfile()
        let appointment = Appointment(
            title: title,
            appointmentType: appointmentType,
            date: date,
            location: location.isEmpty ? nil : location,
            doctorName: doctorName.isEmpty ? nil : doctorName,
            notes: notes.isEmpty ? nil : notes,
            reminderEnabled: reminderEnabled,
            reminderDate: reminderEnabled ? Calendar.current.date(byAdding: .hour, value: -24, to: date) : nil,
            user: user
        )
        
        modelContext.insert(appointment)
        try? modelContext.save()
        isPresented = false
    }
}

#Preview {
    PlanningView()
        .environmentObject(MamaCareViewModel())
}
