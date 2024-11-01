//
//  DrawingPath+Mirror.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 01.11.2024.
//

import Foundation

extension [DrawingPath] {
    var mirrored: [DrawingPath] {
        map { path in
            var mirroredPath = path
            mirroredPath.points = path.points.map { point in
                CGPoint(x: path.size.width - point.x, y: point.y)
            }
            return mirroredPath
        }
    }
}
