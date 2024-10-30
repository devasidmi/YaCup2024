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
    @State private var frontPaths: [DrawingPath] = []
    @State private var frontEraserPaths: [DrawingPath] = []
    @State private var backPaths: [DrawingPath] = []
    @State private var backEraserPaths: [DrawingPath] = []
    
    @State private var rotation: Double = 0.0
    @State private var isAnimating = false
    @State private var initialRotation: Double = 0.0
    @State private var isDragging = false
    @State private var eraserPosition: CGPoint?
    
    @Binding var editorState: EditorState
    @Binding var drawColor: Color
    
    private let lineWidth: CGFloat = 3
    private let eraserLineWidth: CGFloat = 48
    private let thresholdPercentage: CGFloat = 0.25
    private let flipAngle: Double = 180.0
    
    private var flipEnabled: Bool {
        editorState == .none
    }
    
    private var isFrontSide: Bool {
        let normalizedRotation = (rotation.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        return (normalizedRotation >= 0 && normalizedRotation <= 90) || (normalizedRotation >= 270 && normalizedRotation <= 360)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("Card")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(16)
                
                Canvas { context, size in
                    let currentDrawingPaths = isFrontSide ? frontPaths : backPaths
                    let currentEraserPaths = isFrontSide ? frontEraserPaths : backEraserPaths
                    
                    
                    context.drawLayer { layerContext in
                        drawPaths(context: &layerContext, paths: currentDrawingPaths, size: size)
                        drawPaths(context: &layerContext, paths: currentEraserPaths, size: size, isEraser: true)
                        
                        
                        if let currentPath = currentPath {
                            drawPath(context: &layerContext, path: currentPath, size: size)
                        }
                    }
                    
                    
                    if !isFrontSide {
                        context.opacity = 0.5
                        context.drawLayer { layerContext in
                            
                            drawPaths(context: &layerContext, paths: frontPaths, size: size, flipHorizontally: true)
                            
                            drawPaths(context: &layerContext, paths: frontEraserPaths, size: size, isEraser: true, flipHorizontally: true)
                        }
                    }
                }
                .contentShape(Rectangle())
                .allowsHitTesting(editorState != .none)
                .gesture(editorState != .none ? drawingGesture(in: geometry) : nil)
                .mask(Image("Card").resizable().aspectRatio(contentMode: .fit).padding(16))
                
                if editorState == .erasing, let position = eraserPosition {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: eraserLineWidth, height: eraserLineWidth)
                        Circle()
                            .stroke(Color.gray, lineWidth: 2)
                            .frame(width: eraserLineWidth, height: eraserLineWidth)
                    }
                    .position(adjustedPosition(for: position, in: geometry.size))
                }
            }
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            .gesture(flipGesture)
        }
    }
    
    private func drawPaths(context: inout GraphicsContext, paths: [DrawingPath], size: CGSize, isEraser: Bool = false, flipHorizontally: Bool = false) {
        for path in paths {
            drawPath(context: &context, path: path, size: size, isEraser: isEraser, flipHorizontally: flipHorizontally)
        }
    }
    
    private func drawPath(context: inout GraphicsContext, path: DrawingPath, size: CGSize, isEraser: Bool = false, flipHorizontally: Bool = false) {
        var adjustedPoints = path.points
        
        if (!isFrontSide && !isEraser) || flipHorizontally {
            adjustedPoints = adjustedPoints.map { CGPoint(x: size.width - $0.x, y: $0.y) }
        }
        
        var stroke = Path()
        stroke.addLines(adjustedPoints)
        
        if path.isEraser || isEraser {
            context.blendMode = .destinationOut
            context.stroke(stroke, with: .color(.black), lineWidth: path.lineWidth)
            context.blendMode = .normal
        } else {
            context.stroke(stroke, with: .color(path.color), lineWidth: path.lineWidth)
        }
    }
    
    private func adjustedPosition(for position: CGPoint, in size: CGSize) -> CGPoint {
        if !isFrontSide {
            return CGPoint(x: size.width - position.x, y: position.y)
        } else {
            return position
        }
    }
    
    private func drawingGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let newPoint: CGPoint
                if !isFrontSide {
                    newPoint = CGPoint(x: geometry.size.width - value.location.x, y: value.location.y)
                } else {
                    newPoint = value.location
                }
                if editorState == .drawing {
                    if currentPath == nil {
                        currentPath = DrawingPath(points: [newPoint], color: drawColor, lineWidth: lineWidth, isEraser: false)
                    } else {
                        currentPath?.points.append(newPoint)
                    }
                } else if editorState == .erasing {
                    eraserPosition = newPoint
                    if currentPath == nil {
                        currentPath = DrawingPath(points: [newPoint], color: .clear, lineWidth: eraserLineWidth, isEraser: true)
                    } else {
                        currentPath?.points.append(newPoint)
                    }
                }
            }
            .onEnded { _ in
                if let path = currentPath {
                    if editorState == .drawing {
                        if isFrontSide {
                            frontPaths.append(path)
                        } else {
                            backPaths.append(path)
                        }
                    } else if editorState == .erasing {
                        if isFrontSide {
                            frontEraserPaths.append(path)
                        } else {
                            backEraserPaths.append(path)
                        }
                    }
                }
                currentPath = nil
                eraserPosition = nil
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
    CanvasView(editorState: .constant(.drawing), drawColor: .constant(.red))
}
