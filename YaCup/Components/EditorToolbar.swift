//
//  EditorToolbar.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 31.10.2024.
//

import SwiftUI

struct EditorToolbar: View {
    @Binding var undoAvailable: Bool
    @Binding var revertAvailable: Bool
    
    var onAddNewCard: () -> Void
    var onRemoveCard: () -> Void
    
    
    var body: some View {
        Image(systemName: "arrow.uturn.backward.circle")
            .foregroundColor(undoAvailable ? .yellow : .gray)
        Image(systemName: "arrow.uturn.forward.circle")
            .foregroundColor(revertAvailable ? .yellow : .gray)
        Spacer()
            .frame(width: 16)
        Menu {
            Button(action: {
                onAddNewCard()
            }) {
                Label("Create new", systemImage: "plus")
            }
            Button(action: {
                print("Show all")
            }) {
                Label("Show all", systemImage: "square.grid.2x2")
            }
            Section {
                Button(role: .destructive, action: {
                    onRemoveCard()
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle").foregroundColor(.yellow)
        }
    }
}
