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
        CardData(),
    ]
    @State private var cardIndex: Int = 0
    
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func addNewCard(copy: Bool = false) {
        let oldIndex = cardIndex
        
        var newCardData = copy ? cardData[oldIndex] : CardData(
            frontPaths: cardData[oldIndex].backPaths.mirrored,
            scale: 0.85
        )
        if copy {
            newCardData.id = UUID()
        }
        
        cardData.append(newCardData)
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
    
    private func removeAllCards() {
        cardData = [CardData(scale: 0.85)]
        cardIndex = 0
        
        withAnimation(.spring(duration: 0.3)) {
            cardData[cardIndex].scale = 1
        }
    }
    
    private func onCardSelected(_ index: Int) {
        cardData[cardIndex].offsetX = -1000
        cardIndex = index
        cardData[cardIndex].offsetX = 0
        cardData[cardIndex].offsetY = 0
        cardData[cardIndex].rotation = 0
        cardData[cardIndex].scale = 1
    }
    
    private func onShowAll() {
        triggerHapticFeedback()
        withAnimation(.linear) {
            editorState = editorState == .showAll ? .none : .showAll
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if editorState == .showAll {
                    CardsCarouselView(cardData: $cardData, editorCardIndex: cardIndex, onCardSelected: onCardSelected)
                } else {
                    EditorCardsView(editorState: $editorState,
                                    drawColor: $drawColor,
                                    cardData: $cardData
                    )
                }
                Spacer()
                EditorControlsView(
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
                ).opacity(editorState == .showAll ? 0 : 1)
            }
            .toolbar {
                EditorToolbarView(
                    showAllMode: editorState == .showAll,
                    undoAvailable: $undoAvailable,
                    revertAvailable: $revertAvailable,
                    totalCards: cardData.count,
                    onAddNewCard: addNewCard,
                    onRemoveCard: removeCard,
                    onRemoveAllCards: removeAllCards,
                    onShowAll: onShowAll
                )
            }
            
        }
        
    }
}

#Preview {
    EditorView()
}
