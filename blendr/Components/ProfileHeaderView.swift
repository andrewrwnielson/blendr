//
//  ProfileHeaderView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/23/24.
//

import SwiftUI

struct ProfileHeaderView: View {
    let user: User
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(user.profileIcon)
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .shadow(radius: 10)
            Text("\(user.firstname)")
                .font(.title2)
                .fontWeight(.light)
                .foregroundStyle(Color(hex: 0x002247))
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 240)
    }
}
