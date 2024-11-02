//
//  ViewCoordinator.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 02.11.2024.
//

import SwiftUI

final class ViewCoordinator: ObservableObject {
    @Published var currentScreen: Screen = .splash
    
    enum Screen {
        case splash
        case main
    }
    
    func showMainScreen() {
        withAnimation {
            currentScreen = .main
        }
    }
}
