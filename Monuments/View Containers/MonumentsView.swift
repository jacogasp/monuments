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
    private let drawerWidth =  UIScreen.main.bounds.width * 0.75
    
    @State private var stepperValue = 1
    @State private var show = false
    @State private var offset = CGSize(width: -UIScreen.main.bounds.width * 0.75, height: 0)
    
    let options: [LeftDrawerOptionView] = [
        LeftDrawerOptionView(name: "Map", imageName: "map"),
        LeftDrawerOptionView(name: "Settings", imageName: "gear"),
        LeftDrawerOptionView(name: "Info", imageName: "info.circle")
    ]
    
    // MARK: - Body
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                
                ARCLView()
                
                ControlsView(show: self.$show, offset: self.$offset, offsetConstant: -self.drawerWidth )
                
                
                Button (action: {
                    self.offset.width = -self.drawerWidth
                    self.show.toggle()
                }) {
                    Rectangle()
                       .edgesIgnoringSafeArea(.all)
                       .foregroundColor(Color.black.opacity(0.5 - Double(abs(self.offset.width / self.drawerWidth))))
                       .animation(.easeInOut(duration: self.duration))
                    
                }
                    .allowsHitTesting(self.show)
                
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



struct MonumentsView_Previews: PreviewProvider {
    static var previews: some View {
        MonumentsView()
    }
}
