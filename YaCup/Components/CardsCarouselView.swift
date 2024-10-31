//
//  CardsCarousel.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 31.10.2024.
//

import SwiftUI

struct CardsCarouselView: View {
    @Binding var cardData: [CardData]
    var editorCardIndex: Int
    var onCardSelected: (Int) -> Void
    
    
    var body: some View {
        VStack(spacing: 16) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(0..<cardData.count, id: \.self) { index in
                            VStack {
                                Image("Card")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .scaleEffect(0.90)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.yellow, lineWidth: index == editorCardIndex ? 8 : 0)
                                            .padding(.vertical, 32)
                                            .padding(.horizontal, 16)
                                    )
                                Circle()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(editorCardIndex == index ? .yellow : .gray)
                                    .overlay(Text("\(index+1)").foregroundColor(.black))
                            }
                            .frame(width: UIScreen.main.bounds.width - 32)
                            .padding(.horizontal, 16)
                            .id(index)
                            .onTapGesture {
                                onCardSelected(index)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .onAppear() {
                    proxy.scrollTo(editorCardIndex, anchor: .center)
                }
            }
        }
    }
}
