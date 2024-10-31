//
//  EditorView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

struct EditorView: View {
    
    @State private var editorState: EditorState = .none
    @State private var undoAvailable: Bool = false
    @State private var revertAvailable: Bool = false
    @State private var drawColor = Color(.blue)
    @State private var cardData: [CardData] = [
        CardData()
    ]
    @State private var cardIndex: Int = 0
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func addNewCard() {
        let oldIndex = cardIndex
        
        cardData.append(CardData(scale: 0.85))
        cardIndex = cardData.count - 1
        
        withAnimation(.spring(duration: 1.2)) {
            cardData[oldIndex].offsetX = -1000
            cardData[oldIndex].offsetY = 0
            cardData[oldIndex].rotation = -15
            
            cardData[cardIndex].scale = 1
            cardData[cardIndex].offsetY = 0
            cardData[cardIndex].rotation = 0
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                CanvasView(editorState: $editorState, drawColor: $drawColor, cardData: $cardData)
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "pencil.tip").imageScale(.large)
                        .foregroundColor(editorState == .drawing ? .yellow : .gray)
                        .onTapGesture {
                            triggerHapticFeedback()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                editorState = editorState == .drawing ? .none : .drawing
                            }
                        }
                    Spacer()
                    Image(systemName: "eraser").imageScale(.large)
                        .foregroundColor(editorState == .erasing ? .yellow : .gray)
                        .onTapGesture {
                            triggerHapticFeedback()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                editorState = (editorState == .erasing) ? .none : .erasing
                            }
                        }
                    if editorState == .drawing {
                        Spacer()
                        ColorPicker("Colors", selection: $drawColor).frame(width: 32, height: 32)
                    }
                    Spacer()
                }.frame(height: 32)
            }
            .toolbar {
                Image(systemName: "arrow.uturn.backward.circle")
                    .foregroundColor(undoAvailable ? .yellow : .gray)
                Image(systemName: "arrow.uturn.forward.circle")
                    .foregroundColor(revertAvailable ? .yellow : .gray)
                Spacer()
                    .frame(width: 16)
                Menu {
                    Button(action: {
                        triggerHapticFeedback()
                        addNewCard()
                    }) {
                        Label("Create new", systemImage: "plus")
                    }
                    Button(action: {
                        print("Show all")
                    }) {
                        Label("Show all", systemImage: "square.grid.2x2")
                    }
                    Button(role: .destructive, action: {
                        print("Delete")
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle").foregroundColor(.yellow)
                }
            }
            
        }
        
    }
}

#Preview {
    EditorView()
}
