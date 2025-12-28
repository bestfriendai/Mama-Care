//
//  AuthService.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 24/11/2025.
//

import Foundation
import FirebaseAuth
import Combine

// MARK: - Auth Error Types

enum AuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case notAuthenticated
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .userNotFound:
            return "No account found with this email."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .weakPassword:
            return "Password must be at least 6 characters."
        case .networkError:
            return "Please check your internet connection."
        case .notAuthenticated:
            return "You need to sign in first."
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Auth Service Protocol

protocol AuthServiceProtocol: AnyObject {
    var currentUser: FirebaseAuth.User? { get }

    func signUp(email: String, password: String) async throws -> AuthDataResult
    func signIn(email: String, password: String) async throws -> AuthDataResult
    func signOut() throws
    func deleteAccount() async throws
}

// MARK: - Auth Service Implementation

final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()

    private init() {}

    // MARK: - Current User

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    // MARK: - Sign Up (Async)

    func signUp(email: String, password: String) async throws -> AuthDataResult {
        do {
            return try await Auth.auth().createUser(withEmail: email, password: password)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Sign In (Async)

    func signIn(email: String, password: String) async throws -> AuthDataResult {
        do {
            return try await Auth.auth().signIn(withEmail: email, password: password)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Sign Out

    func signOut() throws {
        try Auth.auth().signOut()
    }

    // MARK: - Delete Account (Async)

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.notAuthenticated
        }

        do {
            try await user.delete()
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    // MARK: - Legacy Combine Support (for backward compatibility)

    func signUpPublisher(email: String, password: String) -> Future<AuthDataResult, Error> {
        Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let result = result {
                    promise(.success(result))
                }
            }
        }
    }

    func signInPublisher(email: String, password: String) -> Future<AuthDataResult, Error> {
        Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let result = result {
                    promise(.success(result))
                }
            }
        }
    }

    // MARK: - Error Mapping

    private func mapFirebaseError(_ error: NSError) -> AuthError {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return .unknown(error.localizedDescription)
        }

        switch errorCode {
        case .wrongPassword, .invalidEmail, .invalidCredential:
            return .invalidCredentials
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
