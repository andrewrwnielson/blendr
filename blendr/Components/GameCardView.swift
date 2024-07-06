//
//  GameCardView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct GameCardView: View {
    var gameCard: GameCard
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if gameCard.isFaceUp || gameCard.isMatched {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(gameCard.isMatched ? Color.yellow : Color(hex: 0x002247), lineWidth: 2))
                    Image(gameCard.content)
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: 0x002247))
                }
            }
            .aspectRatio(2/3, contentMode: .fit)
            .padding(5)
        }
        .disabled(gameCard.isMatched) // Disable button if the card is already matched
    }
}
