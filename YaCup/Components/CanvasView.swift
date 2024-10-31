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
            
            context.opacity = 0.3
            context.drawLayer { layerContext in
                for path in opacityPaths {
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
}
