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
    
    private func removeCard() {
        if cardData.count == 1 {
            cardData.append(CardData(scale: 0.85))
            
            cardData.removeFirst()
            
            cardIndex = 0
            
            cardData[cardIndex].offsetX = 0
            cardData[cardIndex].offsetY = 0
            cardData[cardIndex].rotation = 0
            
            withAnimation(.spring(duration: 0.3)) {
                cardData[cardIndex].scale = 1
            }
            return
        }
        
        cardData.remove(at: cardIndex)
        
        cardIndex = cardData.count - 1
        
        cardData[cardIndex].offsetX = 0
        cardData[cardIndex].offsetY = 0
        cardData[cardIndex].rotation = 0
        cardData[cardIndex].scale = 0.85
        
        withAnimation(.spring(duration: 0.3)) {
            cardData[cardIndex].scale = 1
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                CanvasView(editorState: $editorState, drawColor: $drawColor, cardData: $cardData)
                Spacer()
                EditorControls(
                    editorState: $editorState,
                    drawColor: $drawColor,
                    onEdit: {
                        triggerHapticFeedback()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            editorState = editorState == .drawing ? .none : .drawing
                        }
                    }, onErase: {
                        triggerHapticFeedback()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            editorState = (editorState == .erasing) ? .none : .erasing
                        }
                    }
                )
            }
            .toolbar {
                EditorToolbar(
                    undoAvailable: $undoAvailable,
                    revertAvailable: $revertAvailable,
                    onAddNewCard: addNewCard,
                    onRemoveCard: removeCard
                )
            }
            
        }
        
    }
}

#Preview {
    EditorView()
}
