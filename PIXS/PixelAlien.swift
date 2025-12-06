import SwiftUI

// MARK: - Pixel Alien Buddy
/// The signature mascot for PixelNotes - appears in header, reacts to user actions

struct PixelAlien: View {
    let theme: AppTheme
    
    @State private var currentEmoji = ""
    @State private var isHovered = false
    @State private var spinRotation: Double = 0
    @State private var floatOffset: CGFloat = 0
    @State private var blinkOpacity: Double = 1.0
    @State private var sparkleVisible = false
    @State private var celebrationActive = false
    
    // Fun pixel-style emojis
    let emojis = ["👾", "🎮", "🕹️", "🚀", "⭐", "🌟", "💫", "✨", "💎", "🎯", "👻", "👽", "🤖", "🦊", "🐼", "🦄", "🐲", "🎨", "🔥", "💜", "🍀", "🌈", "🦋", "🎪", "🎭", "🎬", "🎵"]
    
    var body: some View {
        ZStack {
            // Glow aura (visible on hover or celebration)
            Circle()
                .fill(theme.accentGlow)
                .frame(width: 32, height: 32)
                .blur(radius: 8)
                .opacity(isHovered || celebrationActive ? 0.6 : 0)
                .scaleEffect(celebrationActive ? 1.3 : 1.0)
            
            // Pixel sparkles (on click)
            if sparkleVisible {
                ForEach(0..<4, id: \.self) { i in
                    PixelSparkle(
                        delay: Double(i) * 0.08,
                        angle: Double(i) * 90
                    )
                    .foregroundColor(theme.accent)
                }
            }
            
            // Random Emoji
            Text(currentEmoji)
                .font(.system(size: 18))
                .rotationEffect(.degrees(spinRotation))
                .offset(y: floatOffset)
                .scaleEffect(isHovered ? 1.15 : 1.0)
                .shadow(color: theme.accent.opacity(0.3), radius: isHovered ? 4 : 0)
        }
        .frame(width: 30, height: 30)
        .contentShape(Rectangle())
        .onTapGesture {
            triggerClick()
        }
        .onHover { hovering in
            withAnimation(Animations.quick) {
                isHovered = hovering
            }
            if hovering {
                triggerWiggle()
            }
        }
        .onAppear {
            // Random emoji on each startup
            currentEmoji = emojis.randomElement() ?? "👾"
            startIdleAnimation()
        }
    }
    
    // MARK: - Animations
    
    /// Idle floating (smooth, no blink)
    func startIdleAnimation() {
        // Gentle float - slower and subtle
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            floatOffset = -3
        }
    }
    
    /// Wiggle on hover
    func triggerWiggle() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
            spinRotation += 20
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                spinRotation -= 40
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                spinRotation = 0
            }
        }
    }
    
    /// Click: change emoji + sparkle
    func triggerClick() {
        // Spin + change emoji
        withAnimation(.easeInOut(duration: 0.3)) {
            spinRotation += 360
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentEmoji = emojis.randomElement() ?? "👾"
        }
        
        // Show sparkles
        withAnimation(Animations.quick) {
            sparkleVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(Animations.quick) {
                sparkleVisible = false
            }
        }
    }
    
    /// Celebration (for milestones)
    func celebrate() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
            celebrationActive = true
            floatOffset = -12
        }
        
        // Quick jumps
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                    floatOffset = i % 2 == 0 ? -16 : -8
                }
            }
        }
        
        // Return to idle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                celebrationActive = false
                floatOffset = 0
            }
            startIdleAnimation()
        }
    }
}

// MARK: - Pixel Sparkle Effect

struct PixelSparkle: View {
    let delay: Double
    let angle: Double
    
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var offset: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .frame(width: 4, height: 4)
            .rotationEffect(.degrees(45 + angle))
            .offset(x: offset * cos(angle * .pi / 180), y: offset * sin(angle * .pi / 180))
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4).delay(delay)) {
                    scale = 1.0
                    offset = 20
                }
                withAnimation(.easeIn(duration: 0.2).delay(delay + 0.3)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Minimal Confetti (for celebrations)

struct PixelConfetti: View {
    let theme: AppTheme
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Rectangle()
                    .fill(particle.color)
                    .frame(width: 4, height: 4)
                    .offset(x: particle.x, y: particle.y)
                    .rotationEffect(.degrees(particle.rotation))
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
    }
    
    func createParticles() {
        let colors = [theme.accent, theme.accentLight, Color.white, theme.success]
        for _ in 0..<12 {
            particles.append(ConfettiParticle(
                color: colors.randomElement()!,
                x: CGFloat.random(in: -20...20),
                y: 0,
                rotation: Double.random(in: 0...360),
                opacity: 1
            ))
        }
    }
    
    func animateParticles() {
        for i in particles.indices {
            withAnimation(.easeOut(duration: 0.6).delay(Double(i) * 0.03)) {
                particles[i].y = CGFloat.random(in: 30...80)
                particles[i].x += CGFloat.random(in: -40...40)
                particles[i].rotation += Double.random(in: 180...540)
            }
            withAnimation(.easeIn(duration: 0.2).delay(0.5 + Double(i) * 0.03)) {
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var color: Color
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var opacity: Double
}
