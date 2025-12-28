//
//  MoodCheckInView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//

import SwiftUI

struct MoodCheckInView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var selectedMood: MoodType?
    @State private var notes = ""
    @State private var isSubmitting = false

    // Navigation States
    @State private var showSupportiveTips = false
    @State private var showPositiveSupport = false
    @State private var showGoodMoodSuccess = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection

                ScrollView {
                    VStack(spacing: 24) {
                        mainContentSection
                    }
                    .padding(.top, 24)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSupportiveTips) {
                SupportiveTipsView(
                    onEmergencyContact: { },
                    onTalkToAI: { },
                    onCalmingAudio: { }
                )
            }
            .sheet(isPresented: $showPositiveSupport) {
                PositiveSupportView(
                    onTalkToAI: { },
                    onDone: {
                        showPositiveSupport = false
                        resetForm()
                    }
                )
            }
            .alert("Wonderful!", isPresented: $showGoodMoodSuccess) {
                Button("Done", role: .cancel) {
                    resetForm()
                }
            } message: {
                Text("Your strength and positivity shine through! Keep nurturing yourself and your little one.")
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MamaCare")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Hi, \(viewModel.currentUser?.firstName ?? "there")")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.mamaCarePrimary.ignoresSafeArea(edges: .top))
    }

    // MARK: - Main Content Section

    private var mainContentSection: some View {
        VStack(spacing: 32) {
            titleSection
            moodSelectionSection
            notesSection
            submitButtonSection
        }
        .padding(.bottom, 40)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: 12) {
            Text("Daily Mood Check-In")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.mamaCareTextPrimary)

            Text("How are you feeling today? Take a moment to reflect on your emotional wellbeing.")
                .font(.body)
                .foregroundColor(.mamaCareTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    // MARK: - Mood Selection Section

    private var moodSelectionSection: some View {
        VStack(spacing: 24) {
            Text("How are you feeling today?")
                .font(.headline)
                .foregroundColor(Color(hex: "374151"))

            HStack(spacing: 20) {
                MoodCircleButton(mood: .good, isSelected: selectedMood == .good) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedMood = .good
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }

                MoodCircleButton(mood: .okay, isSelected: selectedMood == .okay) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedMood = .okay
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }

                MoodCircleButton(mood: .notGood, isSelected: selectedMood == .notGood) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selectedMood = .notGood
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Notes (Optional)")
                .font(.headline)
                .foregroundColor(Color(hex: "374151"))

            ZStack(alignment: .topLeading) {
                TextEditor(text: $notes)
                    .frame(height: 120)
                    .padding(12)
                    .background(Color.mamaCareGrayMedium)
                    .cornerRadius(12)

                if notes.isEmpty {
                    Text("How are you feeling? What's on your mind today? Any concerns or positive moments you'd like to record...")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Submit Button Section

    private var submitButtonSection: some View {
        Button(action: submitCheckIn) {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                        .padding(.trailing, 8)
                }
                Text(isSubmitting ? "Submitting..." : "Submit Check-In")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedMood == nil ? Color.gray.opacity(0.5) : Color.mamaCarePrimary)
            .cornerRadius(12)
        }
        .disabled(selectedMood == nil || isSubmitting)
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // MARK: - Actions

    private func submitCheckIn() {
        guard let mood = selectedMood else { return }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isSubmitting = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let checkIn = MoodCheckIn(moodType: mood, notes: notes.isEmpty ? nil : notes)
            viewModel.addMoodCheckIn(checkIn)

            isSubmitting = false
            UINotificationFeedbackGenerator().notificationOccurred(.success)

            switch mood {
            case .good:
                showGoodMoodSuccess = true
            case .okay:
                showPositiveSupport = true
            case .notGood:
                showSupportiveTips = true
            }
        }
    }

    private func resetForm() {
        withAnimation {
            selectedMood = nil
            notes = ""
        }
    }
}

// MARK: - Mood Circle Button

struct MoodCircleButton: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(getColor(for: mood))
                        .frame(width: 80, height: 80)
                        .shadow(color: getColor(for: mood).opacity(0.4), radius: 8, x: 0, y: 4)

                    Image(systemName: getIconName(for: mood))
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.2), lineWidth: isSelected ? 4 : 0)
                        .scaleEffect(1.1)
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)

                Text(mood.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "374151"))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }

    private func getIconName(for mood: MoodType) -> String {
        switch mood {
        case .good: return "face.smiling"
        case .okay: return "face.dashed"
        case .notGood: return "face.frown"
        }
    }

    private func getColor(for mood: MoodType) -> Color {
        switch mood {
        case .good: return .mamaCareCompleted
        case .okay: return .mamaCareDue
        case .notGood: return .mamaCareOverdue
        }
    }
}
