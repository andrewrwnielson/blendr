//
//  GameCard.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct GameCard: Identifiable, Equatable {
    var id = UUID()
    var content: String
    var isFaceUp = false
    var isMatched = false
}
