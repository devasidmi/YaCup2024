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
    @State private var rotation = 0.0
    @State private var isAnimating = false
    
    @Binding var editorState: EditorState
    @Binding var drawColor: Color
    
    private let threshold: CGFloat = UIScreen.main.bounds.width / 16
    private var flipEnabled: Bool {
        editorState != .drawing && editorState != .erasing
    }
    private let lineWidth: CGFloat = 3
    
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
                            context.stroke(
                                stroke,
                                with: .color(.black),
                                lineWidth: path.lineWidth
                            )
                            context.blendMode = .normal // Reset blend mode
                        } else {
                            context.stroke(
                                stroke,
                                with: .color(path.color),
                                lineWidth: path.lineWidth
                            )
                        }
                    }
                    
                    if let currentPath = currentPath {
                        var stroke = Path()
                        stroke.addLines(currentPath.points)
                        
                        if currentPath.isEraser {
                            context.blendMode = .destinationOut
                            context.stroke(
                                stroke,
                                with: .color(.black),
                                lineWidth: currentPath.lineWidth
                            )
                            context.blendMode = .normal // Reset blend mode
                        } else {
                            context.stroke(
                                stroke,
                                with: .color(currentPath.color),
                                lineWidth: currentPath.lineWidth
                            )
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
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
                                    currentPath = DrawingPath(points: [newPoint], color: .clear, lineWidth: lineWidth, isEraser: true)
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
                )
            }
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
}

#Preview {
    CanvasView(editorState: .constant(EditorState.drawing), drawColor: .constant(.red))
}
