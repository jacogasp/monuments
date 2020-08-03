//
//  StepperView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 28/07/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI

struct StepperView: View {
    var width: CGFloat = 40.0
    var height: CGFloat = 88.0
    
    @EnvironmentObject var env: Environment
    
    var body: some View {
        VStack {
            
            Button(action: {
                self.env.numVisibleMonuments += 1
                self.env.numVisibleMonuments = min(Constants.MAX_NUM_VISIBLE_POIS, self.env.numVisibleMonuments)
                self.env.showCounter = true

            }) {
                Spacer()
                VStack{
                    Spacer()
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                    Spacer()
                }
                Spacer()
            }
            
            Divider()
                .padding(.horizontal, 5)
            Button(action: {
                self.env.numVisibleMonuments -= 1
                self.env.numVisibleMonuments = max(0, self.env.numVisibleMonuments)
                self.env.showCounter = true
            }) {
                Spacer()
                VStack {
                    Spacer()
                    Image(systemName: "minus")
                        .foregroundColor(.white)
                    Spacer()
                }
                Spacer()
            }
        }
        .frame(width: width, height: height)
        .background(Blur(style: .systemThinMaterial))
        .cornerRadius(width / 2)
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct StepperView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            VStack {
                Color.blue
            }
            StepperView()
        }
    }
}
