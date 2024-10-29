//
//  CanvasView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

struct CanvasView: View {
    @State private var rotation = 0.0
    @State private var isAnimating = false
    
    @Binding var isEditing: Bool
    
    private let threshold: CGFloat = UIScreen.main.bounds.width / 16
    private var flipEnabled: Bool {
        isEditing
    }
    
    var body: some View {
        Image("Card")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(16)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0)
            )
            .gesture(
                flipEnabled ?
                DragGesture()
                    .onChanged { gesture in
                        if !isAnimating {
                            if abs(gesture.translation.width) > threshold {
                                isAnimating = true
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    rotation = gesture.translation.width > 0 ? 180 : -180
                                }
                                isAnimating = false
                            } else {
                                rotation = Double(gesture.translation.width / UIScreen.main.bounds.width * 360)
                                rotation = min(max(rotation, -180), 180)
                            }
                        }
                    }
                    .onEnded { gesture in
                        if abs(gesture.translation.width) <= threshold {
                            withAnimation(.spring()) {
                                rotation = 0
                            }
                        }
                    } : nil
            )
    }
}

#Preview {
    CanvasView(isEditing: .constant(false))
}
