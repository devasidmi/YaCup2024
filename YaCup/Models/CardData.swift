//
//  CardData.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 31.10.2024.
//

import Foundation
import SwiftUI

struct CardData: Identifiable {
    var id = UUID()
    var frontPaths: [DrawingPath] = []
    var backPaths: [DrawingPath] = []
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    var rotation: Double = 0
    var scale: CGFloat = 1
    
    private let historyManager = DrawHistoryManager()
    
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
