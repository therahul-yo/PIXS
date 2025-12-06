import Foundation
import UserNotifications

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var notes: [Note] = []
    @Published var reminders: [Reminder] = []
    @Published var chatMessages: [ChatMessage] = []
    @Published var apiKey: String = ""
    
    private let notesKey = "pixelnotes_notes"
    private let remindersKey = "pixelnotes_reminders"
    private let chatKey = "pixelnotes_chat"
    private let apiKeyKey = "pixelnotes_apikey"
    
    init() {
        loadData()
    }
    
    // MARK: - Persistence
    
    func loadData() {
        if let notesData = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([Note].self, from: notesData) {
            notes = decoded
        }
        
        if let remindersData = UserDefaults.standard.data(forKey: remindersKey),
           let decoded = try? JSONDecoder().decode([Reminder].self, from: remindersData) {
            reminders = decoded
        }
        
        if let chatData = UserDefaults.standard.data(forKey: chatKey),
           let decoded = try? JSONDecoder().decode([ChatMessage].self, from: chatData) {
            chatMessages = decoded
        }
        
        apiKey = UserDefaults.standard.string(forKey: apiKeyKey) ?? ""
        
        // Onboarding: Add welcome note if empty
        if notes.isEmpty && !UserDefaults.standard.bool(forKey: "hasShownWelcome") {
            addWelcomeNote()
            UserDefaults.standard.set(true, forKey: "hasShownWelcome")
        }
    }
    
    private func addWelcomeNote() {
        let welcomeContent = """
        Welcome to PIXS! 👾
        
        A minimal space for your thoughts.
        Click the + button to add more notes.
        Click the emoji to change the vibe.
        
        Enjoy the pixels.
        """
        addNote(title: "Welcome to PIXS", content: welcomeContent, emoji: "👋")
    }
    
    func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: remindersKey)
        }
    }
    
    func saveChatMessages() {
        if let encoded = try? JSONEncoder().encode(chatMessages) {
            UserDefaults.standard.set(encoded, forKey: chatKey)
        }
    }
    
    func saveApiKey() {
        UserDefaults.standard.set(apiKey, forKey: apiKeyKey)
    }
    
    // MARK: - Notes CRUD
    
    func addNote(title: String, content: String, emoji: String? = nil) {
        let note = Note(title: title, content: content, emoji: emoji)
        notes.insert(note, at: 0)
        saveNotes()
    }
    
    func updateNote(_ note: Note, title: String, content: String, emoji: String? = nil) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].title = title
            notes[index].content = content
            if let emoji = emoji {
                notes[index].emoji = emoji
            }
            notes[index].updatedAt = Date()
            saveNotes()
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    // MARK: - Reminders CRUD
    
    func addReminder(title: String, date: Date, hasDate: Bool = true, hasTime: Bool = true, repeatInterval: RepeatInterval = .never, earlyReminder: EarlyReminderChoice = .none, noteId: UUID? = nil) {
        let reminder = Reminder(title: title, date: date, noteId: noteId, hasDate: hasDate, hasTime: hasTime, repeatInterval: repeatInterval, earlyReminder: earlyReminder)
        reminders.insert(reminder, at: 0)
        saveReminders()
        scheduleNotification(for: reminder)
    }
    
    func updateReminder(_ reminder: Reminder, title: String, date: Date, hasDate: Bool, hasTime: Bool, repeatInterval: RepeatInterval, earlyReminder: EarlyReminderChoice) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].title = title
            reminders[index].date = date
            reminders[index].hasDate = hasDate
            reminders[index].hasTime = hasTime
            reminders[index].repeatInterval = repeatInterval
            reminders[index].earlyReminder = earlyReminder
            
            saveReminders()
            scheduleNotification(for: reminders[index])
        }
    }
    
    func toggleReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isComplete.toggle()
            saveReminders()
            
            // Cancel or reschedule based on completion
            if reminders[index].isComplete {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString, reminder.id.uuidString + "-early"])
            } else {
                scheduleNotification(for: reminders[index])
            }
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveReminders()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString, reminder.id.uuidString + "-early"])
    }
    
    // MARK: - Notifications
    

        
    func scheduleNotification(for reminder: Reminder) {
        let center = UNUserNotificationCenter.current()
        // clean up old ones
        center.removePendingNotificationRequests(withIdentifiers: [reminder.id.uuidString, reminder.id.uuidString + "-early"])
        
        guard !reminder.isComplete else { return }
        
        // Logic: If no date, no notification
        if !reminder.hasDate { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Px Reminder"
        content.body = reminder.title
        content.sound = .default
        
        // Base components
        var triggerComponents = DateComponents()
        var repeats = false
        
        // Handle "No Time" (All Day) - Default to 9 AM
        var baseDate = reminder.date
        if !reminder.hasTime {
            baseDate = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: reminder.date) ?? reminder.date
        }
        
        // 1. Scheduler Helper
        func getComponents(from date: Date, interval: RepeatInterval) -> DateComponents {
            let cal = Calendar.current
            switch interval {
            case .never:
                if reminder.hasTime {
                    return cal.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                } else {
                    return cal.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                }
            case .daily:
                return cal.dateComponents([.hour, .minute], from: date)
            case .weekly:
                return cal.dateComponents([.weekday, .hour, .minute], from: date)
            case .monthly:
                return cal.dateComponents([.day, .hour, .minute], from: date)
            }
        }
        
        repeats = reminder.repeatInterval != .never
        
        // Main Trigger
        triggerComponents = getComponents(from: baseDate, interval: reminder.repeatInterval)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
        
                // Only add if future or repeating
        if repeats || baseDate > Date() {
            center.add(request) { error in
                if let error = error { print("Error scheduling main: \(error)") }
            }
        }
        
        // 2. Early Notification
        if reminder.earlyReminder != .none {
            let earlyDate = baseDate.addingTimeInterval(-reminder.earlyReminder.timeInterval)
            
            let earlyContent = UNMutableNotificationContent()
            earlyContent.title = "Upcoming: \(reminder.title)"
            earlyContent.body = "In \(reminder.earlyReminder.rawValue)"
            earlyContent.sound = .default
            
            let earlyComponents = getComponents(from: earlyDate, interval: reminder.repeatInterval)
            let earlyTrigger = UNCalendarNotificationTrigger(dateMatching: earlyComponents, repeats: repeats)
            let earlyRequest = UNNotificationRequest(identifier: reminder.id.uuidString + "-early", content: earlyContent, trigger: earlyTrigger)
            
            if repeats || earlyDate > Date() {
                center.add(earlyRequest) { error in
                    if let error = error { print("Error scheduling early: \(error)") }
                }
            }
        }
    }
    
    // MARK: - Chat
    
    func addChatMessage(content: String, isUser: Bool) {
        let message = ChatMessage(content: content, isUser: isUser)
        chatMessages.append(message)
        saveChatMessages()
    }
    
    func clearChat() {
        chatMessages.removeAll()
        saveChatMessages()
    }
    
    // MARK: - AI Context
    
    func getNotesContext() -> String {
        var context = "Here are the user's notes:\n\n"
        for note in notes {
            context += "Title: \(note.title)\n"
            context += "Content: \(note.content)\n"
            context += "Last updated: \(note.updatedAt.formatted())\n\n"
        }
        
        context += "\nHere are the user's reminders:\n\n"
        for reminder in reminders {
            context += "- \(reminder.title) (Due: \(reminder.date.formatted())) \(reminder.isComplete ? "[Complete]" : "[Pending]")\n"
        }
        
        return context
    }
}
