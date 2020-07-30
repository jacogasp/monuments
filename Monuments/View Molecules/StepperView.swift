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
        
    var body: some View {
            VStack {
                Spacer()
                Image(systemName: "plus")
                    .foregroundColor(.white)
                Spacer()
                Divider()
                    .padding(.horizontal, 5)
                Spacer()
                Image(systemName: "minus")
                    .foregroundColor(.white)
                Spacer()

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
