//
//  ProjectAnimationView.swift
//  YaCup
//
//  Created by Vasiliy Dmitriev on 04.11.2024.
//

import SwiftUI

struct ProjectAnimationView: View {
    let cards: [CardData]
    @State private var currentIndex = 0
    @State private var isPlaying = false
    @State private var timer: Timer?
    @State private var movingCardIndex: Int?
    
    private let animationDuration: Double = 0.8
    private let pauseBetweenCards: Double = 0.1
    private let stackOffset: CGFloat = 35
    private let moveOffset: CGFloat = 100
    private let rotationAngle: Double = 2
    private let minScale: CGFloat = 0.9
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    CardView(card: card)
                        .offset(x: getHorizontalOffset(for: index), y: 0)
                        .rotationEffect(.degrees(getRotation(for: index)))
                        .scaleEffect(getScale(for: index))
                        .zIndex(getZIndex(for: index))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.yellow)
                    .symbolEffect(.bounce, options: .repeat(1), value: isPlaying)
                    .contentTransition(.symbolEffect(.replace.downUp))
                    .scaleEffect(isPlaying ? 0.9 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPlaying)
            }
            .padding()
        }
    }
    
    private func getZIndex(for index: Int) -> Double {
        if index == currentIndex {
            return Double(cards.count + 1)
        }
        if index == movingCardIndex {
            return 0
        }
        return Double(cards.count - getRelativeIndex(for: index))
    }
    
    private func getRelativeIndex(for index: Int) -> Int {
        let relative = index - currentIndex
        return relative < 0 ? relative + cards.count : relative
    }
    
    private func getHorizontalOffset(for index: Int) -> CGFloat {
        let relativeIndex = getRelativeIndex(for: index)
        if index == movingCardIndex {
            return -moveOffset * sin(Double.pi * 0.5) * 15
        }
        return CGFloat(relativeIndex) * stackOffset
    }
    
    private func getRotation(for index: Int) -> Double {
        if index == movingCardIndex {
            return -rotationAngle * 15
        }
        let relativeIndex = getRelativeIndex(for: index)
        return -Double(relativeIndex) * rotationAngle
    }
    
    private func getScale(for index: Int) -> CGFloat {
        let relativeIndex = getRelativeIndex(for: index)
        return 1.0 - (0.1 * CGFloat(abs(relativeIndex)))
    }
    
    private func togglePlayback() {
        isPlaying.toggle()
        
        if isPlaying {
            startAnimation()
        } else {
            stopAnimation()
        }
    }
    
    private func startAnimation() {
        animateNextCard()
        timer = Timer.scheduledTimer(withTimeInterval: animationDuration + pauseBetweenCards, repeats: true) { _ in
            animateNextCard()
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func animateNextCard() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            movingCardIndex = currentIndex
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration * 0.5) {
            withAnimation(.easeInOut(duration: animationDuration * 0.7)) {
                currentIndex = (currentIndex + 1) % cards.count
                movingCardIndex = nil
            }
        }
    }
}

private struct CardView: View {
    let card: CardData
    
    var body: some View {
        ZStack {
            Image("Card")
                .resizable()
                .scaledToFit()
                .padding(.all, 48)
                .shadow(radius: 5)
            CanvasView(mainPaths: card.frontPaths, opacityPaths: [])
        }
    }
}
