//
//  TOSView.swift
//  blendr
//
//  Created by Andrew Nielson on 7/7/24.
//

import SwiftUI
import PDFKit

struct TOSView: View {
    var body: some View {
        PDFViewer(pdfName: "TOS")
            .edgesIgnoringSafeArea(.all)
    }
}

struct PDFViewer: UIViewRepresentable {
    var pdfName: String
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        
        if let path = Bundle.main.url(forResource: pdfName, withExtension: "pdf"),
           let document = PDFDocument(url: path) {
            pdfView.document = document
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update the view if needed.
    }
}

// Preview for SwiftUI Canvas
struct TOSView_Previews: PreviewProvider {
    static var previews: some View {
        TOSView()
    }
}
