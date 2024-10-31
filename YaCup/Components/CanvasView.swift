//
//  CanvasView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

struct CanvasView: View {
    @State private var rotation: Double = 0.0
    @State private var initialRotation: Double = 0.0
    @State private var isFrontSide = true
    @State private var isAnimating = false
    @State private var isDragging = false
    
    @Binding var editorState: EditorState
    @Binding var drawColor: Color
    
    private let thresholdPercentage: CGFloat = 0.25
    private let flipAngle: Double = 180.0
    
    private var flipEnabled: Bool {
        editorState == .none
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CanvasCardView(geometry: geometry, rotation: rotation, editorState: $editorState, drawColor: $drawColor)
            }
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            .gesture(flipGesture)
        }
    }
    
    private var flipGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if flipEnabled && !isAnimating {
                    let translation = gesture.translation.width
                    let screenWidth = UIScreen.main.bounds.width
                    
                    if !isDragging {
                        isDragging = true
                        initialRotation = rotation
                    }
                    
                    let progress = translation / screenWidth
                    let rotationDelta = Double(progress) * flipAngle
                    
                    rotation = initialRotation + rotationDelta
                }
            }
            .onEnded { gesture in
                if flipEnabled {
                    let translation = gesture.translation.width
                    let screenWidth = UIScreen.main.bounds.width
                    let progress = translation / screenWidth
                    
                    let threshold = thresholdPercentage
                    
                    if abs(progress) > threshold {
                        isAnimating = true
                        let direction: Double = progress > 0 ? 1 : -1
                        let targetRotation = initialRotation + flipAngle * direction
                        withAnimation(.easeInOut(duration: 0.5)) {
                            rotation = targetRotation
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isAnimating = false
                        }
                    } else {
                        withAnimation(.spring()) {
                            rotation = initialRotation
                        }
                    }
                    isDragging = false
                }
            }
    }
}

#Preview {
    CanvasView(editorState: .constant(.none), drawColor: .constant(.red))
}
