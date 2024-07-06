//
//  IconSelectionView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct IconSelectionView: View {
    @EnvironmentObject var viewModelAuth: AuthViewModel
    @Binding var isShowingPreferences: Bool
    @State private var selectedIcon: String?
    
    let icons = [
            "apple", "avocado", "bacon", "banana", "BBQ", "BBQOpen", "beer", "beerHandle", "bottle1", "bottle2",
            "bread", "breadFancy1", "breadFancy2", "broccoli", "burger", "cake", "cakeSlice", "candle", "candy",
            "carrot", "cheese", "cheeseSlice", "cherry", "chicken", "chickenLegDark", "chickenLegLight", "cookie",
            "cookies", "croissant", "cupcake", "cupCoffee1", "cupCoffee2", "cupJuice", "cupStraw", "dish", "donut",
            "eggplant", "eggs", "fire", "fish", "fishSkeleton", "forkCarrot", "forkKnife", "frenchFries", "fridge",
            "friedEgg", "grape", "greenDish", "grillCutlery", "hat", "hotdog", "iceCreamCone", "jar", "jelly",
            "juiceOrange", "knife", "layeredCake", "lemon", "lollipop", "mixer", "mortar", "muffin", "noodles",
            "nuts", "olives", "onion", "orange", "orangeJuice", "pizzaSlice", "pizzaWhole", "popcorn", "popsicle",
            "robe", "rollingPin", "salt", "scale", "shoppingBasket", "shrimp", "skewer", "spoonFork", "spoonKnife",
            "stove", "strawberry", "sundae", "sushi", "taco", "teacup", "teacupPlate", "teacupPouch", "toast",
            "watermelon", "whisk", "wineglass1", "wineglass2", "wineglass3"
        ]

    var body: some View {
        NavigationView {
            VStack {
                Text("Select Your Icon")
                    .font(.largeTitle)
                    .padding()
                    .foregroundStyle(Color(hex: 0x002247))

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                            }) {
                                Image(icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .padding()
                                    .background(selectedIcon == icon ? Color(hex: 0x002247).opacity(0.3) : Color.clear)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(selectedIcon == icon ? Color(hex: 0x002247) : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
                .padding()

                Button(action: {
                    if let selectedIcon = selectedIcon {
                        viewModelAuth.updateProfileIcon(selectedIcon)
                        isShowingPreferences = true
                    }
                }) {
                    Text("Save")
                        .font(.title)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: 0x002247))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(selectedIcon == nil)
            }
        }
    }
}
