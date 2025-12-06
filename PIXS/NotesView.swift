import SwiftUI

struct NotesView: View {
    @StateObject private var dataManager = DataManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingNewNote = false
    @State private var editingNote: Note?
    @State private var appearAnimation = false
    
    // Delete Confirmation
    @State private var showingDeleteAlert = false
    @State private var noteToDelete: Note?
    
    var theme: AppTheme { AppTheme() }
    
    var body: some View {
        VStack(spacing: 0) {
            if dataManager.notes.isEmpty {
                EmptyStateView(
                    icon: "note.text",
                    title: "No notes yet",
                    subtitle: "Capture your thoughts, ideas, and reminders",
                    actionTitle: "Create Note",
                    theme: theme
                ) {
                    showingNewNote = true
                }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(Array(dataManager.notes.enumerated()), id: \.element.id) { index, note in
                            NoteCard(note: note, theme: theme) {
                                editingNote = note
                            } onDelete: {
                                noteToDelete = note
                                showingDeleteAlert = true
                            }
                            .offset(y: appearAnimation ? 0 : CGFloat(20 + index * 5))
                            .opacity(appearAnimation ? 1 : 0)
                            .animation(Animations.smooth.delay(Double(index) * 0.05), value: appearAnimation)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
                
                // Add button
                HStack {
                    Spacer()
                    PremiumButton("New Note", icon: "plus", theme: theme) {
                        withAnimation(Animations.bouncy) {
                            showingNewNote = true
                        }
                    }
                    Spacer()
                }
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            withAnimation(Animations.smooth.delay(0.1)) {
                appearAnimation = true
            }
        }
        .sheet(isPresented: $showingNewNote) {
            NoteEditorView(note: nil, theme: theme)
        }
        .sheet(item: $editingNote) { note in
            NoteEditorView(note: note, theme: theme)
        }
        .alert("Delete Note?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let note = noteToDelete {
                    withAnimation(Animations.smooth) {
                        dataManager.deleteNote(note)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

// MARK: - Note Card with Dropdown Preview
struct NoteCard: View {
    let note: Note
    let theme: AppTheme
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovered = false
    
    // Show body content, or full content if no separate body
    var previewText: String {
        if !note.bodyContent.isEmpty {
            return note.bodyContent
        } else if !note.content.isEmpty {
            return note.content
        }
        return ""
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Card Row
            HStack(spacing: Spacing.sm) {
                // Emoji icon
                Text(note.emoji)
                    .font(.system(size: 16))
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(theme.cardHover))
                
                VStack(alignment: .leading, spacing: 2) {
                    // First line as title (Apple Notes style)
                    Text(note.displayTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(theme.primaryText)
                        .lineLimit(1)
                    
                    Text(timeAgo(note.updatedAt))
                        .font(.system(size: 10))
                        .foregroundColor(theme.tertiaryText)
                }
                
                Spacer()
                
                // Action buttons on hover
                if isHovered {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(theme.tertiaryText)
                    .rotationEffect(.degrees(isHovered ? 90 : 0))
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isHovered ? theme.cardHover : theme.cardBackground)
            )
            .contentShape(Rectangle())
            .onTapGesture { onEdit() }
            
            // Dropdown Preview - Body content on HOVER
            if isHovered && !previewText.isEmpty {
                Text(previewText)
                    .font(.system(size: 11))
                    .foregroundColor(theme.secondaryText)
                    .lineLimit(3)
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.black)
                    )
                    .padding(.top, 4)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8, anchor: .top).combined(with: .opacity),
                        removal: .scale(scale: 0.9, anchor: .top).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.55), value: isHovered)
        .onHover { hovering in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.5)) {
                isHovered = hovering
            }
        }
    }
    
    func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Apple Notes Style Editor
struct NoteEditorView: View {
    let note: Note?
    let theme: AppTheme
    
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var content: String = ""
    @State private var emoji: String = "📝"
    @State private var appearAnimation = false
    
    // Check if content is not empty (for save button)
    var canSave: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Minimal Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.secondaryText)
                }
                .buttonStyle(.plain)
                .hoverScale(1.1)
                
                .hoverScale(1.1)
                
                Spacer()
                
                // Emoji / Symbol Picker
                TextField("", text: $emoji)
                    .font(.system(size: 24))
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(theme.cardBackground))
                    .overlay(Circle().stroke(theme.border, lineWidth: 1))
                    .onChange(of: emoji) { newValue in
                        if newValue.count > 1 {
                            emoji = String(newValue.last ?? "📝") // Just keep last char typed
                        }
                    }
                
                Spacer()
                
                Button(action: saveNote) {
                    Text("Done")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(canSave ? .black : theme.tertiaryText)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(canSave ? Color.white : theme.cardBackground)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canSave)
                .hoverScale(1.05)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            
            Divider()
                .opacity(0.2)
            
            // Content Editor (Apple Notes style - just content area)
            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("Start typing...")
                        .font(.system(size: 15))
                        .foregroundColor(theme.tertiaryText)
                        .padding(Spacing.md)
                }
                
                TextEditor(text: $content)
                    .font(.system(size: 15))
                    .foregroundColor(theme.primaryText)
                    .scrollContentBackground(.hidden)
                    .padding(Spacing.sm)
            }
            .frame(maxHeight: .infinity)
            .offset(y: appearAnimation ? 0 : 10)
            .opacity(appearAnimation ? 1 : 0)
        }
        .frame(width: 300, height: 320)
        .background(theme.background)
        .onAppear {
            if let note = note {
                content = note.content
                emoji = note.emoji
            }
            withAnimation(Animations.smooth.delay(0.05)) {
                appearAnimation = true
            }
        }
    }
    
    func saveNote() {
        guard canSave else { return }
        if let existingNote = note {
            dataManager.updateNote(existingNote, title: "", content: content, emoji: emoji)
        } else {
            dataManager.addNote(title: "", content: content, emoji: emoji)
        }
        dismiss()
    }
    
    // MARK: - Formatting Helpers
    
    /// Insert formatting around text (like **bold** or *italic*)
    func insertFormatting(prefix: String, suffix: String, placeholder: String) {
        if content.isEmpty {
            content = prefix + placeholder + suffix
        } else {
            // Add at end with newline if needed
            if !content.hasSuffix("\n") && !content.isEmpty {
                content += "\n"
            }
            content += prefix + placeholder + suffix
        }
    }
    
    /// Insert a prefix at a new line (like bullets or checkboxes)
    func insertAtNewLine(prefix: String) {
        if content.isEmpty {
            content = prefix
        } else {
            // Add newline and prefix
            if !content.hasSuffix("\n") {
                content += "\n"
            }
            content += prefix
        }
    }
}

// MARK: - Format Button
struct FormatButton: View {
    let icon: String
    let theme: AppTheme
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isHovered ? theme.primaryText : theme.secondaryText)
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isHovered ? theme.cardHover : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

#Preview {
    NotesView()
        .environmentObject(ThemeManager.shared)
        .frame(width: 320, height: 350)
}
