//
//  EditorView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

struct EditorView: View {
    
    enum Tool {
        case draw
        case erase
    }
    @State private var currentTool: Tool? = .draw
    @State private var undoAvailable: Bool = false
    @State private var revertAvailable: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                CanvasView(flipEnabled: true)
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "pencil.tip").imageScale(.large)
                        .foregroundColor(currentTool == .draw ? .yellow : .gray)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                currentTool = (currentTool == .draw) ? nil : .draw
                            }
                        }
                    Spacer()
                    Image(systemName: "eraser").imageScale(.large)
                        .foregroundColor(currentTool == .erase ? .yellow : .gray)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                currentTool = (currentTool == .erase) ? nil : .erase
                            }
                        }
                    Spacer()
                    Image(systemName: "square.and.pencil").imageScale(.large)
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            print("Create new canvas!")
                        }
                    if currentTool == .draw {
                        Spacer()
                        Circle()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
            }
            .toolbar {
                Image(systemName: "arrow.uturn.backward.circle")
                    .foregroundColor(undoAvailable ? .yellow : .gray)
                Image(systemName: "arrow.uturn.forward.circle")
                    .foregroundColor(revertAvailable ? .yellow : .gray)
                Spacer()
                    .frame(width: 16)
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(Color.yellow)
            }
        }
        
    }
}

#Preview {
    EditorView()
}
