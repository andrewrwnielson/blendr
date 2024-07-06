//
//  NewUserOnboardingView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct NewUserOnboardingView: View {
    @EnvironmentObject var viewModelAuth: AuthViewModel
    @Binding var isOnboardingCompleted: Bool
    @State private var isShowingPreferences = false
    
    var body: some View {
        Group {
            if isShowingPreferences {
                NewUserPreferencesView(isOnboardingCompleted: $isOnboardingCompleted)
            } else {
                IconSelectionView(isShowingPreferences: $isShowingPreferences)
            }
        }
    }
}
