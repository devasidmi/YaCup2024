//
//  EditorControls.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 31.10.2024.
//

import SwiftUI

struct EditorControlsView: View {
    @Binding var editorState: EditorState
    @Binding var drawColor: Color
    @Binding var pencilWidth: Double
    @Binding var eraserWidth: Double
    
    @State private var showPencilSettings = false
    @State private var showEraserSettings = false
    
    let onEdit: () -> Void
    let onErase: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "pencil.tip").imageScale(.large)
                .foregroundColor(editorState == .drawing ? .yellow : .gray)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            showPencilSettings = true
                        }
                )
                .onTapGesture {
                    onEdit()
                }
            Spacer()
            Image(systemName: "eraser.line.dashed").imageScale(.large)
                .foregroundColor(editorState == .erasing ? .yellow : .gray)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            showEraserSettings = true
                        }
                )
                .onTapGesture {
                    onErase()
                }
            if editorState == .drawing {
                Spacer()
                ColorPicker("Colors", selection: $drawColor).frame(width: 32, height: 32)
            }
            Spacer()
        }.frame(height: 32)
            .sheet(isPresented: $showPencilSettings) {
                EditorSettingsView(width: $pencilWidth, type: .pencil)
                    .presentationDetents([.height(250)])
                    .transition(.move(edge: .bottom))
            }
            .sheet(isPresented: $showEraserSettings) {
                EditorSettingsView(width: $eraserWidth, type: .eraser)
                    .presentationDetents([.height(250)])
                    .transition(.move(edge: .bottom))
            }
    }
}

private enum EditorSettingsType {
    case pencil
    case eraser
    
    var icon: String {
        switch self {
        case .pencil: return "pencil.tip"
        case .eraser: return "eraser.line.dashed"
        }
    }
    
    var sliderRange: ClosedRange<Double> {
        switch self {
        case .pencil: return 1...20
        case .eraser: return 1...40
        }
    }
}

private struct EditorSettingsView: View {
    @Binding var width: Double
    @Environment(\.dismiss) var dismiss
    let type: EditorSettingsType
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(systemName: type.icon)
                .imageScale(.large)
                .font(.title2)
                .padding(.top, 32)
            
            Slider(value: $width, in: type.sliderRange)
                .tint(.yellow)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.05))
                )
                .padding(.horizontal)
            
            Button("Apply") {
                triggerHapticFeedback()
                dismiss()
            }
            .frame(width: 100, height: 20)
            .padding()
            .background(Color.yellow)
            .foregroundColor(.black)
            .clipShape(Capsule())
            .padding(.horizontal)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 32)
    }
}
