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

    @State private var showLeftDrawer = false
    @State private var showRightDrawer = false
    @State private var leftOffset = CGSize(width: -UIScreen.main.bounds.width * 0.75, height: 0)
    @State private var rightOffset = CGSize(width: UIScreen.main.bounds.width * 0.75, height: 0)
    @State private var isNavigationBarHidden = true

    @EnvironmentObject private var env: Environment

    let options: [LeftDrawerOptionView] = [
        LeftDrawerOptionView(name: "Map", imageName: "map"),
        LeftDrawerOptionView(name: "Settings", imageName: "gear"),
        LeftDrawerOptionView(name: "Info", imageName: "info.circle")
    ]

    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if gesture.translation.width < 0 {
                    self.leftOffset = CGSize(width: gesture.translation.width, height: 0)
                }
            }
            .onEnded { _ in
                if abs(leftOffset.width) > 100 {
                    // remove the card
                    self.leftOffset = CGSize(width: -drawerWidth, height: 0)
                    self.showLeftDrawer = false
                } else {
                    self.leftOffset = .zero
                }
            }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {

                    // ARCL View
                    ARCLView()
                    ControlsView(
                        show: self.$showLeftDrawer, showRightDrawer: self.$showRightDrawer,
                        offset: self.$leftOffset,
                        offsetConstant: -drawerWidth
                    )

                    // Drawers toggle Button
                    Button(action: {
                        self.leftOffset.width = -drawerWidth
                        self.showLeftDrawer.toggle()
                    }) {
                        if showLeftDrawer {
                            Rectangle()
                                .edgesIgnoringSafeArea(.all)
                                .foregroundColor(Color.black.opacity(0.5 - Double(abs(leftOffset.width / drawerWidth))))
                                .animation(.easeInOut(duration: duration))
                        }
                    }
                    .allowsHitTesting(showLeftDrawer)

                    // Oval Map
                    if env.showOvalMap {
                        OvalMapViewUI()
                    }

                    // Visible POIs Counter
                    VisiblePOIsCounterView()

                    // Drawers
                    LeftDrawer(isNavigationBarHidden: self.$isNavigationBarHidden, options: options, offset: leftOffset)
                        .animation(.easeInOut(duration: duration))
                        .gesture(drag)

                    RightDrawer(isOpen: self.$showRightDrawer)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(isNavigationBarHidden)
        }
    }
}



struct MonumentsView_Previews: PreviewProvider {
    static var previews: some View {
        MonumentsView()
        //            .environmentObject(Environment())
        //        .environment(\.locale, .init(identifier: "en"))
    }
}
