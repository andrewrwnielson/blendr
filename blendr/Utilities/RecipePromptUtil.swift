//
//  RecipePromptUtil.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import Foundation

func createRecipePrompt(occasion: String, ingredients: String, preferences: String, isFood: Bool, equipment: [String], allergies: String, diets: String) -> String {
    let recipeType = isFood ? "\(preferences) dishes (these are loose preferences, do not combine weird ingredients)" : "\(preferences) drink recipes"
    
    // Convert equipment array to a comma-separated string
    let equipmentString = equipment.joined(separator: ", ")
    
    // Create a string for diet restrictions
    var dietRestrictions = ""
    if !diets.isEmpty {
        if diets.lowercased().contains("vegetarian") {
            dietRestrictions += "Ensure all recipes are vegetarian and do not include any meat, poultry, or fish. "
        }
        
        if diets.lowercased().contains("vegetarian") {
            dietRestrictions += "Ensure all recipes are pescetarian and do not include any meat, excluding fish. "
        }
        
        if diets.lowercased().contains("vegan") {
            dietRestrictions += "Ensure all recipes are vegan and do not include any animal products like meat, dairy, or eggs. "
        }
        
        if diets.lowercased().contains("lactose") {
            dietRestrictions += "Ensure all recipes are lactose-free and do not include any dairy products. "
        }
        
        if diets.lowercased().contains("gluten") {
            dietRestrictions += "Ensure all recipes are gluten-free and do not include any products containing gluten. "
        }
        
        if diets.lowercased().contains("kosher") {
            dietRestrictions += "Ensure all recipes adhere to kosher dietary laws. "
        }
        
        if diets.lowercased().contains("keto") {
            dietRestrictions += "Ensure all recipes are keto-friendly, low in carbs, and high in fats. "
        }
        
        if diets.lowercased().contains("diabetic") {
            dietRestrictions += "Ensure all recipes are suitable for diabetics, low in sugar and carbs. "
        }
        
        if diets.lowercased().contains("dairy free") {
            dietRestrictions += "Ensure all recipes are dairy-free and do not include any dairy products. "
        }
        
        if diets.lowercased().contains("low carb") {
            dietRestrictions += "Ensure all recipes are low in carbohydrates. "
        }
        
        if diets.lowercased().contains("halal") {
            dietRestrictions += "Ensure all recipes adhere to halal dietary laws. "
        }
    }
    
    let recipeCount = 10

    // Construct the prompt
    let prompts = [
        "Create EXACTLY \(recipeCount) unique and exciting \(recipeType) for \(occasion) utilizing a mix of \(ingredients).",
        "Generate EXACTLY \(recipeCount) diverse and flavorful \(recipeType) for \(occasion) using a selection of \(ingredients).",
        "Provide EXACTLY \(recipeCount) distinct and innovative \(recipeType) for \(occasion) featuring ingredients like \(ingredients).",
        "Craft EXACTLY \(recipeCount) different and delectable \(recipeType) for \(occasion) with the ingredients \(ingredients).",
        "Produce EXACTLY \(recipeCount) varied and delightful \(recipeType) for \(occasion) that include \(ingredients)."
    ]
    
    var prompt = prompts.randomElement()!
    
    if !allergies.isEmpty {
        prompt += "Please avoid using ingredients that cause allergies such as \(allergies)."
    }
    
    if !diets.isEmpty {
        prompt += "Adhere to dietary preferences like \(diets). \(dietRestrictions)"
    }
    
    if !ingredients.isEmpty {
        prompt += "ONLY use the ingredients provided!!! Do not add additional ingredients"
    }
    
    return """
    \(prompt)
    The output must be in JSON format with the following structure. Do not use the ` character. All numbers must be whole integers:
    {
        recipes: [
            {
                "id": "UUID", // MUST BE UUID FORMAT IN 8-4-4-4-12 FORMAT
                "name": "Recipe Name",
                "prepTime": 10,
                "cookTime": 20,
                "description": "Description of the recipe",
                "ingredients": ["1 cup of Ingredient 1", "2 Ingredient 2", ...], // MAKE SURE TO SHOW AMOUNT IF RELEVANT
                "cuisine": "Cuisine Type",
                "calories": 500,
                "protein": 20,
                "sugar": 10,
                "carbs": 60,
                "fat": 15,
                "sodium": 500,
                "isFood": true // If food then true else false
            },
            ...
        ]
    }
    make sure that if this recipe uses any equipment then it is in this list \(equipmentString)
    """
}



func createRecipeStepsPrompt(recipe: Recipe, equipment: [String]) -> String {
    let equipmentString = equipment.joined(separator: ", ")
    
    return """
    Generate step-by-step instructions for the following recipe. Assume all ingredients are raw. Only use the provided equipment: \(equipmentString). If something has to be preheated, have it be the first step, else skip that step:
    {
        "name": "\(recipe.name)",
        "prepTime": \(recipe.prepTime),
        "cookTime": \(recipe.cookTime),
        "description": "\(recipe.description)",
        "ingredients": \(recipe.ingredients),
        "cuisine": "\(recipe.cuisine)",
        "calories": \(recipe.calories),
        "protein": \(recipe.protein),
        "sugar": \(recipe.sugar)",
        "carbs": \(recipe.carbs),
        "fat": \(recipe.fat),
        "sodium": \(recipe.sodium)
    }
    The output must be in JSON format with the following structure:
    {
        "steps": [
            "1: step 1......",
            "2: step 2.....",
            ...
        ]
    }
    """
}
