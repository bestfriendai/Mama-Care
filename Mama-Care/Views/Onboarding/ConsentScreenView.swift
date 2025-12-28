//
//  ConsentScreenView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 04/11/2025.
//

import SwiftUI

struct ConsentScreenView: View {
    @ObservedObject var onboardingVM: OnboardingViewModel
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var showValidationError = false

    var body: some View {
        ZStack {
            Color.mamaCarePrimaryBg.ignoresSafeArea()

            LinearGradient(
                colors: [Color(hex: "F3F3F5"), .mamaCareGrayLight],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    storageOptionsSection
                    consentTogglesSection
                    validationErrorSection
                    navigationButtonsSection
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "shield.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
                .padding(16)
                .background(Color.mamaCarePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("Privacy & Data Storage")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)

            Text("Choose how your data is stored and review our privacy practices")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 24)
    }

    // MARK: - Storage Options

    private var storageOptionsSection: some View {
        VStack(spacing: 20) {
            storageCard(
                option: .deviceOnly,
                icon: "iphone",
                iconColor: Color(hex: "D0E8FF"),
                title: "Device-Only Storage",
                points: [
                    ConsentPoint(color: .green, text: "Highest privacy - data never leaves device"),
                    ConsentPoint(color: .green, text: "No internet required"),
                    ConsentPoint(color: .red, text: "Data lost if device is lost")
                ]
            )

            storageCard(
                option: .cloud,
                icon: "icloud",
                iconColor: Color(hex: "F3E8FF"),
                title: "Cloud (Firebase)",
                points: [
                    ConsentPoint(color: .green, text: "Access from multiple devices"),
                    ConsentPoint(color: .green, text: "Automatic backup"),
                    ConsentPoint(color: .green, text: "Securely stored in Firebase")
                ]
            )
        }
    }

    // MARK: - Consent Toggles

    private var consentTogglesSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Required Consents")
                .font(.system(size: 17, weight: .semibold))

            Toggle(isOn: $onboardingVM.acceptedTerms) {
                HStack(spacing: 0) {
                    Text("I accept the ")
                    Text("Terms & Conditions")
                        .underline()
                        .foregroundColor(.mamaCarePrimary)
                        .onTapGesture { openLink("https://yourdomain.com/terms") }
                    Text(" *").foregroundColor(.red)
                }
            }
            .toggleStyle(MamaCheckboxToggleStyle())

            Toggle(isOn: $onboardingVM.acceptedPrivacy) {
                HStack(spacing: 0) {
                    Text("I have read and agree to the ")
                    Text("Privacy Policy")
                        .underline()
                        .foregroundColor(.mamaCarePrimary)
                        .onTapGesture { openLink("https://yourdomain.com/privacy") }
                    Text(" *").foregroundColor(.red)
                }
            }
            .toggleStyle(MamaCheckboxToggleStyle())

            Toggle(isOn: $onboardingVM.wantsReminders) {
                Text("I want to receive daily mood check-in reminders (optional)")
            }
            .toggleStyle(MamaCheckboxToggleStyle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
    }

    // MARK: - Validation Error

    @ViewBuilder
    private var validationErrorSection: some View {
        if showValidationError {
            Text("Please select a storage option and accept all required consents.")
                .font(.system(size: 14))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtonsSection: some View {
        HStack(spacing: 16) {
            Button("Back") {
                onBack()
            }
            .buttonStyle(SecondaryButtonStyle())

            Button("Continue") {
                validateAndContinue()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
    }

    // MARK: - Storage Card

    private func storageCard(
        option: StorageMode,
        icon: String,
        iconColor: Color,
        title: String,
        points: [ConsentPoint]
    ) -> some View {
        let isSelected = onboardingVM.storageOption == option

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
                    .padding(12)
                    .background(iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .mamaCarePrimary : Color.gray.opacity(0.4))
            }

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.black)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(points) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: point.color == .red ? "exclamationmark.circle" : "checkmark.circle")
                            .foregroundColor(point.color == .red ? Color(hex: "BB4D00") : .green)
                            .font(.system(size: 16))

                        Text(point.text)
                            .font(.system(size: 15))
                            .foregroundColor(point.color == .red ? Color(hex: "BB4D00") : .black)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.mamaCarePrimary : .clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                onboardingVM.storageOption = option
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    // MARK: - Actions

    private func validateAndContinue() {
        if onboardingVM.canCompleteAccount {
            showValidationError = false
            onNext()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                showValidationError = true
            }
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }

    private func openLink(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
