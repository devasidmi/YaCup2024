//
//  CanvasView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

struct EditorCardsView: View {
    
    @Binding var editorState: EditorState
    @Binding var drawColor: Color
    @Binding var lineWidth: Double
    @Binding var eraserLineWidth: Double
    @Binding var cardData: [CardData]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(cardData.enumerated()), id: \.element.id) { index, _ in
                    CanvasCardView(geometry: geometry,
                                   cardData: $cardData[index],
                                   editorState: $editorState,
                                   drawColor: $drawColor,
                                   lineWidth: $lineWidth,
                                   eraserLineWidth: $eraserLineWidth
                                   
                    )
                    .offset(x: cardData[index].offsetX, y: cardData[index].offsetY)
                    .rotationEffect(.degrees(cardData[index].rotation))
                    .scaleEffect(cardData[index].scale)
                    .zIndex(Double(cardData.count - index))
                }
            }
        }
    }
}
