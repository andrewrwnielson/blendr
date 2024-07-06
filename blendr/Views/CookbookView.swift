//
//  CookbookView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct CookbookView: View {
    @State private var selectedSegment = 0

    var body: some View {
        VStack {
            Picker("Select", selection: $selectedSegment) {
                Text("Likes").tag(0)
                Text("Saves").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedSegment == 0 {
                LikedRecipesView()
            } else {
                SavedRecipesView()
            }
        }
        .padding(.bottom, 15)
        .navigationTitle("Cookbook")
    }
}
