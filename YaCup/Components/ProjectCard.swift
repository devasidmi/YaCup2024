//
//  ProjectCard.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 03.11.2024.
//

import SwiftUI
import CoreData

struct ProjectCard: View {
    @ObservedObject var project: ProjectData
    
    private var cards: [CardData] {
        let cardsData = project.cardsData ?? Data()
        let decodedCards = try? JSONDecoder().decode([CardData].self, from: cardsData)
        return decodedCards ?? []
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.name)
                .font(.headline)
                .foregroundColor(.primary)
            Text("\(cards.count) cards")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(project.createdAt, formatter: {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                return formatter
            }())
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
