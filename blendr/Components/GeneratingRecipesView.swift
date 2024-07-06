//
//  GeneratingRecipesView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

import SwiftUI

struct GeneratingRecipesView: View {
    @StateObject private var gameViewModel = MatchingGameViewModel()
    @State private var progress: CGFloat = 10.0
    private let totalDuration: CGFloat = 40.0

    var body: some View {
        VStack {
            MatchingGameView(viewModel: gameViewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()

            ProgressBarView(percent: $progress)
            
            Spacer()
            
            Text("Generating Recipes...")
                .padding(.top, 10)
                .foregroundColor(Color(hex: 0x002247))
                .font(.headline)
        }
        .padding(10)
        .onAppear {
            startProgress()
        }
    }

    private func startProgress() {
        let interval = 0.1
        let step = CGFloat(100.0 / (totalDuration / interval))

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if self.progress < 100 {
                self.progress += step
            } else {
                timer.invalidate()
            }
        }
    }
}
