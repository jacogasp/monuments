//
//  Balloon.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 27/07/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI

struct Balloon: View {

    var frame = CGSize(width: 300, height: 50)
    var title: String
    var distance = 203
    
    var body: some View {
        HStack {
            Image(systemName: "photo")
                .foregroundColor(.red)
                .padding(.leading)
            
            VStack(alignment: .leading) {
                Text(self.title.capitalized)
                    .fontWeight(.light)
            }
            Spacer()
            Text("\(self.distance) m")
                .font(.system(size: 12))
                .fontWeight(.light)
            Image(systemName: "chevron.right")
                .foregroundColor(.red)
                .padding(.trailing)
        }
        .frame(width: self.frame.width, height: self.frame.height)
        .overlay(
            RoundedRectangle(cornerRadius: self.frame.height)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

struct DemoBallon: View {
    var body: some View {
        VStack {
            Balloon(title: "very long annotation")
        }
    }
}

struct Balloon_Previews: PreviewProvider {
    static var previews: some View {
        DemoBallon()
    }
}
