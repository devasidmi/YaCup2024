//
//  CanvasView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

struct CanvasView: View {
    @State private var currentPath: DrawingPath?
    @State private var frontPaths: [DrawingPath] = []
    @State private var backPaths: [DrawingPath] = []
    @State private var backgroundImage: CGImage?
    
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
                    // Draw background if available
                    if let bgImage = backgroundImage {
                        context.draw(Image(decorative: bgImage, scale: 1.0), in: CGRect(origin: .zero, size: size))
                    }
                    
                    let currentDrawingPaths = isFrontSide ? frontPaths : backPaths
                    
                    // Create a single layer for all content
                    context.drawLayer { layerContext in
                        // Draw all paths
                        for path in currentDrawingPaths {
                            var stroke = Path()
                            stroke.addLines(path.points)
                            layerContext.stroke(
                                stroke,
                                with: .color(path.color),
                                style: StrokeStyle(
                                    lineWidth: path.lineWidth,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                        }
                        
                        // Draw current path if exists
                        if let currentPath = currentPath {
                            var stroke = Path()
                            stroke.addLines(currentPath.points)
                            layerContext.stroke(
                                stroke,
                                with: .color(currentPath.color),
                                style: StrokeStyle(
                                    lineWidth: currentPath.lineWidth,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                        }
                    }
                    
                    // Draw the other side with transparency
                    if !isFrontSide {
                        context.opacity = 0.3
                        context.drawLayer { layerContext in
                            // Draw paths from front side
                            for path in frontPaths {
                                var stroke = Path()
                                let points = path.points.map { CGPoint(x: size.width - $0.x, y: $0.y) }
                                stroke.addLines(points)
                                layerContext.stroke(
                                    stroke,
                                    with: .color(path.color),
                                    style: StrokeStyle(
                                        lineWidth: path.lineWidth,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                            }
                        }
                    }
                }
                .contentShape(Rectangle())
                .allowsHitTesting(editorState != .none)
                .gesture(editorState != .none ? drawingGesture(in: geometry) : nil)
                .mask(
                    Image("Card")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(16)
                )
                
                // Eraser cursor
                if editorState == .erasing, let position = eraserPosition {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: eraserLineWidth, height: eraserLineWidth)
                        Circle()
                            .stroke(Color.gray, lineWidth: 2)
                            .frame(width: eraserLineWidth, height: eraserLineWidth)
                    }
                    .position(position)
                }
            }
            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            .gesture(flipGesture)
        }
    }
    
    private func handleErasing(at point: CGPoint) {
        let paths = isFrontSide ? frontPaths : backPaths
        let eraserRadius = eraserLineWidth / 2
        
        var newPaths: [DrawingPath] = []
        var pathsToRemove: Set<UUID> = []
        
        for path in paths {
            if path.isPointNearPath(point, threshold: eraserRadius) {
                if let (firstHalf, secondHalf) = path.split(at: point) {
                    // Only add path segments if they're long enough
                    if firstHalf.points.count > 1 {
                        newPaths.append(firstHalf)
                    }
                    if secondHalf.points.count > 1 {
                        newPaths.append(secondHalf)
                    }
                }
                pathsToRemove.insert(path.id)
            }
        }
        
        if isFrontSide {
            frontPaths = frontPaths.filter { !pathsToRemove.contains($0.id) }
            frontPaths.append(contentsOf: newPaths)
        } else {
            backPaths = backPaths.filter { !pathsToRemove.contains($0.id) }
            backPaths.append(contentsOf: newPaths)
        }
    }
    
    private func drawingGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let location = value.location
                
                if editorState == .erasing {
                    eraserPosition = location
                    handleErasing(at: location)
                } else if editorState == .drawing {
                    if currentPath == nil {
                        currentPath = DrawingPath(
                            points: [location],
                            color: drawColor,
                            lineWidth: lineWidth
                        )
                    } else {
                        currentPath?.points.append(location)
                    }
                }
            }
            .onEnded { _ in
                if editorState == .drawing, let path = currentPath {
                    if isFrontSide {
                        frontPaths.append(path)
                    } else {
                        backPaths.append(path)
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
