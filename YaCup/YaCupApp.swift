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
    @AppStorage("selectedTheme") private var selectedTheme = "system"
    
    private var colorScheme: ColorScheme? {
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
                        .preferredColorScheme(colorScheme)
                case .editor:
                    EditorView().preferredColorScheme(colorScheme)
                }
            }
        }
    }
}
