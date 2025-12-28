//
//  AuthLandingView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 04/11/2025.
//

import SwiftUI

struct AuthLandingView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                Spacer()

                brandingSection

                Spacer()

                navigationButtonsSection
                privacyPolicySection
            }
            .navigationBarHidden(true)
            .navigationDestination(for: AuthDestination.self) { destination in
                switch destination {
                case .signIn:
                    SignInView()
                case .createAccount:
                    CreateAccountFlowView()
                }
            }
        }
    }

    // MARK: - Branding Section

    private var brandingSection: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.mamaCareGradient)
                    .frame(width: 120, height: 120)

                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                Text("MamaCare")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.mamaCareGradient)

                Text("Your Pregnancy & Child Health Companion")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtonsSection: some View {
        VStack(spacing: 16) {
            Button("Sign In") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                navigationPath.append(AuthDestination.signIn)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Create Account") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                navigationPath.append(AuthDestination.createAccount)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Privacy Policy

    private var privacyPolicySection: some View {
        Text("By continuing you agree to our Privacy Policy and Terms.")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .padding(.top, 20)
            .padding(.bottom, 40)
    }
}

// MARK: - Navigation Destination

enum AuthDestination: Hashable {
    case signIn
    case createAccount
}
