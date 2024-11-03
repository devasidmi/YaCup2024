//
//  Canvas.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 01.11.2024.
//

import SwiftUI

struct CanvasView: View {
    let mainPaths: [DrawingPath]
    let opacityPaths: [DrawingPath]
    var currentPath: DrawingPath? = nil
    
    var body: some View {
        Canvas { context, size in
            context.drawLayer { layerContext in
                for path in mainPaths {
                    var stroke = Path()
                    let scaledPoints = path.points.map { point in
                        CGPoint(
                            x: point.x * (size.width / path.size.width),
                            y: point.y * (size.height / path.size.height)
                        )
                    }
                    stroke.addLines(scaledPoints)
                    layerContext.stroke(
                        stroke,
                        with: .color(path.colorHex.toColor() ?? Color.blue),
                        style: StrokeStyle(
                            lineWidth: path.lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                }
                
                if let currentPath = currentPath {
                    var stroke = Path()
                    let scaledPoints = currentPath.points.map { point in
                        CGPoint(
                            x: point.x * (size.width / currentPath.size.width),
                            y: point.y * (size.height / currentPath.size.height)
                        )
                    }
                    stroke.addLines(scaledPoints)
                    layerContext.stroke(
                        stroke,
                        with: .color(currentPath.colorHex.toColor() ?? Color.blue),
                        style: StrokeStyle(
                            lineWidth: currentPath.lineWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                }
            }
            
            context.opacity = 0.3
            context.drawLayer { layerContext in
                for path in opacityPaths {
                    var stroke = Path()
                    let scaledPoints = path.points.map { point in
                        CGPoint(
                            x: size.width - (point.x * (size.width / path.size.width)),
                            y: point.y * (size.height / path.size.height)
                        )
                    }
                    stroke.addLines(scaledPoints)
                    layerContext.stroke(
                        stroke,
                        with: .color(path.colorHex.toColor() ?? Color.blue),
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
}
