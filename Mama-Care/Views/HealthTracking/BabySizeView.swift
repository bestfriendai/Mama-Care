//
//  BabySizeView.swift
//  Mama-Care
//
//  Baby size comparisons feature for pregnant users
//

import SwiftUI

struct BabySizeView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    
    private var currentWeek: Int {
        viewModel.currentUser?.pregnancyWeek ?? 0
    }
    
    private var babySize: BabySize? {
        BabySizeData.size(for: currentWeek)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let size = babySize {
                        // Week Header
                        VStack(spacing: 8) {
                            Text("Week \(size.week)")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("of 40")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Size Comparison Card
                        VStack(spacing: 20) {
                            // Fruit emoji/icon
                            Text(fruitEmoji(for: size.fruitComparison))
                                .font(.system(size: 100))
                            
                            Text("Your baby is about the size of a")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(size.fruitComparison)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "00BBA7"))
                            
                            // Measurements
                            HStack(spacing: 40) {
                                MeasurementView(icon: "ruler", label: "Length", value: size.length)
                                MeasurementView(icon: "scalemass", label: "Weight", value: size.weight)
                            }
                            .padding(.top)
                        }
                        .padding(24)
                        .background(Color(hex: "F9FAFB"))
                        .cornerRadius(16)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("This Week")
                                .font(.headline)
                            
                            Text(size.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                        
                        // Timeline
                        WeekTimelineView(currentWeek: currentWeek)
                        
                    } else {
                        EmptyStateView()
                    }
                }
                .padding()
            }
            .navigationTitle("Baby's Size")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func fruitEmoji(for fruit: String) -> String {
        let emojiMap: [String: String] = [
            "Poppy seed": "🌱",
            "Sesame seed": "🌱",
            "Lentil": "🫘",
            "Blueberry": "🫐",
            "Kidney bean": "🫘",
            "Grape": "🍇",
            "Kumquat": "🍊",
            "Fig": "🫒",
            "Lime": "🍋",
            "Pea pod": "🫛",
            "Lemon": "🍋",
            "Apple": "🍎",
            "Avocado": "🥑",
            "Turnip": "🥕",
            "Bell pepper": "🫑",
            "Mango": "🥭",
            "Banana": "🍌",
            "Carrot": "🥕",
            "Papaya": "🥭",
            "Grapefruit": "🍊",
            "Cantaloupe": "🍈",
            "Cauliflower": "🥦",
            "Lettuce": "🥬",
            "Cabbage": "🥬",
            "Eggplant": "🍆",
            "Butternut squash": "🎃",
            "Cucumber": "🥒",
            "Coconut": "🥥",
            "Jicama": "🥔",
            "Pineapple": "🍍",
            "Honeydew melon": "🍈",
            "Romaine lettuce": "🥬",
            "Swiss chard": "🥬",
            "Leek": "🥬",
            "Mini watermelon": "🍉",
            "Small pumpkin": "🎃"
        ]
        
        return emojiMap[fruit] ?? "👶"
    }
}

struct MeasurementView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: "00BBA7"))
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

struct WeekTimelineView: View {
    let currentWeek: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pregnancy Timeline")
                .font(.headline)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "E5E7EB"))
                        .frame(height: 8)
                    
                    // Progress bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "00BBA7"))
                        .frame(width: geometry.size.width * CGFloat(currentWeek) / 40, height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Week \(currentWeek)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "00BBA7"))
                
                Spacer()
                
                Text("\(40 - currentWeek) weeks to go")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No pregnancy data available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Set your expected delivery date in settings to see your baby's size.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    BabySizeView()
        .environmentObject({
            let viewModel = MamaCareViewModel()
            viewModel.currentUser = User(
                firstName: "Sarah",
                lastName: "Johnson",
                email: "sarah@example.com",
                country: "United Kingdom",
                mobileNumber: "",
                userType: .pregnant,
                expectedDeliveryDate: Calendar.current.date(byAdding: .weekOfYear, value: 20, to: Date())
            )
            return viewModel
        }())
}
