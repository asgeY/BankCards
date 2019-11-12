//
//  ContentView.swift
//  BankCards
//
//  Created by Fernando Moya de Rivas on 10/11/2019.
//  Copyright © 2019 Fernando Moya de Rivas. All rights reserved.
//

import SwiftUI

struct WalletView: View {
    
    private static let cardTransitionDelay: Double = 0.2
    private static let cardOffset: CGFloat = -20
    private static let cardOpacity: Double = 0.05
    private static let cardShrinkRatio: CGFloat = 0.05
    private static let cardRotationAngle: Double = 30
    private static let cardScaleWhenDragginDown: CGFloat = 1.1
    private static let padding: CGFloat = 20

    var wallet: Wallet = Wallet(cards: cards)
    var draggingOffset: CGFloat = 0
    var isDragging: Bool = false
    var firstCardScale: CGFloat = Self.cardScaleWhenDragginDown
    
    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                ForEach(self.wallet.cards) { card in
                    CardView(card: card)
                        .opacity(self.opacity(for: card))
                        .offset(x: 0,
                                y: self.offset(for: card))
                        .scaleEffect(self.scaleEffect(for: card))
                        .rotation3DEffect(self.rotationAngle(for: card),
                                          axis: (x: 0.5, y: 1, z: 0))
                }
            }.padding(.horizontal, Self.padding)
        }
    }
}

// MARK: Helper functions

extension WalletView {
    
    private func cardsResortedAfterTranslation(draggedCard card: Card, yTranslation: CGFloat, geometry: GeometryProxy) -> [Card] {
        let cardHeight = (geometry.size.width / CGFloat(Card.aspectRatio) - Self.padding)
        if abs(yTranslation + CGFloat(wallet.cards.count) * -Self.cardOffset) > cardHeight {
            let newCards = [card] + Array(wallet.cards.dropLast())
            return newCards
        }
        
        return wallet.cards
    }
    
    private func newFirstCardScale(geometry: GeometryProxy) -> CGFloat {
        if draggingOffset > 0 {
            let newScale = 1 + draggingOffset / (1.5 * geometry.size.height)
            return min(Self.cardScaleWhenDragginDown, newScale)
        } else {
            let newScale = 1 + draggingOffset / (1.5 * geometry.size.height)
            return max(1 - CGFloat(wallet.cards.count) * Self.cardShrinkRatio, newScale)
        }
    }
    
    private func transitionDelay(card: Card) -> Double {
        return Double(wallet.index(of: card)) * Self.cardTransitionDelay
    }
    
    private func opacity(for card: Card) -> Double {
        let cardIndex = Double(wallet.index(of: card))
        return 1 - cardIndex * Self.cardOpacity
    }
    
    private func offset(for card: Card) -> CGFloat {
        guard !wallet.isFirst(card: card) else { return draggingOffset }
        let cardIndex = CGFloat(wallet.index(of: card))
        return cardIndex * Self.cardOffset
    }
    
    private func scaleEffect(for card: Card) -> CGFloat {
        guard !(isDragging && wallet.isFirst(card: card)) else { return firstCardScale }
        let cardIndex = CGFloat(wallet.index(of: card))
        return 1 - cardIndex * Self.cardShrinkRatio
    }
    
    private func rotationAngle(for card: Card) -> Angle {
        guard !wallet.isFirst(card: card) && !isDragging else { return .zero }
        return Angle(degrees: Self.cardRotationAngle)
    }
}

extension AnyTransition {
    static var moveUpWardsWhileFadingIn: AnyTransition {
        return AnyTransition.move(edge: .bottom).combined(with: .opacity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView().environmentObject(Wallet(cards: cards))
    }
}
