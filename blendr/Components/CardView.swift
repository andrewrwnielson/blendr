//
//  CardView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct CardView: View {
    @ObservedObject var viewModel: CardsViewModel
    @EnvironmentObject var viewModelAuth: AuthViewModel
    
    @State private var xOffset: CGFloat = 0
    @State private var degrees: Double = 0
    @State private var showRecipeSheet = false
    @State private var isPaywallPresented = false
    
    let model: CardModel
    
    var body: some View {
        ZStack {
            Rectangle()
            RecipeInfoView(showRecipeSheet: $showRecipeSheet, recipe: recipe, hideNutrition: viewModelAuth.currentUser?.hideNutrition ?? false)
            
            if isPaywallPresented {
                Rectangle()
                    .opacity(0.9)
                    .foregroundStyle(Color(hex: 0x002247))
                
                VStack {
                    Text("Out of swipes!\n\nBuy more or watch an ad in the store.")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $showRecipeSheet) {
            RecipeSheetView(recipe: recipe, hideNutrition: viewModelAuth.currentUser?.hideNutrition ?? false)
        }
        .onReceive(viewModel.$buttonSwipeAction, perform: { action in
            onReceiveSwipeAction(action)
        })
        .foregroundStyle(.gray)
        .frame(width: SizeConstants.cardWidth, height: SizeConstants.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .offset(x: xOffset)
        .rotationEffect(.degrees(degrees))
        .animation(.snappy, value: xOffset)
        .gesture(
            DragGesture()
                .onChanged(onDragChanged)
                .onEnded(onDragEnded)
        )
    }
}

private extension CardView {
    var recipe: Recipe {
        return model.recipe
    }
    
    func returnToCenter() {
        xOffset = 0
        degrees = 0
    }
    
    func swipeRight() {
        withAnimation {
            xOffset = 500
            degrees = 12
        } completion: {
            handleSwipe()
            // Add to liked recipes
            if !isPaywallPresented {
                viewModel.addLikedRecipe(recipe)
            }
        }
    }
    
    func swipeLeft() {
        withAnimation {
            xOffset = -500
            degrees = -12
        } completion: {
            handleSwipe()
            // Discard recipe
        }
    }
    
    func handleSwipe() {
        viewModel.removeCard(model)
        if viewModel.showPaywall {
            returnToCenter()
            isPaywallPresented = true
        }
    }
    
    func onReceiveSwipeAction(_ action: SwipeAction?) {
        guard let action else { return }
        
        let topCard = viewModel.cardModels.last
        
        if topCard == model {
            switch action {
            case .trash:
                swipeLeft()
            case .like:
                swipeRight()
            }
        }
    }

    func onDragChanged(_ value: _ChangedGesture<DragGesture>.Value) {
        xOffset = value.translation.width
        degrees = Double(value.translation.width / 25)
    }
    
    func onDragEnded(_ value: _ChangedGesture<DragGesture>.Value) {
        let width = value.translation.width
        
        if abs(width) <= abs(SizeConstants.screenCutoff) {
            returnToCenter()
            return
        }
        
        if width >= SizeConstants.screenCutoff {
            swipeRight()
        } else {
            swipeLeft()
        }
    }
}
