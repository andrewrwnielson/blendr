//
//  ProgressBarView.swift
//  blendr
//
//  Created by Andrew Nielson on 6/24/24.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var percent: CGFloat
    var width: CGFloat = 200
    var height: CGFloat = 20
    var color1 = Color(.clear)
    var color2 = Color(hex: 0x002247)
    
    
    var body: some View {
        let multiplyer = width / 100
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: height, style: .continuous)
                .frame(width: width, height: height)
                .foregroundColor(Color.black.opacity(0.1))
            
            RoundedRectangle(cornerRadius: height, style: .continuous)
                .frame(width: percent * multiplyer, height: height)
                .background(
                    LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: .trailing)
                        .clipShape(RoundedRectangle(cornerRadius: height, style: .continuous))
                )
                .foregroundStyle(.clear)
        }
    }
}

#Preview {
    ProgressBarView(percent: .constant(69))
}
