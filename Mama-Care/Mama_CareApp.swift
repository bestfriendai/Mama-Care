//
//  Mama_CareApp.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//

import SwiftUI
import FirebaseCore
import SwiftData

@main
struct MamaCareApp: App {
    @StateObject private var viewModel = MamaCareViewModel()
    @StateObject private var onboardingVM = OnboardingViewModel()
    @State private var showSplash = true
    @State private var firebaseConfigured = false

    init() {
        configureFirebase()
    }

    private func configureFirebase() {
        // Firebase configuration with error handling
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        firebaseConfigured = true
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSplash = false
                        }
                    }
                } else {
                    rootView
                }
            }
            .environmentObject(viewModel)
            .environmentObject(onboardingVM)
        }
        .modelContainer(for: [UserProfile.self, MoodEntry.self, Contact.self])
    }

    @ViewBuilder
    private var rootView: some View {
        if viewModel.isLoggedIn {
            MainTabView()
        } else {
            AuthLandingView()
        }
    }
}
