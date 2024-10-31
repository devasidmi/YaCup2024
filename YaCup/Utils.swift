//
//  Utils.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

enum EditorState {
    case drawing
    case erasing
    case none
}

struct DrawingPath: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    
    func isPointNearPath(_ point: CGPoint, threshold: CGFloat) -> Bool {
        guard points.count > 1 else { return false }
        
        for i in 0..<points.count - 1 {
            let start = points[i]
            let end = points[i + 1]
            
            let closest = closestPointOnLineSegment(start: start, end: end, point: point)
            let distance = sqrt(pow(closest.x - point.x, 2) + pow(closest.y - point.y, 2))
            
            if distance < threshold {
                return true
            }
        }
        return false
    }
    
    private func closestPointOnLineSegment(start: CGPoint, end: CGPoint, point: CGPoint) -> CGPoint {
        let dx = end.x - start.x
        let dy = end.y - start.y
        
        if dx == 0 && dy == 0 {
            return start
        }
        
        let t = ((point.x - start.x) * dx + (point.y - start.y) * dy) / (dx * dx + dy * dy)
        
        if t < 0 {
            return start
        } else if t > 1 {
            return end
        }
        
        return CGPoint(
            x: start.x + t * dx,
            y: start.y + t * dy
        )
    }
    
    func split(at point: CGPoint) -> (DrawingPath, DrawingPath)? {
        guard points.count > 1 else { return nil }
        
        var splitIndex = 0
        var closestDistance = CGFloat.infinity
        
        for i in 0..<points.count - 1 {
            let start = points[i]
            let end = points[i + 1]
            let closest = closestPointOnLineSegment(start: start, end: end, point: point)
            let distance = sqrt(pow(closest.x - point.x, 2) + pow(closest.y - point.y, 2))
            
            if distance < closestDistance {
                closestDistance = distance
                splitIndex = i
            }
        }
        
        let firstHalf = Array(points[0...splitIndex])
        let secondHalf = Array(points[splitIndex + 1..<points.count])
        
        return (
            DrawingPath(points: firstHalf, color: color, lineWidth: lineWidth),
            DrawingPath(points: secondHalf, color: color, lineWidth: lineWidth)
        )
    }
}
