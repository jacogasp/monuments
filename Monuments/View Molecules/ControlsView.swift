//
//  ControlsView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 30/07/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI

struct ControlsView: View {
    
    @Binding var show: Bool
    @Binding var offset: CGSize
    var offsetConstant: CGFloat
    
    var body: some View {
        VStack {
            HStack(alignment: .top){
                VStack {
                Button(action: {
                    self.show.toggle()
                    self.offset = self.show ? CGSize.zero : CGSize(width: -self.offsetConstant, height: 0)
                }) {
                    Image("Burger")
                }
                .foregroundColor(.white)
                }
                Spacer()
                VStack {
                    Image("Funnel")
                    StepperView()
                        .padding(.top, 40)
                }
            }
            .padding(16)
            Spacer()
        }
    }
}
