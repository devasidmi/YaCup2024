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
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch coordinator.currentScreen {
                case .splash:
                    SplashView(coordinator: coordinator)
                case .main:
                    ContentView()
                }
            }
        }
    }
}
