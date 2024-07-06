//
//  MatchingGameView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI
import ConfettiSwiftUI

struct MatchingGameView: View {
    @ObservedObject var viewModel: MatchingGameViewModel
    @State private var counter: Int = 0

    var body: some View {
        VStack {
            Text("Can you match the cards before your recipes are ready?")
                .font(.largeTitle)
                .foregroundStyle(Color(hex: 0x002247))
                .italic()
                .bold()

            GridView(viewModel.gameCards) { card in
                GameCardView(gameCard: card) {
                    viewModel.choose(card)
                    if viewModel.gameCards.allSatisfy({ $0.isMatched }) {
                        counter += 1
                    }
                }
            }
            .confettiCannon(counter: $counter, num: 100, rainHeight: 1000, radius: 300)

            Button(action: {
                viewModel.resetGame()
            }) {
                Text("Play Again!")
                    .font(.subheadline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: 0x002247))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}

#Preview {
    MatchingGameView(viewModel: MatchingGameViewModel())
}
