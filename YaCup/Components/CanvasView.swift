//
//  CanvasView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

struct CanvasView: View {
    
    @Binding var editorState: EditorState
    @Binding var drawColor: Color
    @Binding var cardData: [CardData]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach($cardData) { item in
                    CanvasCardView(geometry: geometry, cardData: item, editorState: $editorState, drawColor: $drawColor)
                        .offset(x: item.wrappedValue.offsetX, y: item.wrappedValue.offsetY)
                        .rotationEffect(.degrees(item.wrappedValue.rotation))
                        .scaleEffect(item.wrappedValue.scale)
                }
            }
        }
    }
}

//#Preview {
//    CanvasView(editorState: .constant(.none), drawColor: .constant(.red))
//}
