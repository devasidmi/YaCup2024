//
//  SplashView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 02.11.2024.
//

import SwiftUI

struct SplashView: View {
    @ObservedObject var coordinator: ViewCoordinator
    
    var body: some View {
        VStack {
            Image("Splash")
                .resizable()
                .scaledToFit()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                coordinator.showMainScreen()
            }
        }
    }
}
