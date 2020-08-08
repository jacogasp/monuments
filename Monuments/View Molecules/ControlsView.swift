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
        ZStack {
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
                
                Image("Funnel")
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            Spacer()
        }
        HStack {
                 Spacer()
                 VisibilitySlider()
             }
        }
    }
}

struct ControlsViewTest: View {
    @State var show = false
    @State var offset = CGSize.zero
    
    var body: some View {
        ControlsView(show: $show, offset: $offset, offsetConstant: 0)
            .background(Color.black)
    }
}

struct ControlsViewTest_Previews: PreviewProvider {
    static var previews: some View {
        ControlsViewTest()
    }
}
