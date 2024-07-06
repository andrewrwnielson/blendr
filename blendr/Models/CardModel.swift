//
//  CardModel.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import Foundation

struct CardModel {
    let recipe: Recipe
}

extension CardModel: Identifiable, Hashable {
    var id: UUID { return recipe.id }
}
