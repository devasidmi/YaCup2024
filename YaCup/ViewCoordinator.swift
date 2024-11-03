//
//  ViewCoordinator.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 02.11.2024.
//

import SwiftUI

final class ViewCoordinator: ObservableObject {
    @Published var currentScreen: Screen = .splash
    @Published var isSettingsPresented: Bool = false
    
    enum Screen {
        case splash
        case library
    }
    
    func showMainScreen() {
        withAnimation {
            currentScreen = .library
        }
    }
    
    func openSettings() {
        isSettingsPresented = true
    }
}
