//
//  HealthTrackingModels.swift
//  Mama-Care
//
//  Created for competitor feature parity
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Kick Counter Models

@Model
final class KickCountSession {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date?
    var kickCount: Int
    var notes: String?
    
    // Relationship
    var user: UserProfile?
    
    var duration: TimeInterval {
        guard let end = endDate else {
            return Date().timeIntervalSince(startDate)
        }
        return end.timeIntervalSince(startDate)
    }
    
    var isActive: Bool {
        endDate == nil
    }
    
    init(
        id: UUID = UUID(),
        startDate: Date = Date(),
        endDate: Date? = nil,
        kickCount: Int = 0,
        notes: String? = nil,
        user: UserProfile? = nil
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.kickCount = kickCount
        self.notes = notes
        self.user = user
    }
}

// MARK: - Contraction Timer Models

@Model
final class Contraction {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date?
    var duration: TimeInterval
    var notes: String?
    
    // Relationship
    var user: UserProfile?
    
    var isActive: Bool {
        endDate == nil
    }
    
    init(
        id: UUID = UUID(),
        startDate: Date = Date(),
        endDate: Date? = nil,
        duration: TimeInterval = 0,
        notes: String? = nil,
        user: UserProfile? = nil
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.notes = notes
        self.user = user
    }
}

// MARK: - Weight Tracking Models

@Model
final class WeightEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var weight: Double // in kg
    var unit: String // "kg" or "lbs"
    var notes: String?
    
    // Relationship
    var user: UserProfile?
    
    var weightInKg: Double {
        if unit == "lbs" {
            return weight * 0.453592 // Convert lbs to kg
        }
        return weight
    }
    
    var weightInLbs: Double {
        if unit == "kg" {
            return weight * 2.20462 // Convert kg to lbs
        }
        return weight
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        weight: Double,
        unit: String = "kg",
        notes: String? = nil,
        user: UserProfile? = nil
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.unit = unit
        self.notes = notes
        self.user = user
    }
}

// MARK: - Symptom Tracking Models

enum SymptomType: String, CaseIterable, Codable {
    // Common pregnancy symptoms
    case nausea = "Nausea"
    case vomiting = "Vomiting"
    case headache = "Headache"
    case backPain = "Back Pain"
    case cramping = "Cramping"
    case bleeding = "Bleeding"
    case spotting = "Spotting"
    case swelling = "Swelling"
    case fatigue = "Fatigue"
    case dizziness = "Dizziness"
    case heartburn = "Heartburn"
    case constipation = "Constipation"
    case frequentUrination = "Frequent Urination"
    case breastTenderness = "Breast Tenderness"
    case moodSwings = "Mood Swings"
    case insomnia = "Insomnia"
    case shortBreath = "Shortness of Breath"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .nausea, .vomiting: return "stomach"
        case .headache: return "brain.head.profile"
        case .backPain: return "figure.walk"
        case .cramping: return "bandage"
        case .bleeding, .spotting: return "drop.fill"
        case .swelling: return "figure.stand"
        case .fatigue: return "bed.double.fill"
        case .dizziness: return "tornado"
        case .heartburn: return "flame.fill"
        case .constipation: return "pill.fill"
        case .frequentUrination: return "drop.circle"
        case .breastTenderness: return "heart.circle"
        case .moodSwings: return "face.smiling"
        case .insomnia: return "moon.zzz.fill"
        case .shortBreath: return "wind"
        case .other: return "ellipsis.circle"
        }
    }
}

enum SymptomSeverity: String, CaseIterable, Codable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    
    var color: Color {
        switch self {
        case .mild: return .green
        case .moderate: return .orange
        case .severe: return .red
        }
    }
    
    var value: Int {
        switch self {
        case .mild: return 1
        case .moderate: return 2
        case .severe: return 3
        }
    }
}

@Model
final class SymptomEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var symptomTypeRaw: String
    var severityRaw: String
    var notes: String?
    var duration: String? // e.g., "2 hours", "all day"
    
    // Relationship
    var user: UserProfile?
    
    var symptomType: SymptomType {
        get {
            return SymptomType(rawValue: symptomTypeRaw) ?? .other
        }
        set {
            symptomTypeRaw = newValue.rawValue
        }
    }
    
    var severity: SymptomSeverity {
        get {
            return SymptomSeverity(rawValue: severityRaw) ?? .mild
        }
        set {
            severityRaw = newValue.rawValue
        }
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        symptomType: SymptomType,
        severity: SymptomSeverity,
        notes: String? = nil,
        duration: String? = nil,
        user: UserProfile? = nil
    ) {
        self.id = id
        self.date = date
        self.symptomTypeRaw = symptomType.rawValue
        self.severityRaw = severity.rawValue
        self.notes = notes
        self.duration = duration
        self.user = user
    }
}

// MARK: - Hospital Bag Checklist Models

enum ChecklistCategory: String, CaseIterable, Codable {
    case forMom = "For Mom"
    case forBaby = "For Baby"
    case forPartner = "For Partner"
    case documents = "Documents"
    case other = "Other"
}

@Model
final class HospitalBagItem {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryRaw: String
    var isPacked: Bool
    var isCustom: Bool // User-added vs. pre-populated
    
    // Relationship
    var user: UserProfile?
    
    var category: ChecklistCategory {
        get {
            return ChecklistCategory(rawValue: categoryRaw) ?? .other
        }
        set {
            categoryRaw = newValue.rawValue
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        category: ChecklistCategory,
        isPacked: Bool = false,
        isCustom: Bool = false,
        user: UserProfile? = nil
    ) {
        self.id = id
        self.name = name
        self.categoryRaw = category.rawValue
        self.isPacked = isPacked
        self.isCustom = isCustom
        self.user = user
    }
}

// MARK: - Appointment Tracking Models

enum AppointmentType: String, CaseIterable, Codable {
    case prenatal = "Prenatal Visit"
    case ultrasound = "Ultrasound"
    case bloodWork = "Blood Work"
    case specialist = "Specialist"
    case postpartum = "Postpartum Checkup"
    case pediatric = "Pediatric Visit"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .prenatal: return "stethoscope"
        case .ultrasound: return "waveform.path.ecg"
        case .bloodWork: return "drop.fill"
        case .specialist: return "cross.case.fill"
        case .postpartum: return "heart.circle"
        case .pediatric: return "figure.and.child.holdinghands"
        case .other: return "calendar.badge.clock"
        }
    }
}

@Model
final class Appointment {
    @Attribute(.unique) var id: UUID
    var title: String
    var appointmentTypeRaw: String
    var date: Date
    var location: String?
    var doctorName: String?
    var notes: String?
    var reminderEnabled: Bool
    var reminderDate: Date?
    var isCompleted: Bool
    
    // Relationship
    var user: UserProfile?
    
    var appointmentType: AppointmentType {
        get {
            return AppointmentType(rawValue: appointmentTypeRaw) ?? .other
        }
        set {
            appointmentTypeRaw = newValue.rawValue
        }
    }
    
    var isPast: Bool {
        date < Date()
    }
    
    var isUpcoming: Bool {
        !isPast && !isCompleted
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        appointmentType: AppointmentType,
        date: Date,
        location: String? = nil,
        doctorName: String? = nil,
        notes: String? = nil,
        reminderEnabled: Bool = true,
        reminderDate: Date? = nil,
        isCompleted: Bool = false,
        user: UserProfile? = nil
    ) {
        self.id = id
        self.title = title
        self.appointmentTypeRaw = appointmentType.rawValue
        self.date = date
        self.location = location
        self.doctorName = doctorName
        self.notes = notes
        self.reminderEnabled = reminderEnabled
        self.reminderDate = reminderDate
        self.isCompleted = isCompleted
        self.user = user
    }
}

// MARK: - Photo Journal/Memory Models

enum MemoryType: String, CaseIterable, Codable {
    case bumpPhoto = "Bump Photo"
    case ultrasound = "Ultrasound"
    case babyPhoto = "Baby Photo"
    case milestone = "Milestone"
    case other = "Other"
}

@Model
final class MemoryEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var title: String
    var memoryTypeRaw: String
    var caption: String?
    var imageData: Data? // Encrypted image data
    var weekNumber: Int? // Pregnancy week or baby age in weeks
    
    // Relationship
    var user: UserProfile?
    
    var memoryType: MemoryType {
        get {
            return MemoryType(rawValue: memoryTypeRaw) ?? .other
        }
        set {
            memoryTypeRaw = newValue.rawValue
        }
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        title: String,
        memoryType: MemoryType,
        caption: String? = nil,
        imageData: Data? = nil,
        weekNumber: Int? = nil,
        user: UserProfile? = nil
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.memoryTypeRaw = memoryType.rawValue
        self.caption = caption
        self.imageData = imageData
        self.weekNumber = weekNumber
        self.user = user
    }
}

// MARK: - Water Intake Tracking

@Model
final class WaterIntakeEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var amount: Double // in ml
    var unit: String // "ml" or "oz"
    
    // Relationship
    var user: UserProfile?
    
    var amountInMl: Double {
        if unit == "oz" {
            return amount * 29.5735 // Convert oz to ml
        }
        return amount
    }
    
    var amountInOz: Double {
        if unit == "ml" {
            return amount / 29.5735 // Convert ml to oz
        }
        return amount
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        amount: Double,
        unit: String = "ml",
        user: UserProfile? = nil
    ) {
        self.id = id
        self.date = date
        self.amount = amount
        self.unit = unit
        self.user = user
    }
}

// MARK: - Baby Size Data (for comparisons)

struct BabySize: Codable {
    let week: Int
    let fruitComparison: String
    let length: String // e.g., "5.5 cm"
    let weight: String // e.g., "14 g"
    let description: String
}

// Pre-populated baby size data
struct BabySizeData {
    static let sizes: [BabySize] = [
        BabySize(week: 4, fruitComparison: "Poppy seed", length: "2 mm", weight: "<1 g", description: "Your baby is just a tiny ball of cells."),
        BabySize(week: 5, fruitComparison: "Sesame seed", length: "2 mm", weight: "<1 g", description: "Your baby's heart and circulatory system are forming."),
        BabySize(week: 6, fruitComparison: "Lentil", length: "5 mm", weight: "<1 g", description: "Your baby's nose, mouth, and ears are beginning to take shape."),
        BabySize(week: 7, fruitComparison: "Blueberry", length: "1.3 cm", weight: "<1 g", description: "Your baby's arms and legs are developing."),
        BabySize(week: 8, fruitComparison: "Kidney bean", length: "1.6 cm", weight: "1 g", description: "Your baby's fingers and toes are forming."),
        BabySize(week: 9, fruitComparison: "Grape", length: "2.3 cm", weight: "2 g", description: "Your baby's heart has divided into four chambers."),
        BabySize(week: 10, fruitComparison: "Kumquat", length: "3.1 cm", weight: "4 g", description: "Your baby's vital organs are fully formed."),
        BabySize(week: 11, fruitComparison: "Fig", length: "4.1 cm", weight: "7 g", description: "Your baby can now open and close their fists."),
        BabySize(week: 12, fruitComparison: "Lime", length: "5.4 cm", weight: "14 g", description: "Your baby's reflexes are developing."),
        BabySize(week: 13, fruitComparison: "Pea pod", length: "7.4 cm", weight: "23 g", description: "Your baby's fingerprints are forming."),
        BabySize(week: 14, fruitComparison: "Lemon", length: "8.7 cm", weight: "43 g", description: "Your baby can now squint, frown, and grimace."),
        BabySize(week: 15, fruitComparison: "Apple", length: "10.1 cm", weight: "70 g", description: "Your baby's legs are growing longer than their arms."),
        BabySize(week: 16, fruitComparison: "Avocado", length: "11.6 cm", weight: "100 g", description: "Your baby's eyes can now move."),
        BabySize(week: 17, fruitComparison: "Turnip", length: "13 cm", weight: "140 g", description: "Your baby can now hear sounds."),
        BabySize(week: 18, fruitComparison: "Bell pepper", length: "14.2 cm", weight: "190 g", description: "Your baby's bones are hardening."),
        BabySize(week: 19, fruitComparison: "Mango", length: "15.3 cm", weight: "240 g", description: "Your baby is developing a protective coating."),
        BabySize(week: 20, fruitComparison: "Banana", length: "25.6 cm", weight: "300 g", description: "You're halfway through your pregnancy!"),
        BabySize(week: 21, fruitComparison: "Carrot", length: "26.7 cm", weight: "360 g", description: "Your baby can now taste what you eat."),
        BabySize(week: 22, fruitComparison: "Papaya", length: "27.8 cm", weight: "430 g", description: "Your baby's senses are rapidly developing."),
        BabySize(week: 23, fruitComparison: "Grapefruit", length: "28.9 cm", weight: "501 g", description: "Your baby can hear your voice clearly now."),
        BabySize(week: 24, fruitComparison: "Cantaloupe", length: "30 cm", weight: "600 g", description: "Your baby's lungs are developing rapidly."),
        BabySize(week: 25, fruitComparison: "Cauliflower", length: "34.6 cm", weight: "660 g", description: "Your baby may respond to familiar voices."),
        BabySize(week: 26, fruitComparison: "Lettuce", length: "35.6 cm", weight: "760 g", description: "Your baby's eyes can now open."),
        BabySize(week: 27, fruitComparison: "Cabbage", length: "36.6 cm", weight: "875 g", description: "Your baby can now recognize your voice."),
        BabySize(week: 28, fruitComparison: "Eggplant", length: "37.6 cm", weight: "1 kg", description: "Your baby's eyesight is developing."),
        BabySize(week: 29, fruitComparison: "Butternut squash", length: "38.6 cm", weight: "1.15 kg", description: "Your baby's brain is rapidly developing."),
        BabySize(week: 30, fruitComparison: "Cucumber", length: "39.9 cm", weight: "1.32 kg", description: "Your baby's eyesight continues to improve."),
        BabySize(week: 31, fruitComparison: "Coconut", length: "41.1 cm", weight: "1.5 kg", description: "Your baby is gaining weight quickly now."),
        BabySize(week: 32, fruitComparison: "Jicama", length: "42.4 cm", weight: "1.7 kg", description: "Your baby's bones are fully formed."),
        BabySize(week: 33, fruitComparison: "Pineapple", length: "43.7 cm", weight: "1.9 kg", description: "Your baby's immune system is developing."),
        BabySize(week: 34, fruitComparison: "Cantaloupe", length: "45 cm", weight: "2.1 kg", description: "Your baby's central nervous system is maturing."),
        BabySize(week: 35, fruitComparison: "Honeydew melon", length: "46.2 cm", weight: "2.4 kg", description: "Your baby's kidneys are fully developed."),
        BabySize(week: 36, fruitComparison: "Romaine lettuce", length: "47.4 cm", weight: "2.6 kg", description: "Your baby is shedding their protective coating."),
        BabySize(week: 37, fruitComparison: "Swiss chard", length: "48.6 cm", weight: "2.9 kg", description: "Your baby is now considered full term."),
        BabySize(week: 38, fruitComparison: "Leek", length: "49.8 cm", weight: "3 kg", description: "Your baby is practicing breathing movements."),
        BabySize(week: 39, fruitComparison: "Mini watermelon", length: "50.7 cm", weight: "3.3 kg", description: "Your baby's brain and lungs are still maturing."),
        BabySize(week: 40, fruitComparison: "Small pumpkin", length: "51.2 cm", weight: "3.4 kg", description: "Your baby is ready to meet you!")
    ]
    
    static func size(for week: Int) -> BabySize? {
        sizes.first { $0.week == week }
    }
}
