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
    case showAll
    case none
}

struct DrawingPath: Identifiable, Codable {
    var id = UUID()
    var size: CGSize
    var points: [CGPoint]
    var colorHex: String
    var lineWidth: CGFloat
    
    init(size: CGSize, points: [CGPoint] = [], colorHex: String, lineWidth: CGFloat) {
        self.size = size
        self.points = points
        self.colorHex = colorHex
        self.lineWidth = lineWidth
    }
    
    enum CodingKeys: String, CodingKey {
        case id, size, points, colorHex, lineWidth
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        size = try container.decode(CGSize.self, forKey: .size)
        points = try container.decode([CGPoint].self, forKey: .points)
        colorHex = try container.decode(String.self, forKey: .colorHex)
        lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(size, forKey: .size)
        try container.encode(points, forKey: .points)
        try container.encode(colorHex.description, forKey: .colorHex)
        try container.encode(lineWidth, forKey: .lineWidth)
    }
    
    
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
    
    func split(at point: CGPoint, size: CGSize) -> (DrawingPath, DrawingPath)? {
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
            DrawingPath(size: size, points: firstHalf, colorHex: colorHex, lineWidth: lineWidth),
            DrawingPath(size: size, points: secondHalf, colorHex: colorHex, lineWidth: lineWidth)
        )
    }
}
