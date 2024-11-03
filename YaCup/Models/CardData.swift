//
//  CardData.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 31.10.2024.
//

import Foundation
import SwiftUI

struct CardData: Identifiable, Codable {
    var id = UUID()
    var frontPaths: [DrawingPath]
    var backPaths: [DrawingPath]
    var offsetX: Double
    var offsetY: Double
    var rotation: Double
    var scale: Double
    
    enum CodingKeys: String, CodingKey {
        case id, frontPaths, backPaths, offsetX, offsetY, rotation, scale
    }
    
    init(id: UUID = UUID(),
         frontPaths: [DrawingPath] = [],
         backPaths: [DrawingPath] = [],
         offsetX: Double = 0,
         offsetY: Double = 0,
         rotation: Double = 0,
         scale: Double = 1
    ) {
        self.id = id
        self.frontPaths = frontPaths
        self.backPaths = backPaths
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.rotation = rotation
        self.scale = scale
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        frontPaths = try container.decode([DrawingPath].self, forKey: .frontPaths)
        backPaths = try container.decode([DrawingPath].self, forKey: .backPaths)
        offsetX = try container.decode(Double.self, forKey: .offsetX)
        offsetY = try container.decode(Double.self, forKey: .offsetY)
        rotation = try container.decode(Double.self, forKey: .rotation)
        scale = try container.decode(Double.self, forKey: .scale)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(frontPaths, forKey: .frontPaths)
        try container.encode(backPaths, forKey: .backPaths)
        try container.encode(Double(offsetX), forKey: .offsetX)
        try container.encode(Double(offsetY), forKey: .offsetY)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(Double(scale), forKey: .scale)
    }
    
    private let historyManager = EditorHistoryManager()
    
    var canRedo: Bool {
        historyManager.canRedo
    }
    
    var canUndo: Bool {
        historyManager.canUndo
    }
    
    mutating func addPath(_ path: DrawingPath, isFront: Bool) {
        if isFront {
            frontPaths.append(path)
        } else {
            backPaths.append(path)
        }
        historyManager.addAction(.add(path, isFront))
    }
    
    mutating func removePath(_ path: DrawingPath, isFront: Bool) {
        if isFront {
            frontPaths.removeAll { $0.id == path.id }
        } else {
            backPaths.removeAll { $0.id == path.id }
        }
        historyManager.addAction(.remove(path, isFront))
    }
    
    mutating func splitPath(_ original: DrawingPath, into newPaths: [DrawingPath], isFront: Bool) {
        if isFront {
            frontPaths.removeAll { $0.id == original.id }
            frontPaths.append(contentsOf: newPaths)
        } else {
            backPaths.removeAll { $0.id == original.id }
            backPaths.append(contentsOf: newPaths)
        }
        historyManager.addAction(.split(original, newPaths, isFront))
    }
    
    mutating func undo() {
        guard let action = historyManager.undo() else { return }
        applyReversedAction(action)
    }
    
    mutating func redo() {
        guard let action = historyManager.redo() else { return }
        applyAction(action)
    }
    
    private mutating func applyAction(_ action: DrawingAction) {
        switch action {
        case .add(let path, let isFront):
            if isFront {
                frontPaths.append(path)
            } else {
                backPaths.append(path)
            }
        case .remove(let path, let isFront):
            if isFront {
                frontPaths.removeAll { $0.id == path.id }
            } else {
                backPaths.removeAll { $0.id == path.id }
            }
        case .split(let original, let newPaths, let isFront):
            if isFront {
                frontPaths.removeAll { $0.id == original.id }
                frontPaths.append(contentsOf: newPaths)
            } else {
                backPaths.removeAll { $0.id == original.id }
                backPaths.append(contentsOf: newPaths)
            }
        }
    }
    
    private mutating func applyReversedAction(_ action: DrawingAction) {
        switch action {
        case .add(let path, let isFront):
            if isFront {
                frontPaths.removeAll { $0.id == path.id }
            } else {
                backPaths.removeAll { $0.id == path.id }
            }
        case .remove(let path, let isFront):
            if isFront {
                frontPaths.append(path)
            } else {
                backPaths.append(path)
            }
        case .split(let original, let newPaths, let isFront):
            if isFront {
                frontPaths.removeAll { path in newPaths.contains { $0.id == path.id } }
                frontPaths.append(original)
            } else {
                backPaths.removeAll { path in newPaths.contains { $0.id == path.id } }
                backPaths.append(original)
            }
        }
    }
}
