//
//  PaywallView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

// MARK: - Subscription Package Model

struct SubscriptionPackage: Identifiable, Equatable {
    let id: String
    let name: String
    let duration: String
    let price: String
    let pricePerMonth: String?
    let isBestValue: Bool

    static let monthly = SubscriptionPackage(
        id: "monthly",
        name: "Monthly",
        duration: "1 month",
        price: "£4.99",
        pricePerMonth: nil,
        isBestValue: false
    )

    static let yearly = SubscriptionPackage(
        id: "yearly",
        name: "Yearly",
        duration: "12 months",
        price: "£39.99",
        pricePerMonth: "£3.33/mo",
        isBestValue: true
    )
}

// MARK: - Paywall View

struct PaywallView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedPackage: SubscriptionPackage = .yearly
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?
    @State private var showError = false

    // Simulated packages - replace with RevenueCat offerings
    private let packages: [SubscriptionPackage] = [.monthly, .yearly]

    var body: some View {
        ZStack {
            backgroundGradient
            mainContent

            if isPurchasing || isRestoring {
                loadingOverlay
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Something went wrong")
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [.mamaCarePrimary, .mamaCarePrimaryDark]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            closeButton

            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    featuresSection
                    pricingSection
                    termsSection
                }
            }
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.mamaCareDue)

            Text("Upgrade to Premium")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("Unlock all features and get the most out of MamaCare")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 20)
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(spacing: 16) {
            FeatureRow(icon: "phone.fill", title: "Emergency Escalation", description: "One-tap emergency alerts to your contacts")
            FeatureRow(icon: "message.fill", title: "Unlimited AI Chat", description: "24/7 access to AI pregnancy companion")
            FeatureRow(icon: "bell.badge.fill", title: "Priority Notifications", description: "Never miss important reminders")
            FeatureRow(icon: "cloud.fill", title: "iCloud Sync", description: "Access your data across all devices")
            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Advanced Analytics", description: "Detailed insights into your journey")
            FeatureRow(icon: "heart.text.square.fill", title: "Premium Content", description: "Exclusive tips and resources")
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    // MARK: - Pricing Section

    private var pricingSection: some View {
        VStack(spacing: 20) {
            // Package Selection
            VStack(spacing: 12) {
                ForEach(packages) { package in
                    PackageCard(
                        package: package,
                        isSelected: selectedPackage.id == package.id,
                        onSelect: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedPackage = package
                            }
                        }
                    )
                }
            }

            // Subscribe Button
            Button {
                Task { await purchase() }
            } label: {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "crown.fill")
                        Text("Start Premium")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.mamaCareDue, .mamaCareOrange]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(isPurchasing || isRestoring)

            // Restore Button
            Button {
                Task { await restore() }
            } label: {
                if isRestoring {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Restore Purchases")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .disabled(isPurchasing || isRestoring)
        }
        .padding()
        .background(Color.white.opacity(0.15))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    // MARK: - Terms Section

    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("Subscription automatically renews unless cancelled")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 16) {
                Button("Terms of Service") {
                    if let url = URL(string: "https://yourdomain.com/terms") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption2)
                .foregroundColor(.white.opacity(0.9))

                Text("•")
                    .foregroundColor(.white.opacity(0.5))

                Button("Privacy Policy") {
                    if let url = URL(string: "https://yourdomain.com/privacy") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption2)
                .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.bottom, 40)
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text(isPurchasing ? "Processing..." : "Restoring...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(32)
            .background(Color.mamaCarePrimary.opacity(0.9))
            .cornerRadius(16)
        }
    }

    // MARK: - Actions

    private func purchase() async {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isPurchasing = true

        // TODO: Replace with RevenueCat implementation
        // Example:
        // do {
        //     let result = try await Purchases.shared.purchase(package: selectedPackage.rcPackage)
        //     if result.customerInfo.entitlements["premium"]?.isActive == true {
        //         dismiss()
        //     }
        // } catch {
        //     errorMessage = error.localizedDescription
        //     showError = true
        // }

        // Simulated delay for demo
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        isPurchasing = false
        viewModel.purchaseSubscription()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }

    private func restore() async {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isRestoring = true

        // TODO: Replace with RevenueCat implementation
        // do {
        //     let customerInfo = try await Purchases.shared.restorePurchases()
        //     if customerInfo.entitlements["premium"]?.isActive == true {
        //         dismiss()
        //     }
        // } catch {
        //     errorMessage = error.localizedDescription
        //     showError = true
        // }

        try? await Task.sleep(nanoseconds: 1_500_000_000)

        isRestoring = false
        viewModel.restorePurchases()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - Package Card

struct PackageCard: View {
    let package: SubscriptionPackage
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(package.name)
                            .font(.headline)
                            .foregroundColor(.mamaCareTextPrimary)

                        if package.isBestValue {
                            Text("BEST VALUE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.mamaCarePrimary)
                                .cornerRadius(4)
                        }
                    }

                    Text(package.duration)
                        .font(.caption)
                        .foregroundColor(.mamaCareTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(package.price)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.mamaCarePrimary)

                    if let pricePerMonth = package.pricePerMonth {
                        Text(pricePerMonth)
                            .font(.caption)
                            .foregroundColor(.mamaCareTextSecondary)
                    }
                }

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .mamaCarePrimary : .gray.opacity(0.4))
                    .padding(.leading, 8)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.mamaCarePrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
    }
}
