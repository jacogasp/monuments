//
//  MonumentsView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 25/07/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI

struct MonumentsView: View {
    
    // MARK: - Properties
    
    private let duration = 0.2
    
    @State private var stepperValue = 1
    @State private var show = false
    @State private var offset = CGSize(width: -UIScreen.main.bounds.width * 0.75, height: 0)
    var options: [LeftDrawerOptionView]
    
    // MARK: - Body
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                ARCLView()
                ControlsView(show: self.$show, offset: self.$offset, offsetConstant: -UIScreen.main.bounds.width * 0.75)
                HStack {
                    LeftDrawer(options: self.options)
                        .frame(width: geometry.size.width * 0.75)
                        .offset(self.offset)
                        .animation(.easeInOut(duration: self.duration))
                    Spacer()
                }
                
            }
                
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width < 0 {
                            self.offset = CGSize(width: gesture.translation.width, height: 0)
                        }
                }
                .onEnded { _ in
                    if abs(self.offset.width) > 100 {
                        // remove the card
                        self.offset = CGSize(width: -geometry.size.width * 0.75, height: 0)
                        self.show = false
                    } else {
                        self.offset = .zero
                    }
                }
            )
        }
    }
}

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

struct MonumentsView_Previews: PreviewProvider {
    static var previews: some View {
        MonumentsView(options: options)
    }
}
