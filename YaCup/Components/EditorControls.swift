//
//  EditorControls.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 31.10.2024.
//

import SwiftUI

struct EditorControls: View {
    @Binding var editorState: EditorState
    @Binding var drawColor: Color
    
    var onEdit: () -> Void
    var onErase: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "pencil.tip").imageScale(.large)
                .foregroundColor(editorState == .drawing ? .yellow : .gray)
                .onTapGesture {
                    onEdit()
                }
            Spacer()
            Image(systemName: "eraser.line.dashed").imageScale(.large)
                .foregroundColor(editorState == .erasing ? .yellow : .gray)
                .onTapGesture {
                    onErase()
                }
            if editorState == .drawing {
                Spacer()
                ColorPicker("Colors", selection: $drawColor).frame(width: 32, height: 32)
            }
            Spacer()
        }.frame(height: 32)
    }
}
