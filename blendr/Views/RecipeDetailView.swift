//
//  RecipeDetailView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI
import Firebase
import FirebaseFirestoreInternal

struct RecipeDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var recipe: Recipe
    @State private var isLoading = false
    @State private var errorMessage: String?
    @EnvironmentObject var authViewModel: AuthViewModel

    init(recipe: Recipe) {
        _recipe = State(initialValue: recipe)
    }

    var body: some View {
        if isLoading {
            VStack {
                Spacer()
                ProgressView("Generating steps...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        } else {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button {
                        Task {
                            if authViewModel.isRecipeSaved(recipe) {
                                await authViewModel.unsaveRecipe(recipe)
                            } else {
                                await authViewModel.saveRecipe(recipe)
                            }
                        }
                    } label: {
                        Image(systemName: authViewModel.isRecipeSaved(recipe) ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(authViewModel.isRecipeSaved(recipe) ? Color.yellow : Color.gray)
                            .imageScale(.large)
                            .font(.system(size: 30))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Dismiss the view
                    }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(Color(hex: 0x002247))
                            .imageScale(.large)
                            .font(.system(size: 30))
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Text(recipe.name)
                        .font(.system(size: 40))
                        .fontWeight(.heavy)
                        .foregroundStyle(Color(hex: 0x002247))
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack {
                        HStack(spacing: 12) {
                            
                            Spacer()
                            
                            VStack {
                                Text("PREP")
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .fontWeight(.bold)
                                Text(formatTime(recipe.prepTime))
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("COOK")
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .fontWeight(.bold)
                                Text(formatTime(recipe.cookTime) )
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("TOTAL")
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .fontWeight(.bold)
                                Text(formatTime(recipe.cookTime + recipe.prepTime))
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .font(.subheadline)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description:")
                                .foregroundStyle(Color(hex: 0x002247))
                                .fontWeight(.bold)
                            
                            Text(recipe.description)
                                .foregroundStyle(Color(hex: 0x002247))
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .font(.subheadline)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ingredients:")
                                .foregroundStyle(Color(hex: 0x002247))
                                .fontWeight(.bold)
                            
                            ForEach(recipe.ingredients, id: \.self) { ingredient in
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .imageScale(.small)
                                        .foregroundStyle(.gray)
                                    
                                    Text(ingredient)
                                        .foregroundStyle(Color(hex: 0x002247))
                                        .font(.subheadline)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .font(.subheadline)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Steps:")
                                .foregroundStyle(Color(hex: 0x002247))
                                .fontWeight(.bold)
                            
                            if let steps = recipe.steps, steps.isEmpty {
                                Text("Steps not available")
                                    .font(.headline)
                                    .padding(.top, 10)
                            } else if let steps = recipe.steps {
                                ForEach(steps, id: \.self) { step in
                                    Text(step)
                                        .foregroundStyle(Color(hex: 0x002247))
                                        .font(.subheadline)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .font(.subheadline)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        if !(authViewModel.currentUser!.hideNutrition ?? false) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("*Nutrition:")
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .fontWeight(.bold)
                                Text("**Calories:** \(recipe.calories) Cal")
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .font(.subheadline)
                                Text("**Protein:** \(recipe.protein)g")
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .font(.subheadline)
                                Text("**Fat:** \(recipe.fat)g")
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .font(.subheadline)
                                Text("**Sugar:** \(recipe.sugar)g")
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .font(.subheadline)
                                Text("**Carbs:** \(recipe.carbs)g")
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .font(.subheadline)
                                Text("**Sodium:** \(recipe.sodium)mg")
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .font(.subheadline)
                                Text("* These values are approximate and can vary based on the specific ingredients and preparation methods used. ")
                                    .foregroundStyle(.gray)
                                    .font(.footnote)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .font(.subheadline)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear {
                if recipe.steps == nil || recipe.steps?.isEmpty == true {
                    fetchStepsForRecipe()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func fetchStepsForRecipe() {
        isLoading = true
        errorMessage = nil
        let prompt = createRecipeStepsPrompt(recipe: recipe, equipment: authViewModel.currentUser!.equipment)
        CardService(apiToken: "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").generateRecipeSteps(prompt: prompt) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let steps):
                    self.recipe.steps = steps
                    updateStepsInFirestore(steps: steps)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func updateStepsInFirestore(steps: [String]) {
        guard let user = Auth.auth().currentUser else { return }
        let recipeId = recipe.id.uuidString
        let docRef = Firestore.firestore().collection("users").document(user.uid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var likedRecipes = document.get("likedRecipes") as? [[String: Any]] ?? []
                if let index = likedRecipes.firstIndex(where: { $0["id"] as? String == recipeId }) {
                    likedRecipes[index]["steps"] = steps
                    self.recipe.steps = steps // Update local state after Firestore update
                    authViewModel.updateRecipeSteps(recipeId: recipe.id, steps: steps) // Update local state in the view model
                } else {
                    likedRecipes.append([
                        "id": recipeId,
                        "steps": steps
                    ])
                }
                docRef.updateData(["likedRecipes": likedRecipes]) { error in
                    if let error = error {
                        print("Error updating steps in Firestore: \(error.localizedDescription)")
                    } else {
                        print("Steps successfully updated in Firestore.")
                    }
                }
            } else {
                print("Document does not exist or error occurred: \(String(describing: error))")
            }
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours) hr \(mins) min"
        } else {
            return "\(mins) min"
        }
    }
}
