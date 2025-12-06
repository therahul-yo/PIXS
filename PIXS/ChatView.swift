import SwiftUI

struct ChatView: View {
    @StateObject private var dataManager = DataManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var aiService = AIService.shared
    
    var isToolbarVisible: Bool = true // Passed from parent
    
    @State private var inputText: String = ""
    @State private var isLoading = false
    @State private var appearAnimation = false
    
    var theme: AppTheme { AppTheme() }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer() // Main header handles title, this row is just for actions now
                
                if !dataManager.chatMessages.isEmpty {
                    Button(action: {
                        withAnimation(Animations.smooth) {
                            dataManager.clearChat()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 10))
                            Text("Clear")
                                .font(Typography.caption(size: 10))
                        }
                        .foregroundColor(theme.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(theme.cardBackground)
                                .overlay(
                                    Capsule()
                                        .stroke(theme.border, lineWidth: 0.5)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .hoverScale()
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xs)
            
            // Messages
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: Spacing.sm) {
                        if dataManager.chatMessages.isEmpty {
                            // Premium Empty State
                            VStack(spacing: Spacing.lg) {
                                // Clean sparkle icon
                                ZStack {
                                    Circle()
                                        .fill(theme.accentSubtle)
                                        .frame(width: 64, height: 64)
                                    
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundColor(theme.accent)
                                }
                                .scaleEffect(appearAnimation ? 1.0 : 0.5)
                                .opacity(appearAnimation ? 1 : 0)
                                
                                VStack(spacing: Spacing.xs) {
                                    Text("AI Assistant")
                                        .font(Typography.title(size: 16))
                                        .foregroundColor(theme.primaryText)
                                    
                                    Text("Ask me anything about your notes")
                                        .font(Typography.body(size: 12))
                                        .foregroundColor(theme.secondaryText)
                                    
                                    // Quick prompts
                                    VStack(spacing: Spacing.xs) {
                                        QuickPromptButton(text: "Summarize my notes", theme: theme) {
                                            sendMessage("Can you summarize all my notes?")
                                        }
                                        QuickPromptButton(text: "What do I need to do?", theme: theme) {
                                            sendMessage("What tasks or reminders do I have?")
                                        }
                                    }
                                    .padding(.top, Spacing.sm)
                                }
                                .offset(y: appearAnimation ? 0 : 20)
                                .opacity(appearAnimation ? 1 : 0)
                            }
                            .padding(.top, Spacing.xxl)
                        } else {
                            ForEach(Array(dataManager.chatMessages.enumerated()), id: \.element.id) { index, message in
                                ChatBubble(message: message, theme: theme)
                                    .id(message.id)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        
                        if isLoading {
                            HStack {
                                TypingIndicator(theme: theme)
                                Spacer()
                            }
                            .padding(.horizontal, Spacing.md)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
                .onChange(of: dataManager.chatMessages.count) { _, _ in
                    if let lastMessage = dataManager.chatMessages.last {
                        withAnimation(Animations.smooth) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input area
            HStack(spacing: Spacing.sm) {
                // Text input
                HStack(spacing: Spacing.sm) {
                    TextField("Ask something...", text: $inputText)
                        .textFieldStyle(.plain)
                        .font(Typography.body(size: 13))
                        .foregroundColor(theme.primaryText)
                        .onSubmit {
                            sendMessage(inputText)
                        }
                    
                    if !inputText.isEmpty {
                        Button(action: { inputText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(theme.tertiaryText)
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    Capsule()
                        .fill(theme.cardBackground)
                        .overlay(
                            Capsule()
                                .stroke(theme.border, lineWidth: 0.5)
                        )
                )
                
                // Send button
                SendButton(
                    isDisabled: inputText.isEmpty || isLoading,
                    theme: theme,
                    action: { sendMessage(inputText) }
                )
            }
            .padding(.leading, Spacing.md)
            .padding(.trailing, isToolbarVisible ? Spacing.md : 48) // Dynamic padding
            .padding(.vertical, Spacing.sm)
            .animation(Animations.quick, value: inputText.isEmpty)
            .animation(Animations.smooth, value: isToolbarVisible)
        }
        .onAppear {
            withAnimation(Animations.bouncy.delay(0.1)) {
                appearAnimation = true
            }
        }
    }
    
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let userMessage = text
        inputText = ""
        
        withAnimation(Animations.smooth) {
            dataManager.addChatMessage(content: userMessage, isUser: true)
        }
        
        withAnimation(Animations.smooth) {
            isLoading = true
        }
        
        Task {
            let response = await aiService.chat(message: userMessage, context: dataManager.getNotesContext())
            
            await MainActor.run {
                withAnimation(Animations.smooth) {
                    isLoading = false
                    dataManager.addChatMessage(content: response, isUser: false)
                }
            }
        }
    }
}

// MARK: - Send Button
struct SendButton: View {
    let isDisabled: Bool
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isDisabled {
                    Circle()
                        .fill(theme.cardBackground)
                        .frame(width: 34, height: 34)
                } else {
                    Circle()
                        .fill(theme.accentGradient)
                        .frame(width: 34, height: 34)
                }
                
                Image(systemName: "arrow.up")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isDisabled ? theme.tertiaryText : .white)
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .hoverScale(1.08)
    }
}

// MARK: - Quick Prompt Button
struct QuickPromptButton: View {
    let text: String
    let theme: AppTheme
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(Typography.caption())
                .foregroundColor(theme.accent)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(
                    Capsule()
                        .fill(theme.accent.opacity(0.1))
                        .overlay(
                            Capsule()
                                .stroke(theme.accent.opacity(0.2), lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(Animations.quick, value: isHovered)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage
    let theme: AppTheme
    
    @State private var isHovered = false
    @State private var appeared = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            if message.isUser { Spacer(minLength: 48) }
            
            // Avatar for AI
            if !message.isUser {
                ZStack {
                    Circle()
                        .fill(theme.accent.opacity(0.15))
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "sparkle")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(theme.accent)
                }
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: Spacing.xxs) {
                Group {
                    if let attributedString = try? AttributedString(markdown: message.content) {
                        Text(attributedString)
                            .font(Typography.body())
                            .foregroundColor(theme.primaryText)
                            .textSelection(.enabled)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                    } else {
                        Text(message.content)
                            .font(Typography.body())
                            .foregroundColor(theme.primaryText)
                            .textSelection(.enabled)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                    }
                }
                    .background(
                        Group {
                            if message.isUser {
                                RoundedRectangle(cornerRadius: Corners.lg, style: .continuous)
                                    .fill(theme.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Corners.lg, style: .continuous)
                                            .stroke(theme.accent.opacity(0.5), lineWidth: 1)
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: Corners.lg, style: .continuous)
                                    .fill(theme.cardBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Corners.lg, style: .continuous)
                                            .stroke(theme.border, lineWidth: 0.5)
                                    )
                            }
                        }
                    )
                
                // Timestamp on hover
                if isHovered {
                    Text(formatTime(message.timestamp))
                        .font(Typography.caption(size: 9))
                        .foregroundColor(theme.tertiaryText)
                        .transition(.opacity)
                }
            }
            
            if !message.isUser { Spacer(minLength: 48) }
        }
        .scaleEffect(appeared ? 1.0 : 0.9)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(Animations.bouncy) {
                appeared = true
            }
        }
        .onHover { isHovered = $0 }
        .animation(Animations.quick, value: isHovered)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ChatView()
        .environmentObject(ThemeManager.shared)
        .frame(width: 320, height: 350)
}
