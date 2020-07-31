//
//  CreditsView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 31/07/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI
import UIKit


struct CreditsView: View {
    
    // MARK: - Init
    
    let filename = "Info_credits"
    
    // MARK: - Body
    
    var body: some View {
            loadTextFile(filename: filename)
    }
    
    
    // MARK: - Helpers
    
    func loadTextFile(filename: String ) -> some View  {
        
        let url = Bundle.main.url(forResource: filename, withExtension: "rtf")!
        let attributedStringWithRtf = try! NSAttributedString(
            url: url,
            options: [
                NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf
            ],
            documentAttributes: nil)
        
        return TextView(attributedString: attributedStringWithRtf)
        
    }
}

struct TextView: UIViewRepresentable {
    var attributedString: NSAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        return UITextView()
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedString
    }
}


struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
