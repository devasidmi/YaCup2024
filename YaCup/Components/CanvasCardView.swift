//
//  CanvasCardView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 31.10.2024.
//

import SwiftUI


private struct AnimatedCanvas: View, Animatable {
    var geometry: GeometryProxy
    var rotation: Double
    
    @Binding var cardData: CardData
    @Binding var drawColor: Color
    @Binding var editorState: EditorState
    
    @State private var currentPath: DrawingPath?
    @State private var eraserPosition: CGPoint?
    
    private let lineWidth: CGFloat = 3
    private let eraserLineWidth: CGFloat = 48
    
    private var isFrontSide: Bool {
        let normalizedRotation = (rotation.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        return (normalizedRotation >= 0 && normalizedRotation <= 90) || (normalizedRotation >= 270 && normalizedRotation <= 360)
    }
    
    var animatableData: Double {
        get { rotation }
        set {
            print(newValue)
            rotation = newValue
        }
    }
    
    
    var body: some View {
        Canvas { context, size in
            let currentDrawingPaths = isFrontSide ? cardData.frontPaths : cardData.backPaths
            
            context.drawLayer { layerContext in
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
            
            if !isFrontSide {
                context.opacity = 0.3
                context.drawLayer { layerContext in
                    for path in cardData.frontPaths {
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
                        print("add front path")
                        cardData.frontPaths.append(path)
                    } else {
                        print("add back path")
                        cardData.backPaths.append(path)
                    }
                }
                currentPath = nil
                eraserPosition = nil
            }
    }
    
    private func handleErasing(at point: CGPoint) {
        let paths = isFrontSide ? cardData.frontPaths : cardData.backPaths
        let eraserRadius = eraserLineWidth / 2
        
        var newPaths: [DrawingPath] = []
        var pathsToRemove: Set<UUID> = []
        
        for path in paths {
            if path.isPointNearPath(point, threshold: eraserRadius) {
                if let (firstHalf, secondHalf) = path.split(at: point) {
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
            cardData.frontPaths = cardData.frontPaths.filter { !pathsToRemove.contains($0.id) }
            cardData.frontPaths.append(contentsOf: newPaths)
        } else {
            cardData.backPaths = cardData.backPaths.filter { !pathsToRemove.contains($0.id) }
            cardData.backPaths.append(contentsOf: newPaths)
        }
    }
}

struct CanvasCardView: View {
    var geometry: GeometryProxy
    
    @Binding var cardData: CardData
    @Binding var editorState: EditorState
    @Binding var drawColor: Color
    
    @State private var initialRotation: Double = 0.0
    @State private var isAnimating = false
    @State private var isDragging = false
    @State private var rotation: Double = 0.0
    
    
    @State private var isFrontSide: Bool = true
    
    
    private let thresholdPercentage: CGFloat = 0.25
    private let flipAngle: Double = 180.0
    private var flipEnabled: Bool {
        editorState == .none
    }
    
    var body: some View {
        ZStack {
            Image("Card")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(16)
            AnimatedCanvas(geometry: geometry, rotation: rotation, cardData: $cardData, drawColor: $drawColor, editorState: $editorState)
        }
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
        .gesture(flipGesture)
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
