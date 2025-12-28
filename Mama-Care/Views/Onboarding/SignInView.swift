//
//  SignInView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 06/11/2025.
//

import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var rememberMe: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    @EnvironmentObject var viewModel: MamaCareViewModel

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                gradientHeader
                contentSection

                if isLoading {
                    loadingOverlay
                }
            }
            .background(Color(.sRGB, red: 0.94, green: 0.99, blue: 0.98, opacity: 1.0))
        }
    }

    // MARK: - Gradient Header

    private var gradientHeader: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 0.0, green: 0.733, blue: 0.655, opacity: 1.0),
                Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4, opacity: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 260)
        .edgesIgnoringSafeArea(.top)
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(spacing: 0) {
            welcomeHeader
            loginCard
            Spacer()
        }
    }

    // MARK: - Welcome Header

    private var welcomeHeader: some View {
        VStack(spacing: 8) {
            Text("Welcome Back")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Text("Log in to continue your journey")
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.top, 40)
    }

    // MARK: - Login Card

    private var loginCard: some View {
        VStack(spacing: 20) {
            cardHeader
            emailField
            passwordField
            rememberAndForgotRow
            loginButton
            divider
            signUpRow
        }
        .padding()
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .offset(y: 40)
    }

    // MARK: - Card Header

    private var cardHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Login to Your Account")
                .font(.headline)
            Text("Enter your credentials to access your personal care dashboard")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Email Field

    private var emailField: some View {
        HStack {
            Image(systemName: "envelope")
                .foregroundColor(.gray)
            TextField("your.email@example.com", text: $email)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }

    // MARK: - Password Field

    private var passwordField: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.gray)
            if isPasswordVisible {
                TextField("Enter your password", text: $password)
                    .textContentType(.password)
            } else {
                SecureField("Enter your password", text: $password)
                    .textContentType(.password)
            }
            Button(action: {
                isPasswordVisible.toggle()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }

    // MARK: - Remember & Forgot Row

    private var rememberAndForgotRow: some View {
        HStack {
            Toggle(isOn: $rememberMe) {
                Text("Remember me")
                    .font(.subheadline)
            }
            .toggleStyle(MamaCheckboxToggleStyle())

            Spacer()

            Button("Forgot password?") {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                // TODO: Implement forgot password flow
            }
            .font(.subheadline)
            .foregroundColor(Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4, opacity: 1.0))
        }
    }

    // MARK: - Login Button

    private var loginButton: some View {
        Button(action: {
            handleLogin()
        }) {
            Text("Log In")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(isLoading)
        .alert("Login Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Divider

    private var divider: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
            Text("or")
                .foregroundColor(.gray)
            Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
        }
    }

    // MARK: - Sign Up Row

    private var signUpRow: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.gray)
            NavigationLink(destination: CreateAccountFlowView()) {
                Text("Sign up")
                    .foregroundColor(Color(.sRGB, red: 0.0, green: 0.6, blue: 0.4, opacity: 1.0))
            }
        }
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Signing in...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(32)
            .background(Color.mamaCarePrimary.opacity(0.9))
            .cornerRadius(16)
        }
    }

    // MARK: - Login Logic

    private func handleLogin() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            showError = true
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        isLoading = true

        viewModel.login(email: email, password: password) { result in
            isLoading = false
            switch result {
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}
