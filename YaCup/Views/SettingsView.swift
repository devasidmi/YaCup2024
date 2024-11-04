//
//  SettingsView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 02.11.2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.locale) private var locale
    
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    @AppStorage("appTheme") private var selectedTheme = "system"
    
    private let languages = [
        ("en", "English"),
        ("ru", "Русский")
    ]
    
    private let themes = [
        ("system", LocalizedStringKey("System")),
        ("dark", LocalizedStringKey("Dark")),
        ("light", LocalizedStringKey("Light"))
    ]
    
    private var appColorScheme: ColorScheme? {
        switch selectedTheme {
        case "dark":
            return .dark
        case "light":
            return .light
        default:
            return nil
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 20) {
                    Spacer().frame(height: 16)
                    HStack {
                        Image(systemName: "translate")
                        Text("Language")
                        Spacer()
                        Picker("", selection: $selectedLanguage) {
                            ForEach(languages, id: \.0) { language in
                                Text(language.1).tag(language.0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    
                    HStack {
                        Image(systemName: "paintbrush")
                        Text("Theme")
                        Spacer()
                        Picker("", selection: $selectedTheme) {
                            ForEach(themes, id: \.0) { theme in
                                Text(theme.1).tag(theme.0)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(.primary)
                        .fixedSize()
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(10)
                }
                .padding()
                
                Spacer()
                Text("👨🏻‍💻 Made by @vasidmi")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Settings")
            .background(Color(uiColor: .systemGroupedBackground))
        }
        .id(locale)
        .preferredColorScheme(appColorScheme)
    }
    
}
