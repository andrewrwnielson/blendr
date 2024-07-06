//
//  Recipe.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import Foundation

struct Recipe: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var prepTime: Int
    var cookTime: Int
    var description: String
    var ingredients: [String]
    var cuisine: String
    var calories: Int
    var protein: Int
    var sugar: Int
    var carbs: Int
    var fat: Int
    var sodium: Int
    var steps: [String]?
    var isFood: Bool?
}

extension Recipe {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case prepTime
        case cookTime
        case description
        case ingredients
        case cuisine
        case calories
        case protein
        case sugar
        case carbs
        case fat
        case sodium
        case steps
        case isFood
    }
}
