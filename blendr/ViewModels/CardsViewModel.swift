//
//  CardsViewModel.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI
import Combine
import Firebase

@MainActor
class CardsViewModel: ObservableObject {
    @Published var cardModels: [CardModel] = []
    @Published var buttonSwipeAction: SwipeAction?
    @Published var isLoading: Bool = false
    @Published var showPaywall: Bool = false

    private var service: CardService
    private var authViewModel: AuthViewModel
    private var cancellables = Set<AnyCancellable>()

    init(service: CardService, authViewModel: AuthViewModel) {
        self.service = service
        self.authViewModel = authViewModel
        self.loadInitialCards()

        authViewModel.$currentUser
            .compactMap { $0?.currCardStack }
            .sink { [weak self] newStack in
                self?.cardModels = newStack.map { CardModel(recipe: $0) }
                print("DEBUG: cardModels updated: \(self?.cardModels.count ?? 0) cards")
            }
            .store(in: &cancellables)
    }

    func loadInitialCards() {
        guard let initialCards = authViewModel.currentUser?.currCardStack else {
            print("DEBUG: No initial cards found.")
            return
        }
        self.cardModels = initialCards.map { CardModel(recipe: $0) }
    }

    func removeCard(_ card: CardModel) {
        guard var currentUser = authViewModel.currentUser else { return }
        
        if currentUser.swipes > 0 {
            currentUser.swipes -= 1
            Task {
                await authViewModel.updateUserSwipes(currentUser.swipes)
            }

            // Remove the card if the user has swipes left
            if let index = cardModels.firstIndex(where: { $0.id == card.id }) {
                cardModels.remove(at: index)
                authViewModel.currentUser?.currCardStack = cardModels.map { $0.recipe }
                updateCardStackInFirestore()
            }

            if cardModels.isEmpty {
                generateRecipesIfNeeded()
            }
        } else {
            // Show the paywall if the user has no swipes left
            showPaywall = true
        }
    }

    func generateRecipesIfNeeded() {
        guard !isLoading else {
            print("DEBUG: Recipes are already being generated.")
            return
        }
        guard let user = authViewModel.currentUser else {
            print("DEBUG: No current user found.")
            return
        }

        print("DEBUG: Starting recipe generation.")
        isLoading = true

        let prompt = createRecipePrompt(
            occasion: user.occasion,
            ingredients: user.ingredients,
            preferences: user.preferences,
            isFood: user.isFood,
            equipment: user.equipment,
            allergies: user.allergies,
            diets: user.diets
        )

        service.generateRecipes(prompt: prompt) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let recipes):
                    print("DEBUG: Recipes generated successfully.")
                    self.authViewModel.updateCurrCardStack(with: recipes)
                    self.cardModels = recipes.map { CardModel(recipe: $0) }
                    self.updateCardStackInFirestore()
                    print("DEBUG: cardModels updated: \(self.cardModels.count) cards")
                case .failure(let error):
                    print("Error generating recipes: \(error.localizedDescription)")
                }
                print("DEBUG: Loading complete")
            }
        }
    }

    private func updateCardStackInFirestore() {
        guard let user = authViewModel.currentUser else { return }
        let docRef = Firestore.firestore().collection("users").document(user.id!)
        do {
            try docRef.setData(from: user)
            print("DEBUG: Card stack updated in Firestore.")
        } catch {
            print("Error updating user: \(error.localizedDescription)")
        }
    }

    func addLikedRecipe(_ recipe: Recipe) {
        guard var currentUser = authViewModel.currentUser else { return }
        currentUser.likedRecipes.append(recipe)
        authViewModel.currentUser = currentUser
        Task {
            await authViewModel.updateLikedRecipesInFirestore()
        }
    }
    
    func generateRecipes(ingredients: String, occasion: String, preferences: String, isFood: Bool, user: User, completion: @escaping (Result<[Recipe], Error>) -> Void) {
        isLoading = true
        
        let prompt = createRecipePrompt(
            occasion: occasion,
            ingredients: ingredients,
            preferences: preferences,
            isFood: isFood,
            equipment: user.equipment,
            allergies: user.allergies,
            diets: user.diets
        )
        
        service.generateRecipes(prompt: prompt) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                completion(result)
            }
        }
    }
}
