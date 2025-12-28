//
//  EnhancedDashboardView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//

import SwiftUI

struct EnhancedDashboardView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Binding var selectedTab: Int

    @State private var isRefreshing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection

                    VStack(spacing: 24) {
                        pregnancyProgressSection
                            .offset(y: -40)
                            .padding(.bottom, -40)

                        quickActionsSection
                        moodTrendSection
                    }
                    .padding(.bottom, 20)
                }
            }
            .refreshable {
                await refreshData()
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .background(Color.mamaCareGrayLight)
        }
    }

    // MARK: - Refresh Data

    private func refreshData() async {
        HapticFeedback.light()
        isRefreshing = true

        // Simulate network delay for data refresh
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Refresh mood data from ViewModel
        await MainActor.run {
            viewModel.refreshMoodData()
            isRefreshing = false
            HapticFeedback.success()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.mamaCarePrimary, .mamaCarePrimaryDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())

                        Text("MamaCare")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text("Welcome, \(viewModel.currentUser?.firstName ?? "there")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 60)
            .padding(.bottom, 60)
        }
    }

    // MARK: - Pregnancy Progress Section

    private var pregnancyProgressSection: some View {
        let progressInfo = calculatePregnancyProgress()

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Week \(progressInfo.currentWeek) of 40")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text(progressInfo.babySize)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                Image(systemName: "heart")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }

            Spacer().frame(height: 20)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress to delivery")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("\(Int(progressInfo.percentage * 100))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 8)
                            .opacity(0.3)
                            .foregroundColor(.mamaCareDarkGreen)
                            .cornerRadius(4)

                        Rectangle()
                            .frame(width: geometry.size.width * progressInfo.percentage, height: 8)
                            .foregroundColor(.mamaCareDarkGreen)
                            .cornerRadius(4)
                            .animation(.easeInOut(duration: 0.5), value: progressInfo.percentage)
                    }
                }
                .frame(height: 8)

                Text("Approximately \(progressInfo.weeksRemaining) weeks to go")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.mamaCareTeal, .mamaCareTealDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.mamaCareTextPrimary)
                .padding(.horizontal)

            Text("You'll receive 3 daily reminders (08:00, 14:00, 20:00) for mood check-ins")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                DashboardActionButton(
                    title: "Mood Check-In",
                    icon: "heart",
                    color: .mamaCareMagenta,
                    bgColor: .mamaCarePurpleLight
                ) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    selectedTab = 1
                }

                DashboardActionButton(
                    title: "Vaccines",
                    icon: "shield",
                    color: .mamaCareMagenta,
                    bgColor: .mamaCarePurpleLight
                ) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    selectedTab = 3
                }

                DashboardActionButton(
                    title: "Emergency",
                    icon: "phone",
                    color: .mamaCareOverdue,
                    bgColor: .mamaCareRedLight
                ) {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    selectedTab = 4
                }

                DashboardActionButton(
                    title: "AI Chat",
                    icon: "bubble.left",
                    color: .mamaCareOrange,
                    bgColor: .mamaCareOrangeLight
                ) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    selectedTab = 5
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Mood Trend Section

    private var moodTrendSection: some View {
        MoodTrendChartView(moodCheckIns: viewModel.moodCheckIns)
    }

    // MARK: - Helper Methods

    private func calculatePregnancyProgress() -> (currentWeek: Int, percentage: Double, weeksRemaining: Int, babySize: String) {
        guard let user = viewModel.currentUser,
              user.userType == .pregnant,
              let dueDate = user.expectedDeliveryDate else {
            return (15, 0.38, 25, "Your baby is growing strong")
        }

        let today = Date()
        let calendar = Calendar.current

        guard let conceptionDate = calendar.date(byAdding: .weekOfYear, value: -40, to: dueDate) else {
            return (15, 0.38, 25, "Your baby is growing strong")
        }

        let daysSinceConception = calendar.dateComponents([.day], from: conceptionDate, to: today).day ?? 0
        let currentWeek = max(1, min(40, daysSinceConception / 7))
        let weeksRemaining = max(0, 40 - currentWeek)
        let percentage = Double(currentWeek) / 40.0

        let babySizes = [
            1: "a poppy seed", 2: "a sesame seed", 3: "a lentil", 4: "a blueberry",
            5: "an apple seed", 6: "a pea", 7: "a blueberry", 8: "a raspberry",
            9: "a cherry", 10: "a strawberry", 11: "a lime", 12: "a plum",
            13: "a lemon", 14: "a peach", 15: "an apple", 16: "an avocado",
            17: "a pear", 18: "a bell pepper", 19: "a mango", 20: "a banana",
            21: "a carrot", 22: "a papaya", 23: "a grapefruit", 24: "an ear of corn",
            25: "a cauliflower", 26: "a lettuce", 27: "a cabbage", 28: "an eggplant",
            29: "a butternut squash", 30: "a cucumber", 31: "a coconut", 32: "a jicama",
            33: "a pineapple", 34: "a cantaloupe", 35: "a honeydew", 36: "a romaine lettuce",
            37: "a winter melon", 38: "a leek", 39: "a mini watermelon", 40: "a pumpkin"
        ]

        let babySize = "Your baby is the size of \(babySizes[currentWeek] ?? "a growing miracle")"

        return (currentWeek, percentage, weeksRemaining, babySize)
    }
}

// MARK: - Dashboard Action Button

struct DashboardActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let bgColor: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "374151"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Preview

#Preview {
    EnhancedDashboardView(selectedTab: .constant(0))
        .environmentObject({
            let viewModel = MamaCareViewModel()
            viewModel.currentUser = User(
                firstName: "Elizabeth",
                lastName: "Smith",
                email: "elizabeth@example.com",
                country: "United Kingdom",
                mobileNumber: "",
                userType: .pregnant,
                expectedDeliveryDate: Calendar.current.date(byAdding: .weekOfYear, value: 25, to: Date())
            )
            return viewModel
        }())
}
