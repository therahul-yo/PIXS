import SwiftUI

// MARK: - Premium Design System
// Inspired by Raycast, Bear, Notion, Craft

// =============================================================================
// DESIGN TOKENS
// =============================================================================

/// 8-Point Grid Spacing System
struct Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

/// Corner Radius System
struct Corners {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let full: CGFloat = 100
}

/// Shadow Presets
struct Shadows {
    static let subtle = ShadowStyle(color: .black.opacity(0.15), radius: 4, y: 2)
    static let medium = ShadowStyle(color: .black.opacity(0.25), radius: 8, y: 4)
    static let elevated = ShadowStyle(color: .black.opacity(0.35), radius: 16, y: 8)
    static let glow = ShadowStyle(color: Color("AccentPurple").opacity(0.3), radius: 12, y: 0)
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let y: CGFloat
}

// =============================================================================
// PREMIUM ANIMATION SYSTEM
// =============================================================================

/// Animation Presets (0.15-0.28s range for premium feel)
struct Animations {
    // Quick interactions
    static let micro = Animation.spring(response: 0.15, dampingFraction: 0.8)
    static let quick = Animation.spring(response: 0.2, dampingFraction: 0.75)
    
    // Standard transitions
    static let smooth = Animation.spring(response: 0.25, dampingFraction: 0.8)
    static let bouncy = Animation.spring(response: 0.28, dampingFraction: 0.6)
    
    // Entrance animations
    static let entrance = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let stagger = Animation.spring(response: 0.4, dampingFraction: 0.75)
    
    // Special effects
    static let elastic = Animation.spring(response: 0.5, dampingFraction: 0.5)
    static let gentle = Animation.easeOut(duration: 0.2)
}

// =============================================================================
// TYPOGRAPHY SYSTEM
// =============================================================================

/// Premium Typography using SF Pro
struct Typography {
    // Headers (SF Pro Rounded)
    static func largeTitle(size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func title(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    static func headline(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    
    // Body (SF Pro Default)
    static func body(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    static func callout(size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    static func subtitle(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
    
    static func caption(size: CGFloat = 11) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    static func tiny(size: CGFloat = 10) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    // Monospace (for code/data)
    static func mono(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    // Legacy alias
    static func monospace(size: CGFloat = 12) -> Font {
        mono(size: size)
    }
}

// =============================================================================
// COLOR SYSTEM
// =============================================================================

/// Glass Liquid Dark Theme - Frosted glass with white text
struct AppTheme {
    let isDark: Bool = true
    
    // MARK: - Glass Backgrounds (Frosted Black)
    var background: Color { Color.black }
    var backgroundSecondary: Color { Color.white.opacity(0.03) }
    var cardBackground: Color { Color.white.opacity(0.06) }
    var cardHover: Color { Color.white.opacity(0.10) }
    var elevated: Color { Color.white.opacity(0.08) }
    
    // MARK: - Glass Borders (Subtle white edges)
    var divider: Color { Color.white.opacity(0.08) }
    var border: Color { Color.white.opacity(0.12) }
    var borderSubtle: Color { Color.white.opacity(0.06) }
    
    // MARK: - Text (Pure white palette)
    var primaryText: Color { Color.white }
    var secondaryText: Color { Color.white.opacity(0.7) }
    var tertiaryText: Color { Color.white.opacity(0.5) }
    var mutedText: Color { Color.white.opacity(0.35) }
    
    // MARK: - Accent (Cool white/silver glow)
    var accent: Color { Color.white }
    var accentLight: Color { Color.white.opacity(0.9) }
    var accentGlow: Color { Color.white.opacity(0.2) }
    var accentSubtle: Color { Color.white.opacity(0.1) }
    
    // MARK: - Glass Gradients
    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.95),
                Color.white.opacity(0.75)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var subtleGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.08), Color.clear],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Glass blur gradient for liquid effect
    var glassGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.15),
                Color.white.opacity(0.05),
                Color.white.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Semantic Colors
    var success: Color { Color(hex: "4ADE80") }
    var warning: Color { Color(hex: "FBBF24") }
    var error: Color { Color(hex: "F87171") }
    var info: Color { Color(hex: "60A5FA") }
    
    // MARK: - Separator
    var separator: Color { divider }
}

// =============================================================================
// PREMIUM VIEW MODIFIERS
// =============================================================================

/// Premium Card with elevation, border, and hover lift
struct PremiumCard: ViewModifier {
    let theme: AppTheme
    let cornerRadius: CGFloat
    let isHovered: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isHovered ? theme.cardHover : theme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(isHovered ? theme.border : theme.borderSubtle, lineWidth: 1)
            )
            .shadow(
                color: isHovered ? Color.black.opacity(0.3) : Color.black.opacity(0.15),
                radius: isHovered ? 12 : 6,
                y: isHovered ? 6 : 3
            )
            .scaleEffect(isHovered ? 1.01 : 1.0)
    }
}

/// Hover Scale with smooth animation
struct HoverScale: ViewModifier {
    @State private var isHovered = false
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? scale : 1.0)
            .animation(Animations.quick, value: isHovered)
            .onHover { isHovered = $0 }
    }
}

/// Press Effect with scale and opacity
struct PressEffect: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(Animations.micro, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

/// Staggered Entrance Animation
struct StaggerEntrance: ViewModifier {
    let index: Int
    let appearAnimation: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 12)
            .animation(
                Animations.entrance.delay(Double(index) * 0.05),
                value: appearAnimation
            )
    }
}

/// Glow Border Effect
struct GlowBorder: ViewModifier {
    let theme: AppTheme
    let cornerRadius: CGFloat
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(theme.accent.opacity(isActive ? 0.6 : 0), lineWidth: 1.5)
            )
            .shadow(
                color: theme.accentGlow,
                radius: isActive ? 8 : 0
            )
    }
}

/// Pulse Animation for icons
struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

/// Material Blur Background
struct MaterialBackground: ViewModifier {
    let theme: AppTheme
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.8)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(theme.cardBackground.opacity(0.5))
            )
    }
}

// =============================================================================
// VIEW EXTENSIONS
// =============================================================================

extension View {
    func premiumCard(_ theme: AppTheme, cornerRadius: CGFloat = Corners.md, isHovered: Bool = false) -> some View {
        modifier(PremiumCard(theme: theme, cornerRadius: cornerRadius, isHovered: isHovered))
    }
    
    func hoverScale(_ scale: CGFloat = 1.02) -> some View {
        modifier(HoverScale(scale: scale))
    }
    
    func pressEffect() -> some View {
        modifier(PressEffect())
    }
    
    func staggerEntrance(index: Int, appear: Bool) -> some View {
        modifier(StaggerEntrance(index: index, appearAnimation: appear))
    }
    
    func glowBorder(_ theme: AppTheme, cornerRadius: CGFloat = Corners.md, isActive: Bool = false) -> some View {
        modifier(GlowBorder(theme: theme, cornerRadius: cornerRadius, isActive: isActive))
    }
    
    func pulseEffect() -> some View {
        modifier(PulseEffect())
    }
    
    func materialBackground(_ theme: AppTheme, cornerRadius: CGFloat = Corners.md) -> some View {
        modifier(MaterialBackground(theme: theme, cornerRadius: cornerRadius))
    }
    
    // Legacy support
    func glassCard(_ theme: AppTheme, cornerRadius: CGFloat = Corners.md, padding: CGFloat = Spacing.md) -> some View {
        self
            .padding(padding)
            .premiumCard(theme, cornerRadius: cornerRadius)
    }
    
    func elevatedShadow(_ theme: AppTheme, elevation: CGFloat = 8) -> some View {
        self.shadow(color: Color.black.opacity(0.25), radius: elevation, y: elevation / 2)
    }
    
    func shimmer(_ isDark: Bool) -> some View {
        modifier(ShimmerEffect(isDark: isDark))
    }
}

// =============================================================================
// REUSABLE COMPONENTS
// =============================================================================

/// Premium Button
struct PremiumButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    // Accept theme but default to new theme
    var theme: AppTheme = AppTheme()
    
    enum ButtonStyle {
        case primary, secondary, ghost
    }
    
    @State private var isHovered = false
    @State private var isPressed = false
    
    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, theme: AppTheme = AppTheme(), action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.theme = theme
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 6)
            .background(backgroundView)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : (isHovered ? 1.02 : 1.0))
        .animation(Animations.micro, value: isHovered)
        .animation(Animations.micro, value: isPressed)
        .onHover { isHovered = $0 }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    var foregroundColor: Color {
        switch style {
        case .primary: return Color.black.opacity(0.85)
        case .secondary: return theme.accent
        case .ghost: return theme.secondaryText
        }
    }
    
    @ViewBuilder
    var backgroundView: some View {
        switch style {
        case .primary:
            Capsule()
                .fill(theme.accentGradient)
                .overlay(
                    Group {
                        if isHovered {
                            Color.clear
                                .modifier(ShimmerEffect(isDark: theme.isDark))
                                .clipShape(Capsule())
                        }
                    }
                )
                .shadow(color: theme.accentGlow, radius: isHovered ? 10 : 4)
        case .secondary:
            Capsule()
                .fill(theme.accentSubtle)
                .overlay(Capsule().stroke(theme.accent.opacity(0.3), lineWidth: 1))
        case .ghost:
            Capsule()
                .fill(theme.cardBackground)
                .overlay(Capsule().stroke(theme.border, lineWidth: 1))
        }
    }
}

/// Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let theme: AppTheme
    let action: (() -> Void)?
    
    @State private var iconScale: CGFloat = 0.5
    @State private var contentOpacity: CGFloat = 0
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Animated Icon with glow
            ZStack {
                Circle()
                    .fill(theme.accentSubtle)
                    .frame(width: 72, height: 72)
                    .blur(radius: 8)
                
                Circle()
                    .fill(theme.cardBackground)
                    .frame(width: 64, height: 64)
                
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(theme.accent)
            }
            .scaleEffect(iconScale)
            
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(Typography.headline())
                    .foregroundColor(theme.primaryText)
                
                Text(subtitle)
                    .font(Typography.caption())
                    .foregroundColor(theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .opacity(contentOpacity)
            
            if let actionTitle = actionTitle, let action = action {
                PremiumButton(actionTitle, icon: "plus", theme: theme, action: action)
                    .opacity(contentOpacity)
            }
        }
        .padding(Spacing.xl)
        .onAppear {
            withAnimation(Animations.bouncy.delay(0.1)) {
                iconScale = 1.0
            }
            withAnimation(Animations.smooth.delay(0.2)) {
                contentOpacity = 1.0
            }
        }
    }
}

/// Typing Indicator
struct TypingIndicator: View {
    let theme: AppTheme
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(theme.accent.opacity(animationPhase == index ? 1.0 : 0.4))
                    .frame(width: 6, height: 6)
                    .scaleEffect(animationPhase == index ? 1.2 : 0.8)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            Capsule()
                .fill(theme.cardBackground)
                .overlay(Capsule().stroke(theme.border, lineWidth: 1))
        )
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                withAnimation(Animations.micro) {
                    animationPhase = (animationPhase + 1) % 3
                }
            }
        }
    }
}

/// Section Header
struct SectionHeader: View {
    let title: String
    let theme: AppTheme
    
    var body: some View {
        Text(title.uppercased())
            .font(Typography.tiny())
            .foregroundColor(theme.tertiaryText)
            .tracking(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.xs)
    }
}

/// Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    let isDark: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            isDark ? Color.white.opacity(0.08) : Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: -geo.size.width + phase * geo.size.width * 3)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// =============================================================================
// COLOR EXTENSION
// =============================================================================

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// =============================================================================
// LEGACY COMPONENTS (Keep for compatibility)
// =============================================================================

/// Animated Gradient Capsule with Fun Effects
struct AnimatedGradientCapsule: View {
    @State private var isPressed = false
    let theme = AppTheme()
    
    var body: some View {
        // Retro 3D Box Button (matches CSS example)
        ZStack(alignment: .top) {
            // Shadow/base layer (gray box at bottom)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color(hex: "666666"))
                .frame(height: 34)
                .offset(y: 6)
            
            // Main button surface
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color(hex: "EEEEEE"))
                .overlay(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .stroke(Color.white, lineWidth: 3)
                        .padding(2)
                )
                .frame(height: 28)
                .offset(y: isPressed ? 6 : 0) // Push down on press
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Color.black, lineWidth: 3)
        )
        .frame(height: 34)
    }
}

/// Retro Box Button (Main button component)
struct RetroBoxButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .top) {
                // Shadow/base layer (dark orange)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color(hex: "CC8800"))
                
                // Main button surface (yellow gradient)
                VStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "FFDD44"), Color(hex: "FFBB00")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .stroke(Color(hex: "FFE880"), lineWidth: 2)
                                .padding(1)
                        )
                        .frame(height: 24)
                        .offset(y: isPressed ? 6 : 0)
                    
                    Spacer(minLength: 0)
                }
                
                // Content
                HStack(spacing: 4) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 10, weight: .bold))
                    }
                    Text(title)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(0.3)
                }
                .foregroundColor(Color(hex: "442200"))
                .offset(y: isPressed ? 9 : 3)
            }
            .frame(height: 30)
            .padding(.horizontal, 12)
        }
        .buttonStyle(.plain)
        .fixedSize() // Don't expand to fill width
        .overlay(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Color.black, lineWidth: 2)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeOut(duration: 0.08), value: isPressed)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isHovered)
        .onHover { isHovered = $0 }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Haptics
struct Haptics {
    static func play(_ type: NSHapticFeedbackManager.FeedbackPattern = .alignment) {
        NSHapticFeedbackManager.defaultPerformer.perform(type, performanceTime: .default)
    }
}
