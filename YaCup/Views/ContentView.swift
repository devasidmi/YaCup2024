//
//  ContentView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            EditorView()
        }.ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}