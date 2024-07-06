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
    
    @StateObject var viewModel = CardsViewModel(service: CardService(apiToken: "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"), authViewModel: AuthViewModel())
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var interstitialAdsManager: InterstitialAdsManager
    
    var body: some View {
        GeometryReader { geometry in
            if !isInputPresented && !isGetSwipesPresented {
                VStack {
                    HStack {
                        VStack {
                            Button {
                                isGetSwipesPresented = true
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
                            
                            Spacer()
                        }
                        
                        Image("blendrNoText")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width / 1.2 - 140)
                        
                        VStack {
                            Button {
                                isCardStackPresented = true
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
                                    .frame(width: geometry.size.width / 4 + 15)
                                    .foregroundStyle(Color(hex: 0x002247))
                                
                                Circle()
                                    .frame(width: geometry.size.width / 4)
                                    .foregroundStyle(.white)
                                
                                Button(action: {
                                    isFood = true
                                    isInputPresented = true
                                }) {
                                    Image(systemName: "fork.knife.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: geometry.size.width / 4 - 15)
                                        .foregroundStyle(Color(hex: 0x002247))
                                }
                            }
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .frame(width: geometry.size.width / 4 + 15)
                                    .foregroundStyle(Color(hex: 0x002247))
                                
                                Circle()
                                    .frame(width: geometry.size.width / 4)
                                    .foregroundStyle(.white)
                                
                                Button(action: {
                                    isFood = false
                                    isInputPresented = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .frame(height: geometry.size.width / 4 - 15)
                                            .foregroundStyle(Color(hex: 0x002247))
                                        Image(systemName: "wineglass.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: geometry.size.width / 4 - 40)
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
                .fullScreenCover(isPresented: $isCardStackPresented) {
                    CardStackView(service: CardService(apiToken: "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"), authViewModel: authViewModel)
                        .environmentObject(authViewModel)
                }
            }
            if isInputPresented {
                InputView(isCardStackPresented: $isCardStackPresented, isPresented: $isInputPresented, isFood: $isFood, viewModel: viewModel)
                    .environmentObject(authViewModel)
                    .transition(.push(from: .bottom))
                    .onAppear() {
                        interstitialAdsManager.loadInterstitialAd()
                    }
            }
            if isGetSwipesPresented {
                GetSwipesView(isPresented: $isGetSwipesPresented)
            }
        }
    }
}
