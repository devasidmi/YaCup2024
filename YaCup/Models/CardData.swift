//
//  CardData.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 31.10.2024.
//

import Foundation
import SwiftUI

struct CardData: Identifiable {
    let id = UUID()
    var frontPaths: [DrawingPath] = []
    var backPaths: [DrawingPath] = []
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    var rotation: Double = 0
    var scale: CGFloat = 1
}
