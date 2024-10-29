//
//  CanvasView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

struct DrawingPath: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    var isEraser: Bool
}

struct CanvasView: View {
    @State private var currentPath: DrawingPath?
    @State private var paths: [DrawingPath] = []
    @State private var rotation: Double = 0.0
    @State private var isAnimating = false
    @State private var initialRotation: Double = 0.0
    @State private var isDragging = false
    
    @Binding var editorState: EditorState
    @Binding var drawColor: Color
    
    private let lineWidth: CGFloat = 3
    private let eraserLineWidth: CGFloat = 20
    private let thresholdPercentage: CGFloat = 0.25
    private let flipAngle: Double = 180.0
    
    private var flipEnabled: Bool {
        editorState == .none
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("Card")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(16)
                
                Canvas { context, size in
                    for path in paths {
                        var stroke = Path()
                        stroke.addLines(path.points)
                        if path.isEraser {
                            context.blendMode = .destinationOut
                            context.stroke(stroke, with: .color(.black), lineWidth: path.lineWidth)
                            context.blendMode = .normal
                        } else {
                            context.stroke(stroke, with: .color(path.color), lineWidth: path.lineWidth)
                        }
                    }
                    
                    if let currentPath = currentPath {
                        var stroke = Path()
                        stroke.addLines(currentPath.points)
                        if currentPath.isEraser {
                            context.blendMode = .destinationOut
                            context.stroke(stroke, with: .color(.black), lineWidth: currentPath.lineWidth)
                            context.blendMode = .normal
                        } else {
                            context.stroke(stroke, with: .color(currentPath.color), lineWidth: currentPath.lineWidth)
                        }
                    }
                }
                .contentShape(Rectangle())
                .allowsHitTesting(editorState != .none)
                .gesture(editorState != .none ? drawingGesture : nil)
            }
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            .gesture(flipGesture)
        }
    }
    
    private var drawingGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let newPoint = value.location
                if editorState == .drawing {
                    if currentPath == nil {
                        currentPath = DrawingPath(points: [newPoint], color: drawColor, lineWidth: lineWidth, isEraser: false)
                    } else {
                        currentPath?.points.append(newPoint)
                    }
                } else if editorState == .erasing {
                    if currentPath == nil {
                        currentPath = DrawingPath(points: [newPoint], color: .clear, lineWidth: eraserLineWidth, isEraser: true)
                    } else {
                        currentPath?.points.append(newPoint)
                    }
                }
            }
            .onEnded { _ in
                if let path = currentPath {
                    paths.append(path)
                }
                currentPath = nil
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
