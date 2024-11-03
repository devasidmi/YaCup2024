//
//  YaCupApp.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

@main
struct YaCupApp: App {
    @StateObject private var coordinator = ViewCoordinator()
    
    @Environment(\.colorScheme) var systemColorScheme
    
    @AppStorage("appTheme") private var selectedTheme = "system"
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    
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
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch coordinator.currentScreen {
                case .splash:
                    SplashView(coordinator: coordinator)
                        .preferredColorScheme(.dark)
                case .library:
                    LibraryView(coordinator: coordinator)
                        .preferredColorScheme(appColorScheme)
                        .environment(\.locale, Locale(identifier: selectedLanguage))
                }
            }
            .environment(\.managedObjectContext, ProjectsDataProvider.shared.viewContext)
            .environment(\.locale, Locale(identifier: selectedLanguage))
        }
    }
}
