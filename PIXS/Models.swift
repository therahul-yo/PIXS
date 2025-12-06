import Foundation

// MARK: - Note Model
struct Note: Identifiable, Codable {
    let id: UUID
    var title: String  // Keep for backwards compat, but content-first line is used
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var emoji: String
    
    // Computed: First line of content as display title (Apple Notes style)
    var displayTitle: String {
        let firstLine = content.components(separatedBy: .newlines).first ?? ""
        let trimmed = firstLine.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "New Note" : String(trimmed.prefix(50))
    }
    
    // Computed: Content after first line
    var bodyContent: String {
        let lines = content.components(separatedBy: .newlines)
        if lines.count > 1 {
            return lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }
    
    // Default emojis pool
    static let emojis = ["📝", "📓", "📒", "📔", "📕", "📗", "📘", "📙", "📚", "📜", "📄", "📁", "📂", "🗂️", "📌", "📍", "📎", "🖊️", "🖋️", "✒️", "🧠", "💡", "✨", "🎯", "🎨", "👾", "🚀", "⭐️", "🔥", "💎"]
    
    init(id: UUID = UUID(), title: String = "", content: String, emoji: String? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.emoji = emoji ?? Note.emojis.randomElement() ?? "📝"
    }
    
    // Custom decoding to handle legacy notes without emoji
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // If emoji is missing (legacy data), assign a deterministic one based on ID hash
        if let emojiVal = try? container.decode(String.self, forKey: .emoji) {
            emoji = emojiVal
        } else {
            // Deterministic random for consistent UI on old notes
            let hash = abs(id.hashValue)
            emoji = Note.emojis[hash % Note.emojis.count]
        }
    }
}

// MARK: - Reminder Enums
enum RepeatInterval: String, Codable, CaseIterable {
    case never = "Never"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

enum EarlyReminderChoice: String, Codable, CaseIterable {
    case none = "None"
    case fiveMinutes = "5 min before"
    case fifteenMinutes = "15 min before"
    case thirtyMinutes = "30 min before"
    case oneHour = "1 hour before"
    
    var timeInterval: TimeInterval {
        switch self {
        case .none: return 0
        case .fiveMinutes: return 300
        case .fifteenMinutes: return 900
        case .thirtyMinutes: return 1800
        case .oneHour: return 3600
        }
    }
}

// MARK: - Reminder Model
struct Reminder: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var isComplete: Bool
    var noteId: UUID?
    
    // Reminders 2.0
    var hasDate: Bool
    var hasTime: Bool
    var repeatInterval: RepeatInterval
    var earlyReminder: EarlyReminderChoice
    
    init(id: UUID = UUID(), title: String, date: Date, noteId: UUID? = nil, 
         hasDate: Bool = true, hasTime: Bool = true, 
         repeatInterval: RepeatInterval = .never, earlyReminder: EarlyReminderChoice = .none) {
        self.id = id
        self.title = title
        self.date = date
        self.isComplete = false
        self.noteId = noteId
        self.hasDate = hasDate
        self.hasTime = hasTime
        self.repeatInterval = repeatInterval
        self.earlyReminder = earlyReminder
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    var content: String
    var isUser: Bool
    var timestamp: Date
    
    init(id: UUID = UUID(), content: String, isUser: Bool) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}
