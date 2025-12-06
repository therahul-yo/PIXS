import SwiftUI

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "pixelnotes_darkmode")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "pixelnotes_darkmode")
    }
}

// MARK: - Theme Colors
struct Theme {
    static func background(dark: Bool) -> Color {
        dark ? Color.black : Color(nsColor: .windowBackgroundColor)
    }
    
    static func cardBackground(dark: Bool) -> Color {
        dark ? Color.white.opacity(0.08) : Color.primary.opacity(0.05)
    }
    
    static func secondaryText(dark: Bool) -> Color {
        dark ? Color.white.opacity(0.5) : Color.secondary
    }
    
    static func primaryText(dark: Bool) -> Color {
        dark ? Color.white : Color.primary
    }
    
    static func accent(dark: Bool) -> Color {
        dark ? Color.cyan : Color.accentColor
    }
}
