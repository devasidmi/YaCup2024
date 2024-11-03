//
//  DrawHistoryManager.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 01.11.2024.
//

import SwiftUI

enum DrawingAction {
    case add(DrawingPath, Bool)
    case remove(DrawingPath, Bool)
    case split(DrawingPath, [DrawingPath], Bool)
}

final class EditorHistoryManager: ObservableObject {
    @Published private(set) var canUndo: Bool = false
    @Published private(set) var canRedo: Bool = false
    
    private var undoStack: [DrawingAction] = []
    private var redoStack: [DrawingAction] = []
    
    func addAction(_ action: DrawingAction) {
        undoStack.append(action)
        redoStack.removeAll()
        updateState()
    }
    
    func undo() -> DrawingAction? {
        guard let action = undoStack.popLast() else { return nil }
        redoStack.append(action)
        updateState()
        return action
    }
    
    func redo() -> DrawingAction? {
        guard let action = redoStack.popLast() else { return nil }
        undoStack.append(action)
        updateState()
        return action
    }
    
    private func updateState() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }
}
