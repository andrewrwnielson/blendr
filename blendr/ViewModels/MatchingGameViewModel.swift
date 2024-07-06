//
//  MatchingGameViewModel.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import Foundation
import SwiftUI
import Combine

class MatchingGameViewModel: ObservableObject {
    @Published var gameCards: [GameCard]
    private var indexOfOnlyFaceUpCard: Int?

    static let icons = [
        "apple", "avocado", "bacon", "banana", "BBQ", "BBQOpen", "beer", "beerHandle", "bottle1", "bottle2",
        "bread", "breadFancy1", "breadFancy2", "broccoli", "burger", "cake", "cakeSlice", "candle", "candy",
        "carrot", "cheese", "cheeseSlice", "cherry", "chicken", "chickenLegDark", "chickenLegLight", "cookie",
        "cookies", "croissant", "cupcake", "cupCoffee1", "cupCoffee2", "cupJuice", "cupStraw", "dish", "donut",
        "eggplant", "eggs", "fire", "fish", "fishSkeleton", "forkCarrot", "forkKnife", "frenchFries", "fridge",
        "friedEgg", "grape", "greenDish", "grillCutlery", "hat", "hotdog", "iceCreamCone", "jar", "jelly",
        "knife", "layeredCake", "lemon", "lollipop", "mixer", "mortar", "muffin", "noodles",
        "nuts", "olives", "onion", "orange", "orangeJuice", "pizzaSlice", "pizzaWhole", "popcorn", "popsicle",
        "robe", "rollingPin", "salt", "scale", "shoppingBasket", "shrimp", "skewer", "spoonFork", "spoonKnife",
        "stove", "strawberry", "sundae", "sushi", "taco", "teacup", "teacupPlate", "teacupPouch", "toast",
        "watermelon", "whisk", "wineglass1", "wineglass2", "wineglass3"
    ]

    init() {
        gameCards = []
        setupCards()
    }

    func setupCards() {
        let shuffledIcons = MatchingGameViewModel.icons.shuffled().prefix(8)
        let pairsOfIcons = Array(shuffledIcons + shuffledIcons).shuffled()
        gameCards = pairsOfIcons.map { GameCard(content: $0) }
    }

    func choose(_ card: GameCard) {
        if let chosenIndex = gameCards.firstIndex(where: { $0.id == card.id }),
           !gameCards[chosenIndex].isFaceUp,
           !gameCards[chosenIndex].isMatched {
            if let potentialMatchIndex = indexOfOnlyFaceUpCard {
                gameCards[chosenIndex].isFaceUp = true
                if gameCards[chosenIndex].content == gameCards[potentialMatchIndex].content {
                    gameCards[chosenIndex].isMatched = true
                    gameCards[potentialMatchIndex].isMatched = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.gameCards[chosenIndex].isFaceUp = false
                        self.gameCards[potentialMatchIndex].isFaceUp = false
                    }
                }
                indexOfOnlyFaceUpCard = nil
            } else {
                for index in gameCards.indices {
                    gameCards[index].isFaceUp = false
                }
                gameCards[chosenIndex].isFaceUp = true
                indexOfOnlyFaceUpCard = chosenIndex
            }
        }
    }
    
    func resetGame() {
        gameCards.removeAll()
        setupCards()
    }
}
