//
//  EditorView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 29.10.2024.
//

import SwiftUI

struct EditorView: View {
    
    @State private var editorState: EditorState = .none
    @State private var undoAvailable: Bool = false
    @State private var revertAvailable: Bool = false
    @State private var drawColor = Color(.blue)
    
    var body: some View {
        NavigationStack {
            VStack {
                CanvasView(editorState: $editorState, drawColor: $drawColor)
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "pencil.tip").imageScale(.large)
                        .foregroundColor(editorState == .drawing ? .yellow : .gray)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                editorState = editorState == .drawing ? .none : .drawing
                            }
                        }
                    Spacer()
                    Image(systemName: "eraser").imageScale(.large)
                        .foregroundColor(editorState == .erasing ? .yellow : .gray)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                editorState = (editorState == .erasing) ? .none : .erasing
                            }
                        }
                    Spacer()
                    Image(systemName: "square.and.pencil").imageScale(.large)
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            print("Create new canvas!")
                        }
                    if editorState == .drawing {
                        Spacer()
                        ColorPicker("Colors", selection: $drawColor).frame(width: 32, height: 32)
                    }
                    Spacer()
                }.frame(height: 32)
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
