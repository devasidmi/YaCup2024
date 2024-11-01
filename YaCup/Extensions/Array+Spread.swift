//
//  Array+Spread.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 01.11.2024.
//

import Foundation

extension Array {
    static func ... (lhs: [Self.Element], rhs: [Self.Element]) -> [Self.Element] {
        var copy = lhs
        copy.append(contentsOf: rhs)
        return copy
    }
}
