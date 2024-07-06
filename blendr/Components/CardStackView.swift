//
//  CardStackView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct CardStackView: View {
    @EnvironmentObject var viewModelAuth: AuthViewModel
    @StateObject private var viewModel: CardsViewModel
    @Environment(\.presentationMode) var presentationMode // Add this to manage the dismissal

    init(service: CardService, authViewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: CardsViewModel(service: service, authViewModel: authViewModel))
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                let swipes = viewModelAuth.currentUser!.swipes
                VStack(alignment: .center, spacing: 0) {
                    Text("\(swipes > 100000 ? "Unlimited" : "\(swipes)")")
                        .foregroundStyle(Color(hex: 0x002247))
                        .bold()
                    Text("swipes")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
                .padding(.leading)
                .frame(height: 50)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Dismiss the full-screen cover
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundStyle(Color(hex: 0x002247))
                }
                .padding(.trailing)
            }
            .overlay(
                Image("blendrText")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150)
                    .padding(.top, 25)
            )
            if viewModel.isLoading {
                GeneratingRecipesView()
            } else {
                NavigationStack {
                    VStack(spacing: 20) {
                        ZStack {
                            ForEach(viewModel.cardModels) { card in
                                CardView(viewModel: viewModel, model: card)
                            }
                        }

                        if !viewModel.cardModels.isEmpty {
                            SwipeActionButtonsView(viewModel: viewModel)
                        }
                    }
                    .onAppear {
                        print("DEBUG: CardStackView onAppear called.")
                        viewModel.loadInitialCards()
                    }
                }
            }
        }
        .onChange(of: viewModel.isLoading) { isLoading in
            if !isLoading && viewModel.cardModels.isEmpty {
                viewModel.generateRecipesIfNeeded()
            }
        }
    }
}
