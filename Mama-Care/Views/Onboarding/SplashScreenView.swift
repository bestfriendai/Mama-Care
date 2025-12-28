//
//  SplashScreenView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    var onFinish: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.mamaCarePrimary, .mamaCarePrimaryDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                logoSection
                brandingSection

                Spacer()

                loadingDotsSection
            }
        }
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                onFinish()
            }
        }
    }

    // MARK: - Logo Section

    private var logoSection: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 140, height: 140)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)

            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.mamaCarePrimary)

            Image(systemName: "star.fill")
                .font(.system(size: 24))
                .foregroundColor(.mamaCareDue)
                .offset(x: 50, y: -40)
        }
        .scaleEffect(isAnimating ? 1.0 : 0.8)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
    }

    // MARK: - Branding Section

    private var brandingSection: some View {
        VStack(spacing: 12) {
            Text("MamaCare")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)

            Text("Your Pregnancy & Child Health\nCompanion")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Loading Dots

    private var loadingDotsSection: some View {
        HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 10, height: 10)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .padding(.bottom, 60)
    }
}
