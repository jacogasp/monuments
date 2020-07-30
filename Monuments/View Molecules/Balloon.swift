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
                .foregroundColor(Color.primary)
                .padding(.leading)
            
            VStack(alignment: .leading) {
                Text(self.title.capitalized)
                    .font(.title)
            }
            Spacer()
            Text("\(self.distance) m")
                .font(.subtitle)
            Image(systemName: "chevron.right")
                .foregroundColor(Color.primary)
                .padding(.trailing)
        }
        .frame(width: self.frame.width, height: self.frame.height)
        .background(Color.white)
        .cornerRadius(self.frame.height / 2)

    }
}

struct DemoBallon: View {
    var body: some View {
        VStack {
            Balloon(title: "very long annotation")
                .frame(width: 400, height: 900)
        }
        .background(Color.orange)
    }
}

struct Balloon_Previews: PreviewProvider {
    static var previews: some View {
        DemoBallon()
    }
}
