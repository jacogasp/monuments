//
//  LeftDrawer.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 26/07/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI



struct LeftDrawer: View {
    var options: [LeftDrawerOptionView]
    
    let startColor = Color(#colorLiteral(red: 0.9537991881, green: 0.2298480868, blue: 0.2896286845, alpha: 1))
    let endColor = Color(#colorLiteral(red: 0.7994838357, green: 0.2183310688, blue: 0.165236026, alpha: 1))
    
    let titleFontFamily = "Trajan Pro"
    let titleFontSize: CGFloat = 38
    let fontSize: CGFloat = 25
    let imageSize: CGFloat = 25

    
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Text("Monuments")
                    .fontWeight(.bold)
                    .font(.custom(titleFontFamily, size: titleFontSize))
                    .foregroundColor(Color.white)
                    .padding(.top, 64)
                Spacer()
                
            }
            Spacer()
            ForEach(self.options) { option in
                LeftItemCell(option: option, imageSize: self.imageSize, fontSize: self.fontSize)
            }
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
    }
    
}

struct LeftDrawer_Previews: PreviewProvider {
    
    static var previews: some View {
        LeftDrawer(options: options)
    }
}


struct LeftItemCell: View {
    
    var option: LeftDrawerOptionView
    var imageSize:CGFloat = 25
    var fontSize: CGFloat = 20
    
    var body: some View {
        HStack {
            Image(systemName: option.imageName)
            .resizable()
                .frame(width: imageSize, height: imageSize)
                .foregroundColor(.white)
            Text(option.name)
                .font(.custom("Helvetica Neue Light", size: fontSize))
                .foregroundColor(.white)
                
            
            Spacer()
        }
    }
}


struct LeftDrawerOptionView: Identifiable {
    var id = UUID()
    var name: String
    var imageName: String
}


let options: [LeftDrawerOptionView] = [
    LeftDrawerOptionView(name: "Map", imageName: "map"),
    LeftDrawerOptionView(name: "Settings", imageName: "gear"),
    LeftDrawerOptionView(name: "Info", imageName: "info.circle")
]
