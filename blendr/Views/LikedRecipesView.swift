//
//  LikedRecipesView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct LikedRecipesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedRecipe: Recipe?

    var body: some View {
        List {
            ForEach(authViewModel.currentUser?.likedRecipes.prefix(50).reversed() ?? [], id: \.id) { recipe in
                Button(action: {
                    selectedRecipe = recipe
                }) {
                    RecipeRow(recipe: recipe)
                }
            }
            .onDelete(perform: deleteLikedRecipes)
        }
        .onAppear {
            Task {
                await authViewModel.fetchUser()
            }
            authViewModel.limitLikedRecipesTo50MostRecent()
        }
        .fullScreenCover(item: $selectedRecipe) { recipe in
            RecipeDetailView(recipe: recipe)
                .environmentObject(authViewModel)
        }
    }

    private func deleteLikedRecipes(at offsets: IndexSet) {
        guard var currentUser = authViewModel.currentUser else { return }

        // Convert reversed offsets to original indexes
        let originalIndexes = offsets.map { currentUser.likedRecipes.count - 1 - $0 }

        for index in originalIndexes {
            let recipe = currentUser.likedRecipes[index]
            Task {
                await authViewModel.unsaveRecipe(recipe)
            }
            currentUser.likedRecipes.remove(at: index)
        }

        authViewModel.currentUser = currentUser
        Task {
            await authViewModel.updateLikedRecipesInFirestore()
        }
    }
}

struct RecipeRow: View {
    var recipe: Recipe

    var body: some View {
        HStack {
            if recipe.isFood != nil {
                Image(systemName: recipe.isFood! ? "fork.knife" : "wineglass.fill")
                    .foregroundStyle(.gray)
                    .font(.subheadline)
            }
            Text(recipe.name)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(.vertical)
    }
}
