//
//  SavedRecipesView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct SavedRecipesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedRecipe: Recipe?

    var body: some View {
        List {
            ForEach(authViewModel.currentUser?.savedRecipes.reversed() ?? []) { recipe in
                Button(action: {
                    selectedRecipe = recipe
                }) {
                    RecipeRow(recipe: recipe)
                }
            }
        }
        .navigationTitle("Saved Recipes")
        .fullScreenCover(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe)
                .environmentObject(authViewModel)
        }
    }
}
