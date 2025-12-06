import Foundation

class AIService: ObservableObject {
    static let shared = AIService()
    
    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "pixelnotes_gemini_key")
        }
    }
    
    init() {
        self.apiKey = UserDefaults.standard.string(forKey: "pixelnotes_gemini_key") ?? ""
    }
    
    func chat(message: String, context: String) async -> String {
        // If no API key, use offline mode with smart responses
        guard !apiKey.isEmpty else {
            return offlineResponse(for: message, context: context)
        }
        
        // Use Gemini 2.0 Flash API
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)")!
        
        let systemPrompt = """
        You are a helpful AI assistant for PIXS (PixelNotes).
        You have access to the user's notes and reminders below.
        
        Guidelines:
        - Use nice Markdown formatting (bold key terms, use bullet points for lists).
        - Keep responses concise but friendly.
        - If listing items, use standard bullet points.
        - Add a relevant emoji occasionally to match the app's vibe.
        
        USER'S DATA:
        \(context)
        """
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": "\(systemPrompt)\n\nUser question: \(message)"]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 300
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP status
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("API Error: HTTP \(httpResponse.statusCode)")
                    if let errorText = String(data: data, encoding: .utf8) {
                        print("Error body: \(errorText)")
                    }
                    return "API Error: Please check your API key in Settings. (HTTP \(httpResponse.statusCode))"
                }
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                print("Parse error - Response: \(String(data: data, encoding: .utf8) ?? "nil")")
                return "I couldn't parse the response. Please try again."
            }
        } catch {
            print("Network Error: \(error.localizedDescription)")
            return "Network error: \(error.localizedDescription). Please check your connection."
        }
    }
    
    // Offline mode - smart keyword matching from notes
    func offlineResponse(for message: String, context: String) -> String {
        let lowercased = message.lowercased()
        
        // Count notes
        if lowercased.contains("how many") && lowercased.contains("note") {
            let count = context.components(separatedBy: "Title:").count - 1
            if count == 0 {
                return "You don't have any notes yet. Create one by tapping 'New Note'! 📝"
            }
            return "You have \(count) note\(count == 1 ? "" : "s"). \(count > 3 ? "Quite the collector! 📚" : "")"
        }
        
        // Reminders check
        if lowercased.contains("reminder") || lowercased.contains("task") || lowercased.contains("todo") {
            if context.contains("[Pending]") {
                let pendingCount = context.components(separatedBy: "[Pending]").count - 1
                return "You have \(pendingCount) pending reminder\(pendingCount == 1 ? "" : "s"). Check the Reminders tab to see them! ⏰"
            } else {
                return "No pending reminders! You're all caught up. 🎉"
            }
        }
        
        // Summary request
        if lowercased.contains("summary") || lowercased.contains("summarize") || lowercased.contains("what") && lowercased.contains("note") {
            let noteCount = context.components(separatedBy: "Title:").count - 1
            if noteCount == 0 {
                return "No notes to summarize yet. Start capturing your thoughts! ✨"
            }
            return "You have \(noteCount) notes. Add your Gemini API key in Settings to get AI-powered summaries and search! 🔑"
        }
        
        // Search for keywords in notes
        let searchWords = lowercased.components(separatedBy: .whitespaces).filter { $0.count > 3 }
        for word in searchWords {
            if context.lowercased().contains(word) && word != "note" && word != "about" && word != "what" {
                return "I found '\(word)' in your notes! 🔍 For detailed AI analysis, add your Gemini API key in Settings."
            }
        }
        
        // Default response
        return "I'm in offline mode. Add your free Gemini API key in Settings to unlock full AI features! 🤖\n\nGet one at: aistudio.google.com/app/apikey"
    }
}

