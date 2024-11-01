//
//  EditorToolbar.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 31.10.2024.
//

import SwiftUI

struct EditorToolbarView: View {
    let showAllMode: Bool
    @Binding var undoAvailable: Bool
    @Binding var revertAvailable: Bool
    @State private var showDeleteConfirmation = false
    
    let onAddNewCard: (_ copy: Bool) -> Void
    let onRemoveCard: () -> Void
    let onShowAll: () -> Void
    
    var body: some View {
        HStack {
            if showAllMode {
                Button(action: {
                    onShowAll()
                }) {
                    Text("Done")
                        .foregroundColor(.yellow)
                }
                .transition(.opacity)
            } else {
                Image(systemName: "arrow.uturn.backward.circle")
                    .foregroundColor(undoAvailable ? .yellow : .gray)
                Image(systemName: "arrow.uturn.forward.circle")
                    .foregroundColor(revertAvailable ? .yellow : .gray)
                Spacer()
                    .frame(width: 16)
                Menu {
                    Section {
                        Button(action: {
                            onAddNewCard(false)
                        }) {
                            Label("Create new", systemImage: "plus")
                        }
                        Button(action: {
                            onAddNewCard(true)
                        }) {
                            Label("Create copy", systemImage: "document.on.document")
                        }
                    }
                    Button(action: {
                        onShowAll()
                    }) {
                        Label("Show all", systemImage: "square.grid.2x2")
                    }
                    Section {
                        Button(role: .destructive, action: {
                            showDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle").foregroundColor(.yellow)
                }
            }
        }
        .animation(.linear, value: showAllMode)
        .alert("Delete Card", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onRemoveCard()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this card?")
        }
    }
}