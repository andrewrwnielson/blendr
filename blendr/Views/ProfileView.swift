//
//  ProfileView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModelAuth: AuthViewModel
    @State private var showingReauthenticateView = false
    @State private var showingTOSView = false
    @State private var showingPPView = false
    @State private var showingADEView = false
    @EnvironmentObject var rewardedAdsManager: RewardedAdsManager
    
    private var hideNutritionBinding: Binding<Bool> {
        Binding<Bool>(
            get: {
                self.viewModelAuth.currentUser?.hideNutrition ?? false
            },
            set: { newValue in
                self.viewModelAuth.currentUser?.hideNutrition = newValue
                Task {
                    await self.viewModelAuth.updateHideNutrition(newValue)
                }
            }
        )
    }
    
    var body: some View {
        if let user = viewModelAuth.currentUser {
            NavigationView {
                List {
                    ProfileHeaderView(user: user)
                        .environmentObject(viewModelAuth)
                    
                    Section("Account Information") {
                        HStack {
                            Text("Name")
                            
                            Spacer()
                            
                            Text(user.fullname)
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        
                        HStack {
                            Text("Email")
                            
                            Spacer()
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    Section("Preferences") {
                        Toggle("Hide Nutritional Information", isOn: hideNutritionBinding)
                        
                        HStack {
                            Button("Allergies, Diets, Equipment") {
                                showingADEView = true
                            }
                            .sheet(isPresented: $showingADEView) {
                                VStack(spacing: 0) {
                                    HStack {
                                        Spacer()
                                        
                                        Button {
                                            showingADEView = false
                                        } label:{
                                            Image(systemName: "arrow.down.circle.fill")
                                                .foregroundStyle(Color(hex: 0x002247))
                                                .fontWeight(.bold)
                                                .imageScale(.large)
                                                .font(.system(size: 20))
                                        }
                                        .padding()
                                    }
                                    
                                    PreferencesView()
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.up")
                                .foregroundStyle(Color(.systemGray2))
                                .font(.subheadline)
                        }
                    }
                    
//                    Section("Purchasing") {
                        //                        TODO: Subscription service
                        //                        HStack {
                        //                            Text("Plan")
                        //
                        //                            Spacer()
                        //
                        //                            if user.subscription == 0 {
                        //                                Text("Trainee")
                        //                                    .font(.subheadline)
                        //                                    .foregroundStyle(.gray)
                        //                            } else if user.subscription == 1 {
                        //                                Text("Sous")
                        //                                    .font(.subheadline)
                        //                                    .foregroundStyle(.gray)
                        //                            } else {
                        //                                Text("Master")
                        //                                    .font(.subheadline)
                        //                                    .foregroundStyle(.gray)
                        //                            }
                        //
                        //                        }
                        
//                        NavigationLink("Get Swipes") {
//                            GetSwipesView(isPresented: .constant(true))
//                                .environmentObject(rewardedAdsManager)
//                                .navigationBarBackButtonHidden(true)
//                        }
                        
                        //                        TODO: Subcription service
                        //                        Button("Manage Subscription") {
                        //                            showingPaywallView = true
                        //                        }
                        //                        .foregroundStyle(.red)
                        //                        .sheet(isPresented: $showingPaywallView) {
                        //                            VStack(spacing: 0) {
                        //                                HStack {
                        //                                    Spacer()
                        //
                        //                                    Button {
                        //                                        showingPaywallView = false
                        //                                    } label:{
                        //                                        Image(systemName: "arrow.down.circle.fill")
                        //                                            .foregroundStyle(Color(hex: 0x002247))
                        //                                            .fontWeight(.bold)
                        //                                            .imageScale(.large)
                        //                                            .font(.system(size: 20))
                        //                                    }
                        //                                    .padding()
                        //                                }
                        //
                        //                                PaywallView(viewModelAuth: viewModelAuth, isPaywallPresented: $showingPaywallView)
                        //                                    .environmentObject(viewModelAuth)
                        //                            }
                        //                        }
                    //                    }
                    
                    Section("Legal") {
                        HStack {
                            Button("Terms of Service") {
                                showingTOSView = true
                            }
                            .sheet(isPresented: $showingTOSView) {
                                VStack(spacing: 0) {
                                    HStack {
                                        Spacer()
                                        
                                        Button {
                                            showingTOSView = false
                                        } label:{
                                            Image(systemName: "arrow.down.circle.fill")
                                                .foregroundStyle(Color(hex: 0x002247))
                                                .fontWeight(.bold)
                                                .imageScale(.large)
                                                .font(.system(size: 20))
                                        }
                                        .padding()
                                    }
                                    
                                    TOSView()
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.up")
                                .foregroundStyle(Color(.systemGray2))
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Button("Privacy Policy") {
                                showingPPView = true
                            }
                            .sheet(isPresented: $showingPPView) {
                                VStack(spacing: 0) {
                                    HStack {
                                        Spacer()
                                        
                                        Button {
                                            showingPPView = false
                                        } label:{
                                            Image(systemName: "arrow.down.circle.fill")
                                                .foregroundStyle(Color(hex: 0x002247))
                                                .fontWeight(.bold)
                                                .imageScale(.large)
                                                .font(.system(size: 20))
                                        }
                                        .padding()
                                    }
                                    
                                    PrivacyPolicyView()
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.up")
                                .foregroundStyle(Color(.systemGray2))
                                .font(.subheadline)
                        }
                    }
                    
                    Section("General") {
                        HStack {
                            Text("Version")
                            
                            Spacer()
                            
                            Text("1.0.2")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    Section {
                        Button("Logout") {
                            viewModelAuth.signOut()
                        }
                        .foregroundStyle(.red)
                    }
                    
                    Section {
                        Button("Delete Account") {
                            showingReauthenticateView = true
                        }
                        .foregroundStyle(.red)
                        .fullScreenCover(isPresented: $showingReauthenticateView) {
                            ReauthenticateView()
                                .environmentObject(viewModelAuth)
                        }
                    }
                }
                .background(Color.white)
                .foregroundStyle(Color(hex: 0x002247))
                .padding(.bottom, 15)
            }
        }
    }
}
