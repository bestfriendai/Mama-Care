//
//  EmergencyView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 03/11/2025.
//

import SwiftUI

struct EmergencyView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var isSendingAlert = false
    @State private var alertSent = false
    @State private var showingAlertConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header

                    if alertSent {
                        EmergencySuccessView()
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else if isSendingAlert {
                        EmergencySendingView()
                            .transition(.opacity)
                    } else {
                        EmergencyContactsSection()
                            .transition(.opacity)
                    }
                }
                .padding(.vertical)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: alertSent)
                .animation(.easeInOut(duration: 0.3), value: isSendingAlert)
            }
            .navigationBarHidden(true)
            .alert("Send Emergency Alert?", isPresented: $showingAlertConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Send Alert", role: .destructive) {
                    sendEmergencyAlert()
                }
            } message: {
                Text("This will alert all contacts with your location.")
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("MamaCare")
                .font(.title)
                .fontWeight(.bold)

            Text("Welcome, \(viewModel.currentUser?.firstName ?? "User")")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Simulated Alert Logic

    private func sendEmergencyAlert() {
        HapticFeedback.heavy()
        isSendingAlert = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSendingAlert = false
            alertSent = true
            HapticFeedback.success()

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    alertSent = false
                }
            }
        }
    }
}

// MARK: - Emergency Sending View

struct EmergencySendingView: View {
    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.red)

            VStack(spacing: 12) {
                Text("Sending Emergency Alert...")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("Notifying your emergency contacts with your location and emergency details.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
}

// MARK: - Emergency Success View

struct EmergencySuccessView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .scaleEffect(isAnimating ? 1.0 : 0.5)
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)

            VStack(spacing: 12) {
                Text("Alert Sent Successfully!")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Your emergency contacts have been notified with your location. Help is on the way.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(isAnimating ? 1.0 : 0.0)
            .offset(y: isAnimating ? 0 : 20)
            .animation(.easeOut(duration: 0.4).delay(0.2), value: isAnimating)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
        .onAppear {
            isAnimating = true
        }
    }
}
