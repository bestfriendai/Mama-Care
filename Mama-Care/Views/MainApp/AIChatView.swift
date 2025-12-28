//
//  AIChatView.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 19/11/2025.
//

import SwiftUI

struct AIChatView: View {
    @EnvironmentObject var viewModel: MamaCareViewModel
    @State private var messageText = ""
    @State private var showDisclaimer = true
    @State private var isSending = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    headerSection
                    messagesSection
                    inputSection
                }

                if showDisclaimer {
                    DisclaimerOverlay {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showDisclaimer = false
                        }
                        HapticFeedback.medium()
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            VStack(spacing: 2) {
                Text("AI Chat")
                    .font(.headline)
                    .foregroundColor(.mamaCareTextPrimary)

                Text("Your pregnancy companion")
                    .font(.caption)
                    .foregroundColor(.mamaCareTextSecondary)
            }

            Spacer()

            Button {
                HapticFeedback.light()
                showDisclaimer = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.mamaCareTextPrimary)
            }
        }
        .padding()
        .background(Color.white)
        .subtleShadow()
    }

    // MARK: - Messages Section

    private var messagesSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(Array(viewModel.chatMessages.enumerated()), id: \.element.id) { index, message in
                        MessageBubble(message: message)
                            .staggeredAnimation(index: index)
                            .id(message.id)
                    }
                }
                .padding()
            }
            .background(Color.mamaCareGrayLight)
            .onChange(of: viewModel.chatMessages.count) { _, _ in
                if let lastMessage = viewModel.chatMessages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        HStack(spacing: 12) {
            TextField("Type your message...", text: $messageText)
                .padding()
                .background(Color.mamaCareGrayMedium)
                .cornerRadius(24)
                .focused($isInputFocused)
                .onSubmit {
                    sendMessage()
                }

            Button {
                sendMessage()
            } label: {
                ZStack {
                    if isSending {
                        ProgressView()
                            .tint(.mamaCarePrimary)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(messageText.isEmpty ? .mamaCareTextTertiary : .mamaCarePrimary)
                    }
                }
                .frame(width: 36, height: 36)
            }
            .disabled(messageText.isEmpty || isSending)
        }
        .padding()
        .background(Color.white)
    }

    // MARK: - Send Message

    private func sendMessage() {
        guard !messageText.isEmpty else { return }

        HapticFeedback.light()
        isSending = true

        let message = messageText
        messageText = ""
        isInputFocused = false

        viewModel.sendChatMessage(message)

        // Simulate response delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSending = false
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(message.isUser ? .white : .mamaCareTextPrimary)
                    .padding()
                    .background(message.isUser ? Color.mamaCarePrimary : Color.white)
                    .cornerRadius(20)
                    .cardShadow()

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.mamaCareTextTertiary)
            }
            .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)

            if !message.isUser {
                Spacer()
            }
        }
    }
}

// MARK: - Disclaimer Overlay

struct DisclaimerOverlay: View {
    let onAccept: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.mamaCareDueBg)
                        .frame(width: 80, height: 80)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.mamaCareDue)
                }

                VStack(spacing: 12) {
                    Text("Important Disclaimer")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.mamaCareTextPrimary)

                    Text("This AI chat is for informational purposes only and does not provide medical advice. Always consult with your healthcare provider for medical concerns.")
                        .font(.body)
                        .foregroundColor(.mamaCareTextDark)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Button {
                    onAccept()
                } label: {
                    Text("I Understand")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mamaCarePrimary)
                        .cornerRadius(12)
                }
            }
            .padding(32)
            .background(Color.white)
            .cornerRadius(24)
            .elevatedShadow()
            .padding(40)
        }
    }
}
