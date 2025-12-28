//
//  DesignTokens.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 27/12/2025.
//

import SwiftUI

// MARK: - Spacing System

enum Spacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius

enum CornerRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let full: CGFloat = 9999
}

// MARK: - Typography

extension Font {
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headlineLarge = Font.system(size: 22, weight: .semibold)
    static let headlineMedium = Font.system(size: 18, weight: .semibold)
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let labelLarge = Font.system(size: 14, weight: .medium)
    static let labelMedium = Font.system(size: 12, weight: .medium)
    static let captionLarge = Font.system(size: 13, weight: .regular)
    static let captionSmall = Font.system(size: 11, weight: .regular)
}

// MARK: - Animation Tokens

enum AnimationToken {
    static let quick = Animation.spring(response: 0.25, dampingFraction: 0.8)
    static let standard = Animation.spring(response: 0.35, dampingFraction: 0.85)
    static let slow = Animation.spring(response: 0.5, dampingFraction: 0.9)
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)

    static let quickEase = Animation.easeInOut(duration: 0.2)
    static let standardEase = Animation.easeInOut(duration: 0.3)
    static let slowEase = Animation.easeInOut(duration: 0.5)
}

// MARK: - Shadow Extensions

extension View {
    func subtleShadow() -> some View {
        shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    func cardShadow() -> some View {
        shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    func elevatedShadow() -> some View {
        shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
    }

    func coloredShadow(_ color: Color, opacity: Double = 0.3) -> some View {
        shadow(color: color.opacity(opacity), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Haptic Feedback Helpers

enum HapticFeedback {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - Skeleton Loader Modifier

struct SkeletonModifier: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.2),
                        Color.gray.opacity(0.4),
                        Color.gray.opacity(0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: isAnimating ? 300 : -300)
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

extension View {
    func skeleton() -> some View {
        modifier(SkeletonModifier())
    }
}

// MARK: - Staggered Animation Modifier

struct StaggeredAnimationModifier: ViewModifier {
    let index: Int
    let delay: Double
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(
                AnimationToken.standard.delay(Double(index) * delay),
                value: appeared
            )
            .onAppear {
                appeared = true
            }
    }
}

extension View {
    func staggeredAnimation(index: Int, delay: Double = 0.05) -> some View {
        modifier(StaggeredAnimationModifier(index: index, delay: delay))
    }
}

// MARK: - Skeleton Placeholder Views

struct SkeletonRectangle: View {
    let width: CGFloat?
    let height: CGFloat

    init(width: CGFloat? = nil, height: CGFloat = 20) {
        self.width = width
        self.height = height
    }

    var body: some View {
        RoundedRectangle(cornerRadius: CornerRadius.sm)
            .fill(Color.gray.opacity(0.2))
            .frame(width: width, height: height)
            .skeleton()
    }
}

struct SkeletonCircle: View {
    let size: CGFloat

    init(size: CGFloat = 48) {
        self.size = size
    }

    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: size, height: size)
            .skeleton()
    }
}

// MARK: - Card Skeleton

struct CardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                SkeletonCircle(size: 48)
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    SkeletonRectangle(width: 120, height: 16)
                    SkeletonRectangle(width: 80, height: 12)
                }
            }
            SkeletonRectangle(height: 16)
            SkeletonRectangle(width: 200, height: 16)
        }
        .padding(Spacing.md)
        .background(Color.white)
        .cornerRadius(CornerRadius.lg)
        .cardShadow()
    }
}

// MARK: - App Error Types

enum AppError: LocalizedError, Equatable {
    case networkError
    case authenticationFailed(String)
    case dataNotFound
    case saveFailed
    case invalidInput(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Please check your internet connection and try again."
        case .authenticationFailed(let message):
            return message
        case .dataNotFound:
            return "The requested data could not be found."
        case .saveFailed:
            return "Failed to save your data. Please try again."
        case .invalidInput(let field):
            return "Please check the \(field) field and try again."
        case .unknown(let message):
            return message
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Try again when you have a stable internet connection."
        case .authenticationFailed:
            return "Check your credentials and try again."
        default:
            return nil
        }
    }
}
