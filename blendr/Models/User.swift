//
//  User.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var fullname: String
    var email: String
    var subscription: Int = 0   // trainee
    var swipes: Int = 10
    var profileIcon: String = "chickenLegLight"
    var diets: String = ""
    var allergies: String = ""
    var equipment: [String] = []
    var currCardStack: [Recipe] = []
    var likedRecipes: [Recipe] = []
    var savedRecipes: [Recipe] = []
    var occasion: String = ""
    var ingredients: String = ""
    var preferences: String = ""
    var firstname: String {
        return fullname.components(separatedBy: " ").first ?? ""
    }
    var isFood: Bool = true
    var hideNutrition: Bool?
}


