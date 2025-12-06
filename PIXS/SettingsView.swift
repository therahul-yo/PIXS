import SwiftUI

struct SettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var aiService = AIService.shared
    @State private var apiKeyInput: String = ""
    @State private var showingApiKey = false
    
    var body: some View {
        Form {
            Section("Appearance") {
                Toggle("Dark Mode (Pitch Black)", isOn: $themeManager.isDarkMode)
            }
            
            Section("AI Integration") {
                HStack {
                    if showingApiKey {
                        TextField("Gemini API Key", text: $apiKeyInput)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        SecureField("Gemini API Key", text: $apiKeyInput)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Button(action: { showingApiKey.toggle() }) {
                        Image(systemName: showingApiKey ? "eye.slash" : "eye")
                    }
                }
                
                Button("Save API Key") {
                    aiService.apiKey = apiKeyInput
                }
                .disabled(apiKeyInput.isEmpty)
                
                Text("Get your free API key from [Google AI Studio](https://aistudio.google.com/app/apikey)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Developer", value: "PixelNotes Team")
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 300)
        .onAppear {
            apiKeyInput = aiService.apiKey
        }
    }
}

#Preview {
    SettingsView()
}
