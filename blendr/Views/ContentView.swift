//
//  ContentView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI
import RevenueCat

struct ContentView: View {
    @EnvironmentObject var viewModelAuth: AuthViewModel
    @EnvironmentObject var interstitialAdsManager: InterstitialAdsManager
    @State private var isOnboardingCompleted = false
    @State var isActive: Bool = false

    var body: some View {
        ZStack {
            if self.isActive {
                Group {
                    if viewModelAuth.userSession != nil {
                        MainTabView()
                            .fullScreenCover(isPresented: $viewModelAuth.isNewUser) {
                                NewUserOnboardingView(isOnboardingCompleted: $isOnboardingCompleted)
                                    .environmentObject(viewModelAuth)
                            }
                            .environmentObject(interstitialAdsManager)
                            .onAppear {
                                configureRevenueCat()
                            }
                    } else {
                        LoginView()
                    }
                }
            } else {
                Rectangle()
                    .foregroundStyle(.white)
                
                VStack {
                    Image("blendrText")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .padding()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }

    private func configureRevenueCat() {
        if let userID = viewModelAuth.currentUser?.id {
            Purchases.configure(withAPIKey: "appl_ICsAAaeoGHlbcvKgsQIIrRKRAfR", appUserID: userID)
        } else {
            // Handle the case where user is not yet available
            // This might involve waiting for the user object to be fetched or created
            viewModelAuth.$currentUser
                .compactMap { $0?.id }
                .first()
                .sink { userID in
                    Purchases.configure(withAPIKey: "appl_ICsAAaeoGHlbcvKgsQIIrRKRAfR", appUserID: userID)
                }
                .store(in: &viewModelAuth.cancellables)
        }
    }
}
