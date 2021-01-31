//
//  VisiblePOIsCounterView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 02/08/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI

struct VisiblePOIsCounterView: View {

    @EnvironmentObject private var env: Environment

    var body: some View {

        VStack {
            if env.showVisibleMonumentsCounter {
                Text("\(env.numVisibleMonuments) visible elements around you")
                        .fontWeight(.light)
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.top, 4)
                        .padding(.bottom, 4)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Capsule(style: .circular))
                        .transition(.fadeAndSlide)
            }
            Spacer()
        }
    }
}

struct CounterTestView: View {
    @EnvironmentObject var env: Environment

    var body: some View {
        ZStack {
            Button(action: {
                withAnimation(.easeInOut) {
                    env.showVisibleMonumentsCounter.toggle()
                }
            }) {
                Text("Test")
            }
            VisiblePOIsCounterView()
        }
    }
}

struct VisiblePOIsCounterView_Previews: PreviewProvider {


    static var previews: some View {
        CounterTestView().environmentObject(Environment())
    }
}
