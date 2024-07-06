//
//  PaywallView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/25/24.
//
// Testing w/o revenue cat

import SwiftUI
import RevenueCat

struct PaywallView: View {
    @ObservedObject var viewModelAuth: AuthViewModel
    @Binding var isPaywallPresented: Bool
    @State private var isMasterSelected = true
    @State private var selectedPackage: Package?
    @State var currentOffering: Offering?
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image("leaf")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
            
            Text("What kind of _**chef**_ are you? Upgrade your plan to unlock _exclusive_ benefits.")
                .font(.system(size: 30))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: 0x002247))
                .frame(width: SizeConstants.cardWidth * 0.8)
                .fixedSize()
            
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundColor(Color(hex: 0x7ec636))
                    Text("Explore gourmet recipes")
                        .foregroundColor(Color(hex: 0x002247))
                }

                HStack {
                    Image(systemName: "leaf")
                        .foregroundColor(Color(hex: 0x7ec636))
                    Text("Personalized dietary plans")
                        .foregroundColor(Color(hex: 0x002247))
                }

                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(Color(hex: 0x7ec636))
                    Text("Save time with quick recipes")
                        .foregroundColor(Color(hex: 0x002247))
                }
            }
            .foregroundColor(Color(hex: 0x002247)) // Default text color
            
            HStack {
                Button {
                    isMasterSelected = false
                    selectedPackage = nil
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(height: 200)
                            .foregroundColor(!isMasterSelected ? Color(hex: 0x002247) : Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: 0x002247), lineWidth: 2)
                            )
                        
                        VStack {
                            Text("_**Sous**_")
                                .font(.title3)
                                .padding(.top)
                            
                            Spacer()
                            
                            Text("**50** swipes")
                                .font(.subheadline)
                            
                            Text("-")
                                .font(.subheadline)
                            
                            Text("Watch ads to earn more")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("Free")
                                .font(.subheadline)
                                .padding(.bottom)
                        }
                        .frame(height: 200)
                        .multilineTextAlignment(.center)
                        .foregroundColor(!isMasterSelected ? Color.white : Color(hex: 0x002247))
                        .padding()
                    }
                    .padding()
                }
                
                Button {
                    isMasterSelected = true
                    selectedPackage = currentOffering!.package(identifier: "blendr_4.99_1m")
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(height: 200)
                            .foregroundColor(isMasterSelected ? Color(hex: 0x002247) : Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: 0x002247), lineWidth: 2)
                            )
                        
                        VStack {
                            Text("_**Master**_")
                                .font(.title3)
                                .padding(.top)
                            
                            Spacer()
                            
                            Text("**Unlimited** swipes")
                                .font(.subheadline)
                            Text("-")
                                .font(.subheadline)
                            Text("Ad free")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("$4.99/mo")
                                .font(.subheadline)
                                .padding(.bottom)
                        }
                        .frame(height: 200)
                        .multilineTextAlignment(.center)
                        .foregroundColor(isMasterSelected ? Color.white : Color(hex: 0x002247))
                        .padding()
                    }
                    .padding()
                }
            }
            .padding(.vertical, 10)
            
            let invalidContinuation = (viewModelAuth.currentUser?.subscription == 1 && isMasterSelected) || (viewModelAuth.currentUser?.subscription == 0 && !isMasterSelected)
            
            Button {
                if !invalidContinuation {
                    if selectedPackage != nil {
                        print("Purchase loading...")
                        
                        Purchases.shared.purchase(package: selectedPackage!) { (transaction, customerInfo, error, userCancelled) in
                            Task {
                                if customerInfo?.entitlements["master"]?.isActive == true {
                                    await viewModelAuth.updateUserSwipes(999999)
                                    await viewModelAuth.updateUserSubscription(1)
                                    print("Purchase successful")
                                } else {
                                    print("Purchase unsuccesful")
                                }
                            }
                        }
                    }
                }
                isPaywallPresented = false
            } label: {
                ZStack {
                    if(invalidContinuation) {
                        Rectangle()
                            .frame(height: 55)
                            .foregroundColor(.gray)
                            .cornerRadius(10)
                        
                        Text("CONTINUE WITH CURRENT PLAN")
                            .foregroundColor(.white)
                            .bold()
                        
                    } else {
                        Rectangle()
                            .frame(height: 55)
                            .foregroundColor(Color(hex: 0x002247))
                            .cornerRadius(10)
                        if isMasterSelected {
                            Text("UPGRADE")
                                .foregroundColor(.white)
                                .bold()
                        } else {
                            Text("CANCEL SUBSCRIPTION")
                                .foregroundColor(.white)
                                .bold()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 15)
        .onAppear {
            Purchases.shared.getOfferings { offerings, error in
                if let offer = offerings?.current, error == nil {
                    currentOffering = offer
                }
            }
        }
    }
}
