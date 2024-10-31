//
//  CanvasCardView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 31.10.2024.
//

import SwiftUI

struct CanvasCardView: View, Animatable {
    var geometry: GeometryProxy
    var rotation: Double = 0
    @Binding var editorState: EditorState
    @Binding var drawColor: Color
    
    @State private var currentPath: DrawingPath?
    @State private var frontPaths: [DrawingPath] = []
    @State private var backPaths: [DrawingPath] = []
    @State private var eraserPosition: CGPoint?
    
    private let lineWidth: CGFloat = 3
    private let eraserLineWidth: CGFloat = 48
    
    
    private var isFrontSide: Bool {
        let normalizedRotation = (rotation.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        return (normalizedRotation >= 0 && normalizedRotation <= 90) || (normalizedRotation >= 270 && normalizedRotation <= 360)
    }
    
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    var body: some View {
        ZStack {
            Image("Card")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(16)
            Canvas { context, size in
                let currentDrawingPaths = isFrontSide ? frontPaths : backPaths
                
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
    
    private func handleErasing(at point: CGPoint) {
        let paths = isFrontSide ? frontPaths : backPaths
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
            frontPaths = frontPaths.filter { !pathsToRemove.contains($0.id) }
            frontPaths.append(contentsOf: newPaths)
        } else {
            backPaths = backPaths.filter { !pathsToRemove.contains($0.id) }
            backPaths.append(contentsOf: newPaths)
        }
    }
}
