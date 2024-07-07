//
//  GetSwipesView.swift
//  blendr
//
//  Created by Andrew Nielson on 7/1/24.
//

import SwiftUI
import RevenueCat

struct GetSwipesView: View {
    @EnvironmentObject var rewardedAdsManager: RewardedAdsManager
    @EnvironmentObject var viewModelAuth: AuthViewModel
    @State var packages: [Package]?
    @State private var selectedPackage: Package?
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
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
                .frame(height: 50)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundStyle(Color(hex: 0x002247))
                }
            }
            
            Image("leaf")
                .resizable()
                .scaledToFit()
                .frame(height: UIScreen.main.bounds.height / 10)
            
            Text("Out of swipes? _Get_ more swipes to keep discovering delicious recipes!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.2)
                .foregroundColor(Color(hex: 0x002247))
            
            Spacer()
            Spacer()
            
            Text("Select to purchase swipes")
                .italic()
                .foregroundStyle(.gray)
            
            HStack {
                Button {
                    for package in packages! {
                        if package.identifier == "swipes-80" {
                            self.selectedPackage = package
                        }
                    }
                    Purchases.shared.purchase(package: selectedPackage!) { (transaction, customerInfo, error, userCancelled) in
                        Task {
                            if let customerInfo, error == nil {
                                await viewModelAuth.updateUserSwipes(viewModelAuth.currentUser!.swipes + 80)
                            }
                        }
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(height: UIScreen.main.bounds.height / 5)
                            .foregroundColor(Color(hex: 0x002247))
                            .cornerRadius(10)
                        
                        VStack {
                            Text("_**Quick\nTaste**_")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .lineLimit(2) // Ensures text does not exceed two lines
                                .minimumScaleFactor(0.6)
                                .padding(.top)
                            
                            Spacer()
                            
                            Text("**80**\nswipes")
                                .font(.subheadline)
                                .lineLimit(2)
                                .minimumScaleFactor(0.6)
                            
                            Spacer()
                            
                            Text("$0.99")
                                .font(.subheadline)
                                .padding(.bottom)
                                .minimumScaleFactor(0.6)
                        }
                        .frame(height: UIScreen.main.bounds.height / 5)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.white)
                        .padding()
                    }
                }
                
                Button {
                    for package in packages! {
                        if package.identifier == "swipes-200" {
                            self.selectedPackage = package
                        }
                    }
                    Purchases.shared.purchase(package: selectedPackage!) { (transaction, customerInfo, error, userCancelled) in
                        Task {
                            if let customerInfo, error == nil {
                                await viewModelAuth.updateUserSwipes(viewModelAuth.currentUser!.swipes + 200)
                            }
                        }
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(height: UIScreen.main.bounds.height / 5)
                            .foregroundColor(Color(hex: 0x002247))
                            .cornerRadius(10)
                        
                        VStack {
                            Text("_**Flavor\nPack**_")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .lineLimit(2) // Ensures text does not exceed two lines
                                .minimumScaleFactor(0.6)
                                .padding(.top)
                            
                            Spacer()
                            
                            Text("**200**\nswipes")
                                .font(.subheadline)
                                .lineLimit(2)
                                .minimumScaleFactor(0.6)
                            
                            Spacer()
                            
                            Text("$1.99")
                                .font(.subheadline)
                                .padding(.bottom)
                                .minimumScaleFactor(0.6)
                        }
                        .frame(height: UIScreen.main.bounds.height / 5)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                    }
                }
                
                Button {
                    for package in packages! {
                        if package.identifier == "swipes-500" {
                            self.selectedPackage = package
                        }
                    }
                    Purchases.shared.purchase(package: selectedPackage!) { (transaction, customerInfo, error, userCancelled) in
                        Task {
                            if let customerInfo, error == nil {
                                await viewModelAuth.updateUserSwipes(viewModelAuth.currentUser!.swipes + 500)
                            }
                        }
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(height: UIScreen.main.bounds.height / 5)
                            .foregroundColor(Color(hex: 0x002247))
                            .cornerRadius(10)
                        
                        VStack {
                            Text("_**Gourmet\nFeast**_")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .lineLimit(2) // Ensures text does not exceed two lines
                                .minimumScaleFactor(0.6) // Adjusts font size to a minimum of 60% if needed
                                .padding(.top)
                            
                            Spacer()
                            
                            Text("**500**\nswipes")
                                .font(.subheadline)
                                .lineLimit(2)
                                .minimumScaleFactor(0.6)
                            
                            Spacer()
                            
                            Text("$3.99")
                                .font(.subheadline)
                                .padding(.bottom)
                                .minimumScaleFactor(0.6)
                        }
                        .frame(height: UIScreen.main.bounds.height / 5)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                    }
                }
            }
            
            Text("OR")
                .italic()
                .foregroundStyle(.gray)
            
            Button {
                rewardedAdsManager.displayrewardedAd()
                Task {
                    await viewModelAuth.updateUserSwipes(viewModelAuth.currentUser!.swipes + 10)
                }
            } label: {
                ZStack {
                    Rectangle()
                        .frame(height: UIScreen.main.bounds.height / 16)
                        .foregroundColor(Color(hex: 0x002247))
                        .cornerRadius(10)
                    
                    if rewardedAdsManager.rewardedAdLoaded {
                        Text("WATCH AN AD TO EARN 10 SWIPES")
                            .foregroundColor(.white)
                            .bold()
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
            }
            .padding(.vertical)
        }
        .padding(.horizontal, 10)
        .foregroundStyle(Color(hex: 0x002247))
        .onAppear {
            rewardedAdsManager.loadRewardedAd()
            loadPackages()
        }
    }
    
    private func loadPackages() {
        Purchases.shared.getOfferings { (offerings, error) in
            if let offerings = offerings, let offering = offerings.current {
                self.packages = offering.availablePackages
            }
        }
    }
}
