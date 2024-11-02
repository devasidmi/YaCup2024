//
//  LibraryView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 02.11.2024.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var coordinator: ViewCoordinator
    
    var body: some View {
        NavigationView {
            VStack {
                
            }
            .sheet(isPresented: $coordinator.isSettingsPresented) {
                SettingsView()
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        coordinator.openSettings()
                    }) {
                        Image(systemName: "gearshape").foregroundColor(.yellow)
                    }
                }
            }
        }
    }
}
