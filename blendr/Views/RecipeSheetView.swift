//
//  RecipeSheetView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct RecipeSheetView: View {
    @Environment(\.dismiss) var dismiss
    let recipe: Recipe
    var hideNutrition: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(recipe.name)
                    .font(.system(size: 35))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color(hex: 0x002247))
                
                Spacer()
                
                Button{
                    dismiss()
                } label:{
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(Color(hex: 0x002247))
                        .fontWeight(.bold)
                        .imageScale(.large)
                        .font(.system(size: 30))
                }
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
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("COOK")
                                .foregroundStyle(Color(hex: 0x002247))
                                .fontWeight(.bold)
                            Text(formatTime(recipe.cookTime))
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("TOTAL")
                                .foregroundStyle(Color(hex: 0x002247))
                                .fontWeight(.bold)
                            Text(formatTime(recipe.cookTime + recipe.prepTime))
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
                    
                    if !hideNutrition {
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
