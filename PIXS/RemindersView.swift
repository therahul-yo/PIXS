import SwiftUI

struct RemindersView: View {
    @StateObject private var dataManager = DataManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingNewReminder = false
    @State private var editingReminder: Reminder?
    @State private var appearAnimation = false
    
    var theme: AppTheme { AppTheme() }
    
    var pendingReminders: [Reminder] {
        dataManager.reminders.filter { !$0.isComplete }
    }
    
    var completedReminders: [Reminder] {
        dataManager.reminders.filter { $0.isComplete }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if dataManager.reminders.isEmpty {
                EmptyStateView(
                    icon: "bell",
                    title: "No reminders",
                    subtitle: "Never forget important tasks and events",
                    actionTitle: "Add Reminder",
                    theme: theme
                ) {
                    showingNewReminder = true
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.md) {
                        // Pending Section
                        if !pendingReminders.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                HStack {
                                    Text("UPCOMING")
                                        .font(Typography.caption(size: 11))
                                        .foregroundColor(theme.accent)
                                        .tracking(1)
                                    
                                    Text("\(pendingReminders.count)")
                                        .font(Typography.caption(size: 10))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(theme.accent))
                                }
                                .padding(.horizontal, Spacing.xs)
                                
                                ForEach(Array(pendingReminders.enumerated()), id: \.element.id) { index, reminder in
                                    ReminderCard(reminder: reminder, theme: theme) {
                                        editingReminder = reminder
                                    }
                                        .offset(y: appearAnimation ? 0 : CGFloat(20 + index * 5))
                                        .opacity(appearAnimation ? 1 : 0)
                                        .animation(Animations.smooth.delay(Double(index) * 0.05), value: appearAnimation)
                                }
                            }
                        }
                        
                        // Completed Section
                        if !completedReminders.isEmpty {
                            VStack(alignment: .leading, spacing: Spacing.sm) {
                                HStack {
                                    Text("COMPLETED")
                                        .font(Typography.caption(size: 11))
                                        .foregroundColor(theme.tertiaryText)
                                        .tracking(1)
                                    
                                    Text("\(completedReminders.count)")
                                        .font(Typography.caption(size: 10))
                                        .foregroundColor(theme.tertiaryText)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(theme.cardBackground))
                                }
                                .padding(.horizontal, Spacing.xs)
                                
                                ForEach(completedReminders) { reminder in
                                    ReminderCard(reminder: reminder, theme: theme) {
                                        editingReminder = reminder
                                    }
                                        .opacity(0.6)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
                
                // Add button
                HStack {
                    Spacer()
                    PremiumButton("New Reminder", icon: "plus", theme: theme) {
                        withAnimation(Animations.bouncy) {
                            showingNewReminder = true
                        }
                    }
                    Spacer()
                }
                .padding(.bottom, 10) // Lowered further as requested
            }
        }
        .onAppear {
            withAnimation(Animations.smooth.delay(0.1)) {
                appearAnimation = true
            }
        }
        .sheet(isPresented: $showingNewReminder) {
            ReminderEditorView(theme: theme)
        }
        .sheet(item: $editingReminder) { reminder in
            ReminderEditorView(reminder: reminder, theme: theme)
        }
    }
}

// MARK: - Premium Reminder Card
struct ReminderCard: View {
    let reminder: Reminder
    let theme: AppTheme
    let onEdit: () -> Void
    
    @StateObject private var dataManager = DataManager.shared
    @State private var isHovered = false
    @State private var isCompleting = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Status Indicator Strip
            Capsule()
                .fill(statusColor)
                .frame(width: 4, height: 24)
                .shadow(color: statusColor.opacity(0.5), radius: 2)
            
            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(reminder.title)
                    .font(Typography.subtitle(size: 13))
                    .foregroundColor(reminder.isComplete ? theme.secondaryText : theme.primaryText)
                    .strikethrough(reminder.isComplete, color: theme.secondaryText)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Label(formatDate(reminder.date), systemImage: "calendar")
                    Label(formatTime(reminder.date), systemImage: "clock")
                }
                .font(Typography.caption(size: 11))
                .foregroundColor(isPastDue ? .red.opacity(0.8) : theme.tertiaryText)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: Spacing.sm) {
                if isHovered {
                    // Delete Button (Only on Hover)
                    Button(action: deleteReminder) {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.red.opacity(0.8))
                            .frame(width: 28, height: 28)
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .scale))
                }
                
                // Premium Complete Button
                Button(action: toggleComplete) {
                    ZStack {
                        // Background
                        Circle()
                            .fill(reminder.isComplete ? Color.green : theme.cardBackground)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(reminder.isComplete ? Color.green : (isHovered ? theme.accent : theme.border), lineWidth: 1.5)
                            )
                        
                        // Icon
                        if reminder.isComplete {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .heavy))
                                .foregroundColor(.white)
                        }
                    }
                    .shadow(color: reminder.isComplete ? Color.green.opacity(0.4) : Color.clear, radius: 4)
                    .scaleEffect(isCompleting ? 1.2 : 1.0)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: Corners.md, style: .continuous)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: Corners.md, style: .continuous)
                        .stroke(isHovered ? theme.accent.opacity(0.3) : theme.border, lineWidth: isHovered ? 1 : 0.5)
                )
                .shadow(color: isHovered ? theme.accent.opacity(0.1) : Color.black.opacity(0.05), radius: isHovered ? 8 : 2, y: 2)
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { isHovered = $0 }
        .contentShape(Rectangle())
        .onTapGesture { onEdit() }
    }
    
    var statusColor: Color {
        if reminder.isComplete { return .green }
        if isPastDue { return .red }
        return theme.accent
    }
    
    func toggleComplete() {
        withAnimation(.bouncy(duration: 0.3)) {
            isCompleting = true
        }
        Haptics.play(.alignment)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.bouncy(duration: 0.3)) {
                isCompleting = false
                dataManager.toggleReminder(reminder)
            }
        }
    }
    
    func deleteReminder() {
        withAnimation(Animations.smooth) {
            dataManager.deleteReminder(reminder)
            Haptics.play(.generic)
        }
    }
    
    var isPastDue: Bool {
        !reminder.isComplete && reminder.date < Date()
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Premium Reminder Editor
struct ReminderEditorView: View {
    var reminder: Reminder? = nil
    let theme: AppTheme
    
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedHour: Int = 12
    @State private var selectedMinute: Int = 0
    @State private var isAM: Bool = true
    
    // Reminders 2.0 State
    @State private var hasDate: Bool = true
    @State private var hasTime: Bool = true
    @State private var repeatInterval: RepeatInterval = .never
    @State private var earlyReminder: EarlyReminderChoice = .none
    
    @State private var currentMonth: Date = Date()
    @State private var appearAnimation = false
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.secondaryText)
                }
                .buttonStyle(.plain)
                .hoverScale(1.1)
                
                Spacer()
                
                Spacer()
                
                Text(reminder == nil ? "New Reminder" : "Edit Reminder")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.primaryText)
                
                Spacer()
                
                Spacer()
                
                Button(action: saveReminder) {
                    Text("Save")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(title.isEmpty ? theme.tertiaryText : .black)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .background(
                            Group {
                                if title.isEmpty {
                                    Capsule().fill(theme.cardBackground)
                                } else {
                                    Capsule().fill(theme.accentGradient)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
                .disabled(title.isEmpty)
                .hoverScale(1.05)
            }
            .padding(Spacing.lg)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    // Title Input
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        TextField("Title", text: $title)
                            .textFieldStyle(.plain)
                            .font(Typography.title(size: 15))
                            .foregroundColor(theme.primaryText)
                            .glassCard(theme, cornerRadius: Corners.md, padding: Spacing.md)
                    }
                    .offset(y: appearAnimation ? 0 : 20)
                    .opacity(appearAnimation ? 1 : 0)
                    
                    // Date & Time Section
                    VStack(spacing: 0) {
                        // Date Row
                        ToggleRow(icon: "calendar", title: "Date", isOn: $hasDate, theme: theme) {
                            Text(formatDate(selectedDate))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theme.accent)
                        }
                        
                        if hasDate {
                            Divider().padding(.leading, 36).opacity(0.1)
                            
                            // Calendar (Collapsible)
                            VStack(spacing: 0) {
                                // Month Navigation
                                HStack {
                                    Button(action: previousMonth) {
                                        Image(systemName: "chevron.left").font(.system(size: 12, weight: .semibold))
                                    }
                                    .buttonStyle(.plain)
                                    Spacer()
                                    Text(monthYearString).font(.system(size: 13, weight: .semibold))
                                    Spacer()
                                    Button(action: nextMonth) {
                                        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, Spacing.md)
                                .padding(.top, Spacing.sm)
                                .foregroundColor(theme.primaryText)
                                
                                // Days
                                HStack(spacing: 0) {
                                    ForEach(daysOfWeek, id: \.self) { day in
                                        Text(day)
                                            .font(.system(size: 9, weight: .semibold))
                                            .foregroundColor(theme.tertiaryText)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.top, 8)
                                
                                // Grid
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 2) {
                                    ForEach(daysInMonth, id: \.self) { date in
                                        if let date = date {
                                            DayCell(
                                                date: date,
                                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                                isToday: calendar.isDateInToday(date),
                                                theme: theme
                                            ) {
                                                withAnimation(Animations.bouncy) { selectedDate = date }
                                            }
                                        } else {
                                            Color.clear.frame(height: 30)
                                        }
                                    }
                                }
                                .padding(Spacing.sm)
                            }
                        }
                        
                        Divider().padding(.leading, 36).opacity(0.1)
                        
                        // Time Row
                        ToggleRow(icon: "clock", title: "Time", isOn: $hasTime, theme: theme) {
                            Text(formatTime())
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(theme.accent)
                        }
                        
                        if hasTime && hasDate { // Time needs date to be relevant usually
                            Divider().padding(.leading, 36).opacity(0.1)
                            
                            HStack(spacing: Spacing.md) {
                                Spacer()
                                TimePickerWheel(value: $selectedHour, range: 1...12, theme: theme)
                                Text(":").foregroundColor(theme.tertiaryText)
                                TimePickerWheel(value: $selectedMinute, range: 0...59, theme: theme, padZero: true)
                                VStack(spacing: 2) {
                                    TimeToggleButton(text: "AM", isSelected: isAM, theme: theme) { withAnimation { isAM = true } }
                                    TimeToggleButton(text: "PM", isSelected: !isAM, theme: theme) { withAnimation { isAM = false } }
                                }
                                Spacer()
                            }
                            .padding(Spacing.md)
                        }
                    }
                    .background(
                         RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(theme.cardBackground)
                    )
                    .offset(y: appearAnimation ? 0 : 30)
                    .opacity(appearAnimation ? 1 : 0)
                    
                    // Options Section
                    VStack(spacing: 0) {
                        SettingsRow(icon: "repeat", title: "Repeat", theme: theme) {
                            Picker("", selection: $repeatInterval) {
                                ForEach(RepeatInterval.allCases, id: \.self) { interval in
                                    Text(interval.rawValue).tag(interval)
                                }
                            }
                            .labelsHidden()
                            .accentColor(theme.secondaryText)
                            .frame(width: 100)
                        }
                        
                        Divider().padding(.leading, 36).opacity(0.1)
                        
                        SettingsRow(icon: "bell.badge", title: "Early Reminder", theme: theme) {
                            Picker("", selection: $earlyReminder) {
                                ForEach(EarlyReminderChoice.allCases, id: \.self) { choice in
                                    Text(choice.rawValue).tag(choice)
                                }
                            }
                            .labelsHidden()
                            .accentColor(theme.secondaryText)
                            .frame(width: 120)
                        }
                    }
                    .background(
                         RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(theme.cardBackground)
                    )
                    .offset(y: appearAnimation ? 0 : 40)
                    .opacity(appearAnimation ? 1 : 0)
                }
                .padding(Spacing.lg)
            }
        }
        .frame(width: 340, height: 550)
        .background(theme.background)
        .onAppear {
            if let reminder = reminder {
                // Populate fields
                title = reminder.title
                selectedDate = reminder.date
                hasDate = reminder.hasDate
                hasTime = reminder.hasTime
                repeatInterval = reminder.repeatInterval
                earlyReminder = reminder.earlyReminder
                
                let components = calendar.dateComponents([.hour, .minute], from: reminder.date)
                let hour = components.hour ?? 12
                selectedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
                selectedMinute = components.minute ?? 0
                isAM = hour < 12
            } else {
                // Default init
                let components = calendar.dateComponents([.hour, .minute], from: Date().addingTimeInterval(3600))
                let hour = components.hour ?? 12
                selectedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
                selectedMinute = components.minute ?? 0
                isAM = hour < 12
            }
            
            withAnimation(Animations.smooth.delay(0.05)) {
                appearAnimation = true
            }
        }
    }
    
    // Helpers
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var daysInMonth: [Date?] {
        var days: [Date?] = []
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        
        for _ in 1..<firstWeekday { days.append(nil) }
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }
        return days
    }
    
    func previousMonth() { withAnimation { currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth } }
    func nextMonth() { withAnimation { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth } }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    func formatTime() -> String {
        return "\(selectedHour):\(String(format: "%02d", selectedMinute)) \(isAM ? "AM" : "PM")"
    }
    
    func saveReminder() {
        var hour = selectedHour
        if !isAM && hour != 12 { hour += 12 }
        else if isAM && hour == 12 { hour = 0 }
        
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = hour
        components.minute = selectedMinute
        
        if let finalDate = calendar.date(from: components) {
            if let existing = reminder {
                dataManager.updateReminder(
                    existing,
                    title: title,
                    date: finalDate,
                    hasDate: hasDate,
                    hasTime: hasTime,
                    repeatInterval: repeatInterval,
                    earlyReminder: earlyReminder
                )
            } else {
                dataManager.addReminder(
                    title: title, 
                    date: finalDate, 
                    hasDate: hasDate, 
                    hasTime: hasTime, 
                    repeatInterval: repeatInterval, 
                    earlyReminder: earlyReminder
                )
            }
        }
        dismiss()
    }
}

// MARK: - Reminder Settings Components

struct ToggleRow<Content: View>: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let theme: AppTheme
    let subtitle: () -> Content
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(isOn ? theme.accent : theme.tertiaryText)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(theme.primaryText)
                
                if isOn {
                    subtitle()
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: theme.accent))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let theme: AppTheme
    let content: () -> Content
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(theme.secondaryText)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(theme.primaryText)
            
            Spacer()
            
            content()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let theme: AppTheme
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular, design: .rounded))
                .foregroundColor(foregroundColor)
                .frame(width: 34, height: 34)
                .background(
                    ZStack {
                        if isSelected {
                            Circle().fill(theme.accentGradient)
                        } else if isToday {
                            Circle().stroke(theme.accent, lineWidth: 1.5)
                        } else if isHovered {
                            Circle().fill(theme.accent.opacity(0.1))
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered && !isSelected ? 1.1 : 1.0)
        .animation(Animations.quick, value: isHovered)
        .onHover { isHovered = $0 }
    }
    
    var foregroundColor: Color {
        if isSelected { return .white }
        if isPastDate { return theme.tertiaryText }
        return theme.primaryText
    }
    
    var isPastDate: Bool {
        date < Calendar.current.startOfDay(for: Date())
    }
}

// MARK: - Time Picker Wheel
struct TimePickerWheel: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let theme: AppTheme
    var padZero: Bool = false
    
    var body: some View {
        VStack(spacing: Spacing.xxs) {
            Button(action: increment) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(theme.accent)
            }
            .buttonStyle(.plain)
            .hoverScale(1.2)
            
            TextField("", text: Binding(
                get: { padZero ? String(format: "%02d", value) : "\(value)" },
                set: { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if let intVal = Int(filtered) {
                        // Allow typing, clamp only if valid length or out of bounds logic?
                        // For simplicity, update if within range.
                        if range.contains(intVal) {
                            value = intVal
                        }
                    }
                }
            ))
            .textFieldStyle(.plain)
            .multilineTextAlignment(.center)
            .font(.system(size: 26, weight: .medium, design: .rounded))
            .foregroundColor(theme.primaryText)
            .frame(width: 44)
            .background(Color.black.opacity(0.01)) // Hit target
            
            Button(action: decrement) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(theme.accent)
            }
            .buttonStyle(.plain)
            .hoverScale(1.2)
        }
    }
    
    func increment() {
        withAnimation(Animations.quick) {
            value = value >= range.upperBound ? range.lowerBound : value + 1
        }
    }
    
    func decrement() {
        withAnimation(Animations.quick) {
            value = value <= range.lowerBound ? range.upperBound : value - 1
        }
    }
}

// MARK: - Time Toggle Button
struct TimeToggleButton: View {
    let text: String
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : theme.secondaryText)
                .frame(width: 36, height: 26)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: Corners.xs, style: .continuous)
                                .fill(theme.accentGradient)
                        } else {
                            RoundedRectangle(cornerRadius: Corners.xs, style: .continuous)
                                .fill(theme.cardBackground)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .hoverScale(1.05)
    }
}

#Preview {
    RemindersView()
        .environmentObject(ThemeManager.shared)
        .frame(width: 320, height: 350)
}
