import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0
    @State private var showingSettings = false
    @State private var showToolbar = true
    
    // Popover animation states
    @State private var popoverScale: CGFloat = 0.95
    @State private var popoverOpacity: CGFloat = 0
    @State private var popoverOffset: CGFloat = 8
    
    var theme: AppTheme { AppTheme() }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView(theme: theme)
            
            // Tab Content with smooth transitions
            Group {
                if showingSettings {
                    InlineSettingsView(theme: theme, showingSettings: $showingSettings)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .trailing)),
                            removal: .scale(scale: 0.95).combined(with: .opacity).combined(with: .move(edge: .trailing))
                        ))
                } else {
                    TabContent(selectedTab: selectedTab, showToolbar: showToolbar, theme: theme)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .leading))
                        ))
                }
            }
            .frame(maxHeight: .infinity)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showingSettings)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedTab)
            
            // Tab Bar with animations
            if !showingSettings && showToolbar {
                TabBarView(selectedTab: $selectedTab, theme: theme)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
        }
        .frame(width: 320, height: 420)
        .background(
            ZStack {
                // Dark gray frosted glass base
                Color(white: 0.08)
                
                // Frosted glass overlay with subtle gradient
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.06),
                        Color.white.opacity(0.02),
                        Color.white.opacity(0.04)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Material blur effect
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Corners.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Corners.lg, style: .continuous)
                .stroke(theme.border, lineWidth: 0.5)
        )
        .overlay(alignment: .bottomTrailing) {
            // Floating Dropover Toggle Button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showToolbar.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(theme.cardBackground)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(theme.border, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 4, y: 2)
                    
                    Image(systemName: showToolbar ? "chevron.down" : "chevron.up")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(theme.secondaryText)
                }
            }
            .buttonStyle(.plain)
            .padding(.trailing, 12)
            .padding(.bottom, 12)
            .hoverScale(1.1)
        }
        .scaleEffect(popoverScale)
        .opacity(popoverOpacity)
        .offset(y: popoverOffset)
        .environmentObject(themeManager)
        .onAppear {
            // Premium opening animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                popoverScale = 1.0
                popoverOpacity = 1.0
                popoverOffset = 0
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShowSettings"))) { _ in
            withAnimation(Animations.smooth) {
                showingSettings = true
            }
        }
    }
}

// MARK: - Tab Content
struct TabContent: View {
    let selectedTab: Int
    let showToolbar: Bool
    let theme: AppTheme
    
    var body: some View {
        ZStack {
            switch selectedTab {
            case 0:
                NotesView()
                    .id(0)
            case 1:
                RemindersView()
                    .id(1)
            case 2:
                ChatView(isToolbarVisible: showToolbar)
                    .id(2)
            default:
                NotesView()
            }
        }
    }
}

// MARK: - Header View with Animated PIXS Logo
struct HeaderView: View {
    let theme: AppTheme
    
    @State private var currentEmoji = "👾"
    @State private var spinRotation: Double = 0
    @State private var letterOffsets: [CGFloat] = [0, 0, 0, 0]
    @State private var letterScales: [CGFloat] = [1, 1, 1, 1]
    @State private var letterRotations: [Double] = [0, 0, 0, 0]
    @State private var animationTimer: Timer?
    @State private var showSettingsMenu = false
    
    let emojis = ["👾", "🎮", "🕹️", "🚀", "⭐", "🌟", "💫", "✨", "🔥", "💎", "🎯", "🎪", "🎨", "🎭", "🎬", "🎵", "🎸", "🎹", "🎺", "🥁", "🌈", "🌙", "☀️", "⚡", "💥", "🌸", "🍀", "🌺", "🦋", "🐱", "🐶", "🦊", "🐼", "🐨", "🦁", "🐯", "🐻", "🐵", "🦄", "🐲", "👻", "👽", "🤖", "💀", "🎃", "🍕", "🍔", "🍟", "🌮", "🍩", "🍪", "🧁", "🍭", "🍬"]
    let letters = ["P", "I", "X", "S"]
    
    // Premium White/Silver Gradient Colors (Glass)
    let colors: [Color] = [
        Color.white.opacity(0.95),
        Color.white.opacity(0.8),
        Color.white.opacity(0.9),
        Color.white.opacity(0.85)
    ]
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Animated PIXS Logo (Funny & Premium)
            HStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { index in
                    Text(letters[index])
                        .font(.system(size: 20, weight: .black, design: .monospaced)) // Monospace kept for Logo style
                        .foregroundStyle(
                            LinearGradient(
                                colors: [colors[index], colors[index].opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: colors[index].opacity(0.4), radius: 5, y: 0)
                        .scaleEffect(x: 1.0, y: letterScales[index]) // Squash & Stretch
                        .offset(y: letterOffsets[index])
                        .rotationEffect(.degrees(letterRotations[index])) // Wobbly
                }
            }
            .onAppear {
                startFunnyAnimation()
            }
            .onDisappear {
                animationTimer?.invalidate()
            }
            
            Spacer()
            
            // Pixel Alien Buddy (Random Emoji Generator)
            PixelAlien(theme: theme)
            
            // Settings gear dropdown
            Menu {
                Button(action: {
                    // Show settings - handled via notification
                    NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
                }) {
                    Label("Settings", systemImage: "gear")
                }
                
                Divider()
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Label("Quit", systemImage: "power")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.secondaryText)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
    
    func startFunnyAnimation() {
        // "Professional Funny" - Smooth staggered wave
        // No timer needed, just pure SwiftUI animation
        for i in 0..<4 {
            // Random start delay for organic feel, or fixed stagger for wave
            let delay = Double(i) * 0.15
            
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
                .delay(delay)
            ) {
                letterOffsets[i] = -4
                letterRotations[i] = i % 2 == 0 ? 3 : -3
            }
            
            // Subtle breathing scale
            withAnimation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true)
                .delay(delay + 0.5)
            ) {
                letterScales[i] = 1.05
            }
        }
    }
}

// MARK: - Premium Tab Bar View (Floating Icons)
struct TabBarView: View {
    @Binding var selectedTab: Int
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: Spacing.xl) {
            FloatingTabIcon(icon: "doc.text", isSelected: selectedTab == 0, theme: theme) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 0
                }
            }
            
            FloatingTabIcon(icon: "bell", isSelected: selectedTab == 1, theme: theme) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 1
                }
            }
            
            FloatingTabIcon(icon: "sparkles", isSelected: selectedTab == 2, theme: theme) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = 2
                }
            }
        }
        .padding(.vertical, 6)
    }
}

struct FloatingTabIcon: View {
    let icon: String
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Glow background when selected
                if isSelected {
                    Circle()
                        .fill(theme.accent.opacity(0.15))
                        .frame(width: 36, height: 36)
                        .blur(radius: 4)
                }
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? theme.accent : theme.tertiaryText)
            }
            .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.1 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isHovered)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isSelected)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Footer View
struct FooterView: View {
    let theme: AppTheme
    @Binding var showingSettings: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation(Animations.smooth) {
                    showingSettings.toggle()
                }
            }) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: showingSettings ? "chevron.left" : "gear")
                        .font(.system(size: 11, weight: .medium))
                    Text(showingSettings ? "Back" : "Settings")
                        .font(Typography.caption(size: 11))
                }
                .foregroundColor(theme.secondaryText)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(
                    Capsule()
                        .fill(theme.cardBackground)
                )
            }
            .buttonStyle(.plain)
            .hoverScale(1.03)
            
            Spacer()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit")
                    .font(Typography.caption(size: 11))
                    .foregroundColor(theme.secondaryText)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        Capsule()
                            .fill(theme.cardBackground)
                    )
            }
            .buttonStyle(.plain)
            .hoverScale(1.03)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(theme.elevated)
    }
}

// MARK: - Inline Settings View
struct InlineSettingsView: View {
    let theme: AppTheme
    @Binding var showingSettings: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var aiService = AIService.shared
    @State private var apiKeyInput: String = ""
    @State private var showingApiKey = false
    @State private var saveStatus: String = ""
    @State private var appearAnimation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Back button
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        showingSettings = false
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(theme.accent)
                }
                .buttonStyle(.plain)
                .hoverScale(1.05)
                
                Spacer()
                
                Text("Settings")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.primaryText)
                
                Spacer()
                
                // Invisible spacer for centering
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 13, weight: .medium))
                }
                .opacity(0)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            
            Divider().opacity(0.2)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                // AI Section
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    SectionHeader(title: "AI Integration", theme: theme)
                    
                    VStack(spacing: Spacing.sm) {
                        HStack {
                            Group {
                                if showingApiKey {
                                    TextField("Gemini API Key", text: $apiKeyInput)
                                } else {
                                    SecureField("Gemini API Key", text: $apiKeyInput)
                                }
                            }
                            .textFieldStyle(.plain)
                            .font(Typography.monospace(size: 12))
                            .foregroundColor(theme.primaryText)
                            
                            Button(action: { showingApiKey.toggle() }) {
                                Image(systemName: showingApiKey ? "eye.slash.fill" : "eye.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.secondaryText)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: Corners.sm, style: .continuous)
                                .fill(theme.isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.03))
                        )
                        
                        PremiumButton("Save API Key", icon: "checkmark", theme: theme) {
                            aiService.apiKey = apiKeyInput
                            withAnimation(Animations.quick) {
                                saveStatus = "✓ Saved!"
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(Animations.quick) {
                                    saveStatus = ""
                                }
                            }
                        }
                        
                        if !saveStatus.isEmpty {
                            Text(saveStatus)
                                .font(Typography.caption())
                                .foregroundColor(.green)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        Link(destination: URL(string: "https://aistudio.google.com/app/apikey")!) {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 10))
                                Text("Get free API key")
                                    .font(Typography.caption())
                            }
                            .foregroundColor(theme.accent)
                        }
                    }
                    .glassCard(theme, cornerRadius: Corners.md, padding: Spacing.md)
                }
                .offset(y: appearAnimation ? 0 : 30)
                .opacity(appearAnimation ? 1 : 0)
                
                // About Section
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    SectionHeader(title: "About", theme: theme)
                    
                    HStack {
                        Text("Version")
                            .font(Typography.body(size: 12))
                            .foregroundColor(theme.secondaryText)
                        Spacer()
                        Text("1.0.0")
                            .font(Typography.body(size: 12))
                            .foregroundColor(theme.primaryText)
                    }
                    .glassCard(theme, cornerRadius: Corners.md, padding: Spacing.md)
                }
                .offset(y: appearAnimation ? 0 : 40)
                .opacity(appearAnimation ? 1 : 0)
            }
            .padding(Spacing.lg)
            }
        }
        .onAppear {
            apiKeyInput = aiService.apiKey
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.05)) {
                appearAnimation = true
            }
        }
        .onDisappear {
            appearAnimation = false
        }
    }
}

// MARK: - Visual Effect View
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

#Preview {
    ContentView()
}
