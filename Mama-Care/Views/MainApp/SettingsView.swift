//
//  SettingsView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 24/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel

    // Profile fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var mobileNumber: String = ""

    // Notification settings
    @State private var notificationsEnabled: Bool = true
    @State private var firstCheckInTime = Date()
    @State private var secondCheckInTime = Date()
    @State private var thirdCheckInTime = Date()

    // Alerts
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false
    @State private var showSaveSuccess = false
    @State private var isSaving = false
    @State private var isDeleting = false

    var body: some View {
        NavigationStack {
            Form {
                profileSection
                notificationsSection
                accountSection
                appInfoSection
            }
            .navigationTitle("Settings")
            .onAppear {
                loadUserData()
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    HapticFeedback.medium()
                    viewModel.logout()
                }
            } message: {
                Text("Are you sure you want to logout? Your data will be preserved.")
            }
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("This will permanently delete your account and all data. This action cannot be undone.")
            }
            .alert("Saved", isPresented: $showSaveSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your profile has been updated successfully.")
            }
        }
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        Section {
            TextField("First Name", text: $firstName)
                .textContentType(.givenName)
            TextField("Last Name", text: $lastName)
                .textContentType(.familyName)
            TextField("Mobile Number", text: $mobileNumber)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)

            Button {
                saveProfile()
            } label: {
                HStack {
                    if isSaving {
                        ProgressView()
                            .padding(.trailing, 8)
                    }
                    Text(isSaving ? "Saving..." : "Save Changes")
                }
            }
            .foregroundColor(.mamaCarePrimary)
            .disabled(firstName.isEmpty || lastName.isEmpty || isSaving)
        } header: {
            Text("Profile")
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        Section {
            Toggle("Enable Notifications", isOn: $notificationsEnabled)
                .tint(.mamaCarePrimary)
                .onChange(of: notificationsEnabled) { _, newValue in
                    HapticFeedback.light()
                    handleNotificationToggle(newValue)
                }

            if notificationsEnabled {
                DatePicker("First Check-in", selection: $firstCheckInTime, displayedComponents: .hourAndMinute)
                    .onChange(of: firstCheckInTime) { _, _ in
                        updateNotificationTimes()
                    }

                DatePicker("Second Check-in", selection: $secondCheckInTime, displayedComponents: .hourAndMinute)
                    .onChange(of: secondCheckInTime) { _, _ in
                        updateNotificationTimes()
                    }

                DatePicker("Third Check-in", selection: $thirdCheckInTime, displayedComponents: .hourAndMinute)
                    .onChange(of: thirdCheckInTime) { _, _ in
                        updateNotificationTimes()
                    }
            }
        } header: {
            Text("Mood Check-in Reminders")
        } footer: {
            if notificationsEnabled {
                Text("You'll receive daily reminders at these times to check in on your mood.")
            }
        }
    }

    // MARK: - Account Section

    private var accountSection: some View {
        Section {
            Button {
                HapticFeedback.light()
                showLogoutAlert = true
            } label: {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
            }
            .foregroundColor(.blue)

            Button {
                HapticFeedback.warning()
                showDeleteAlert = true
            } label: {
                HStack {
                    if isDeleting {
                        ProgressView()
                            .padding(.trailing, 8)
                    }
                    Label(isDeleting ? "Deleting..." : "Delete Account", systemImage: "trash")
                }
            }
            .foregroundColor(.red)
            .disabled(isDeleting)
        } header: {
            Text("Account")
        }
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("MamaCare v\(appVersion)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Build \(buildNumber)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("© 2025 MamaCare")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }

    // MARK: - App Version Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Helper Methods

    private func loadUserData() {
        guard let user = viewModel.currentUser else { return }

        firstName = user.firstName
        lastName = user.lastName
        mobileNumber = user.mobileNumber
        notificationsEnabled = user.notificationsWanted

        let calendar = Calendar.current
        firstCheckInTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        secondCheckInTime = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: Date()) ?? Date()
        thirdCheckInTime = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    }

    private func saveProfile() {
        HapticFeedback.light()
        isSaving = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.updateProfile(
                firstName: firstName,
                lastName: lastName,
                mobileNumber: mobileNumber
            )
            isSaving = false
            showSaveSuccess = true
            HapticFeedback.success()
        }
    }

    private func handleNotificationToggle(_ enabled: Bool) {
        viewModel.updateNotificationPreference(enabled: enabled)

        if enabled {
            Task {
                let granted = await viewModel.notificationService.requestAuthorization()
                if granted {
                    updateNotificationTimes()
                }
            }
        } else {
            viewModel.notificationService.cancelMoodCheckInNotifications()
            viewModel.notificationService.cancelAllVaccineReminders()
        }
    }

    private func updateNotificationTimes() {
        let calendar = Calendar.current
        let times = [
            calendar.component(.hour, from: firstCheckInTime),
            calendar.component(.hour, from: secondCheckInTime),
            calendar.component(.hour, from: thirdCheckInTime)
        ]

        viewModel.notificationService.scheduleMoodCheckInNotifications(times: times)
    }

    private func deleteAccount() {
        HapticFeedback.heavy()
        isDeleting = true

        viewModel.deleteAccount { result in
            isDeleting = false
            switch result {
            case .success:
                HapticFeedback.success()
            case .failure:
                HapticFeedback.error()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(MamaCareViewModel())
}
