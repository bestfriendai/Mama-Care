//
//  OnboardingFlowView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 06/11/2025.
//

import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @StateObject private var onboardingVM = OnboardingViewModel()

    @State private var step: OnboardingStep = .personalInfo

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                Group {
                    switch step {
                    case .personalInfo:
                        CreateAccountStepOneView(
                            onboardingVM: onboardingVM,
                            onNext: handlePersonalInfo
                        )
                    case .accountInfo:
                        CreateAccountStepTwoView(
                            onboardingVM: onboardingVM,
                            onBack: goBack,
                            onCreateAccount: handleAccountInfo
                        )
                    case .consent:
                        ConsentScreenView(
                            onboardingVM: onboardingVM,
                            onNext: handleConsent,
                            onBack: goBack
                        )
                    case .userType:
                        UserTypeSelectionView(
                            onboardingVM: onboardingVM,
                            onNext: handleUserType,
                            onBack: goBack
                        )
                    case .dateCapture:
                        DateCaptureView(
                            onboardingVM: onboardingVM,
                            onNext: handleDateCapture,
                            onBack: goBack
                        )
                    case .emergencyContacts:
                        EmergencyContactsView(
                            onFinish: completeOnboarding,
                            onBack: goBack
                        )
                    }
                }
                .environmentObject(viewModel)
                .environmentObject(onboardingVM)
            }
        }
    }

    // MARK: - Navigation Handlers

    private func handlePersonalInfo() {
        if onboardingVM.isPersonalInfoValid {
            withAnimation(.easeInOut(duration: 0.3)) {
                step = .accountInfo
            }
        } else {
            onboardingVM.showPersonalInfoError = true
        }
    }

    private func handleAccountInfo() {
        if onboardingVM.isAccountInfoValid {
            withAnimation(.easeInOut(duration: 0.3)) {
                step = .consent
            }
        } else {
            onboardingVM.showAccountInfoError = true
        }
    }

    private func handleConsent() {
        if onboardingVM.canCompleteAccount {
            onboardingVM.user.privacyAcceptedAt = Date()
            withAnimation(.easeInOut(duration: 0.3)) {
                step = .userType
            }
        } else {
            onboardingVM.showConsentError = true
        }
    }

    private func handleUserType() {
        if onboardingVM.user.userType != nil {
            withAnimation(.easeInOut(duration: 0.3)) {
                step = .dateCapture
            }
        }
    }

    private func handleDateCapture() {
        if onboardingVM.isDateValid {
            withAnimation(.easeInOut(duration: 0.3)) {
                step = .emergencyContacts
            }
        } else {
            onboardingVM.showDateError = true
        }
    }

    private func completeOnboarding() {
        viewModel.completeOnboarding(
            with: onboardingVM.user,
            password: onboardingVM.password,
            storage: onboardingVM.storageOption,
            wantsReminders: onboardingVM.wantsReminders
        )
    }

    private func goBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            switch step {
            case .accountInfo:
                step = .personalInfo
            case .consent:
                step = .accountInfo
            case .userType:
                step = .consent
            case .dateCapture:
                step = .userType
            case .emergencyContacts:
                step = .dateCapture
            default:
                break
            }
        }
    }
}

enum OnboardingStep {
    case personalInfo, accountInfo, consent, userType, dateCapture, emergencyContacts
}
