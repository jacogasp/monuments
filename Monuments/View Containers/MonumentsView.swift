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
    @State private var isNavigationBarHidden = true
    
    let options: [LeftDrawerOptionView] = [
        LeftDrawerOptionView(name: "Map", imageName: "map"),
        LeftDrawerOptionView(name: "Settings", imageName: "gear"),
        LeftDrawerOptionView(name: "Info", imageName: "info.circle")
    ]
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if gesture.translation.width < 0 {
                    self.offset = CGSize(width: gesture.translation.width, height: 0)
                }
        }
        .onEnded { _ in
            if abs(self.offset.width) > 100 {
                // remove the card
                self.offset = CGSize(width: -self.drawerWidth, height: 0)
                self.show = false
            } else {
                self.offset = .zero
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    ARCLView()
                    
                    ControlsView(show: self.$show, offset: self.$offset, offsetConstant: -self.drawerWidth )
                    
                    Button (action: {
                        self.offset.width = -self.drawerWidth
                        self.show.toggle()
                    }) {
                        if self.show {
                            Rectangle()
                                .edgesIgnoringSafeArea(.all)
                                .foregroundColor(Color.black.opacity(0.5 - Double(abs(self.offset.width / self.drawerWidth))))
                                .animation(.easeInOut(duration: self.duration))
                                .allowsHitTesting(false)
                        }
                    }
                    .allowsHitTesting(self.show)
                    
                    LeftDrawer(isNavigationBarHidden: self.$isNavigationBarHidden, options: self.options, offset: self.offset)
                        .animation(.easeInOut(duration: self.duration))
                        .gesture(self.drag)
                }
            }
            .background(Color.orange)
            .navigationBarTitle("")
            .navigationBarHidden(isNavigationBarHidden)
        }
    }
}



struct MonumentsView_Previews: PreviewProvider {
    static var previews: some View {
        MonumentsView()
    }
}
