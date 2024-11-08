//
//  EditorToolbar.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 31.10.2024.
//

import SwiftUI

struct EditorToolbarView: View {
    let showAllMode: Bool
    var undoAvailable: Bool
    var redoAvailable: Bool
    var totalCards: Int
    @State private var showDeleteConfirmation = false
    @State private var showDeleteAllConfirmation = false
    
    let onAddNewCard: (_ copy: Bool) -> Void
    let onRemoveCard: () -> Void
    let onRemoveAllCards: () -> Void
    let onShowAll: () -> Void
    let onUndo: () -> Void
    let onRedo: () -> Void
    let onShowProjectAnimation: () -> Void
    
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
                Button(action: {
                    onUndo()
                }) {
                    Image(systemName: "arrow.uturn.backward.circle")
                        .foregroundColor(undoAvailable ? .yellow : .gray)
                }
                Button(action: {
                    onRedo()
                }) {
                    Image(systemName: "arrow.uturn.forward.circle")
                        .foregroundColor(redoAvailable ? .yellow : .gray)
                }
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
                    if (totalCards > 1) {
                        Section {
                            Button(action: {
                                onShowProjectAnimation();
                            }) {
                                Label("Play animation", systemImage: "movieclapper")
                            }
                        }
                    }
                    if (totalCards > 1) {
                        Button(action: {
                            onShowAll()
                        }) {
                            Label("Show all", systemImage: "square.grid.2x2")
                        }
                    }
                    Section {
                        if (totalCards > 1) {
                            Button(role: .destructive, action: {
                                showDeleteAllConfirmation = true
                            }) {
                                Label("Delete all (\(totalCards))", systemImage: "xmark.bin")
                            }
                        }
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
        .alert("Delete All Cards", isPresented: $showDeleteAllConfirmation) {
            Button("Delete", role: .destructive) {
                onRemoveAllCards()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete all cards?")
        }
    }
}
