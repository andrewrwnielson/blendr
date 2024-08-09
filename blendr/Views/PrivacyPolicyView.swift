//
//  PrivacyPolicyView.swift
//  blendr
//
//  Created by Andrew Nielson on 7/8/24.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        PDFViewer(pdfName: "PrivacyPolicy")
            .edgesIgnoringSafeArea(.all)
    }
}
