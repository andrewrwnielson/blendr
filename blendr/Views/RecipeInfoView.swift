//
//  RecipeInfoView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct RecipeInfoView: View {
    @Binding var showRecipeSheet: Bool
    let recipe: Recipe
    var hideNutrition: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack {
                    Text(recipe.name)
                        .font(.system(size: 35))
                        .fontWeight(.heavy)
                    
                    Spacer()
                    
                    Button {
                        showRecipeSheet.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .fontWeight(.bold)
                            .imageScale(.large)
                            .font(.system(size: 30))
                    }
                }
                
                Rectangle()
                    .frame(height: 2)
                    .padding(.bottom)
                
                if !hideNutrition {
                    Text("\(recipe.calories) Cal     \(recipe.protein)g Protein     \(recipe.fat)g Fat")
                }
            }
            
            Spacer()
            
            Text("**Prep Time:** \(formatTime(recipe.prepTime))")
                .font(.system(size: 30))
                .padding(.bottom, 5)
            
            Text("**Cook Time:** \(formatTime(recipe.cookTime))")
                .font(.system(size: 30))
                .padding(.bottom, 5)
            
            Text("**Total Time:** \(formatTime(recipe.cookTime + recipe.prepTime))")
                .font(.system(size: 30))
            
            Spacer()
            
            Text("Description:")
                .font(.system(size: 30))
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .padding(.bottom, 5)
            
            Text(recipe.description)
                .font(.system(size: 20))
                .font(.subheadline)
                .lineLimit(3)
        }
        .foregroundStyle(.white)
        .padding()
        .background(
            LinearGradient(colors: [.clear, Color(hex: 0x002247)], startPoint: .bottom, endPoint: .top)
        )
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
