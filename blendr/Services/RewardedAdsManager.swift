//
//  RewardedAdsManager.swift
//  blendr
//
//  Created by Andrew Nielson on 7/2/24.
//

import GoogleMobileAds
import SwiftUI

class RewardedAdsManager: NSObject, GADFullScreenContentDelegate, ObservableObject {
    
    // Properties
    @Published var rewardedAdLoaded:Bool = false
    var rewardedAd : GADRewardedAd?
    
    // Load RewardedAd
    func loadRewardedAd(){
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest()) { [weak self] add, error in
            guard let self = self else {return}
            if let error = error{
                print("🔴: \(error.localizedDescription)")
                self.rewardedAdLoaded = false
                return
            }
            print("🟢: Loading succeeded")
            self.rewardedAdLoaded = true
            self.rewardedAd = add
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }
    
    // Display rewardAd
    func displayrewardedAd(){
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let root = windowScene?.windows.first?.rootViewController else {
            return
        }
        if let ad = rewardedAd{
            ad.present(fromRootViewController: root) {
                let reward = ad.adReward
                print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
            }
            self.rewardedAdLoaded = false
        }else{
            print("🔵: Ad wasn't ready")
            self.rewardedAdLoaded = false
            self.loadRewardedAd()
        }
    }
    
    // Failure notification
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("🟡: Failed to display rewarded ad with error: \(error)")
        self.loadRewardedAd()
    }
    
    // Indicate notification
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("🤩: Displayed a rewarded ad")
        self.rewardedAdLoaded = false
    }
    
    // Close notification
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("😔: rewarded ad closed")
    }
}
