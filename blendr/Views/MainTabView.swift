//
//  MainTabView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct MainTabView: View {
    @State var selectedTab: Int = 1 // Set initial tab to Home
    @EnvironmentObject var interstitialAdsManager: InterstitialAdsManager

    var body: some View {
        TabView(selection: $selectedTab) {
            CookbookView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Cookbook")
                }
                .tag(0)
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(1)
                .environmentObject(interstitialAdsManager)
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(2)
        }
        .tint(Color(hex: 0x002247))
    }
}
