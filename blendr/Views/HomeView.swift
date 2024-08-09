//
//  HomeView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/27/24.
//

import SwiftUI

struct HomeView: View {
    @State private var isCardStackPresented = false
    @State private var isInputPresented = false
    @State private var isGetSwipesPresented = false
    @State private var isFood = true
    
    @StateObject var viewModel = CardsViewModel(service: CardService(apiToken: Config.openAIKey), authViewModel: AuthViewModel())
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var interstitialAdsManager: InterstitialAdsManager
    
    let storeTip = StoreTip()
    let cardStackTip = CardStackTip()
    
    var body: some View {
        if !isInputPresented && !isGetSwipesPresented {
            VStack {
                HStack {
                    VStack {
                        Button {
                            withAnimation {
                                isGetSwipesPresented = true
                            }
                            storeTip.invalidate(reason: .actionPerformed)
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .cornerRadius(10)
                                VStack {
                                    Image(systemName: "cart.fill")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .popoverTip(storeTip)
                        
                        Spacer()
                    }
                    
                    Image("blendrNoText")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width / 1.2 - 140)
                    
                    VStack {
                        Button {
                            isCardStackPresented = true
                            cardStackTip.invalidate(reason: .actionPerformed)
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .foregroundStyle(Color(hex: 0x002247))
                                    .cornerRadius(10)
                                VStack {
                                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled.fill")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .popoverTip(cardStackTip)
                        
                        Spacer()
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
                
                Spacer()
                
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(height: 50)
                            .foregroundStyle(Color(hex: 0x002247))
                            .cornerRadius(10)
                        
                        Text("What would you like to make?")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 30)
                    
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .frame(width: UIScreen.main.bounds.width / 4 + 15)
                                .foregroundStyle(Color(hex: 0x002247))
                            
                            Circle()
                                .frame(width: UIScreen.main.bounds.width / 4)
                                .foregroundStyle(.white)
                            
                            Button(action: {
                                isFood = true
                                withAnimation {
                                    isInputPresented = true
                                }
                            }) {
                                Image(systemName: "fork.knife.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: UIScreen.main.bounds.width / 4 - 15)
                                    .foregroundStyle(Color(hex: 0x002247))
                            }
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .frame(width: UIScreen.main.bounds.width / 4 + 15)
                                .foregroundStyle(Color(hex: 0x002247))
                            
                            Circle()
                                .frame(width: UIScreen.main.bounds.width / 4)
                                .foregroundStyle(.white)
                            
                            Button(action: {
                                isFood = false
                                withAnimation {
                                    isInputPresented = true
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .frame(height: UIScreen.main.bounds.width / 4 - 15)
                                        .foregroundStyle(Color(hex: 0x002247))
                                    Image(systemName: "wineglass.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: UIScreen.main.bounds.width / 4 - 40)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                Spacer()
                Spacer()
            }
            .onAppear() {
                Task { await StoreTip.homeViewVisitedEvent.donate() }
            }
            .fullScreenCover(isPresented: $isCardStackPresented) {
                CardStackView(service: CardService(apiToken: Config.openAIKey), authViewModel: authViewModel)
                    .environmentObject(authViewModel)
                    .onDisappear() {
                        Task { await CardStackTip.recipesGeneratedEvent.donate() }
                    }
            }
        }
        if isInputPresented {
            InputView(isCardStackPresented: $isCardStackPresented, isPresented: $isInputPresented, isFood: $isFood, viewModel: viewModel)
                .environmentObject(authViewModel)
                .transition(.blurReplace)
                .onAppear() {
                    interstitialAdsManager.loadInterstitialAd()
                }
        }
        if isGetSwipesPresented {
            GetSwipesView(isPresented: $isGetSwipesPresented)
                .transition(.blurReplace)
        }
    }
}
