//
//  blendrApp.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI
import Firebase
import RevenueCat
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start()
        
        return true
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

@main
struct blendrApp: App {
    @StateObject var viewModelAuth = AuthViewModel()
    @StateObject var interstitialAdsManager = InterstitialAdsManager()
    @StateObject var rewardedAdsManager = RewardedAdsManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModelAuth)
                .environmentObject(interstitialAdsManager)
                .environmentObject(rewardedAdsManager)
        }
    }
}
