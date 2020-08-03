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
            if self.env.showCounter {
                Text("\(self.env.numVisibleMonuments) visible elements around you")
                    .fontWeight(.light)
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(.infinity)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.gray)
                )
                    .transition(.fadeAndSlide)
                    .animation(.easeInOut(duration: 0.3))
                    .onAppear {
                        self.animateAndDelayWithSeconds(3) {
                            self.env.showCounter = false
                        }
                }
            }
            Spacer()
        }
        
    }
    
    func animateAndDelayWithSeconds(_ seconds: TimeInterval, action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            withAnimation {
                action()
            }
        }
    }
}


struct VisibilePOICounterTestView: View {
    @State private var show = false
    
    var body: some View {
        ZStack {
            Button(action: {
                withAnimation {
                    self.show.toggle()
                }}
            ) {
                Rectangle()
                    .background(Color.red)
            }
            
            VStack {
                if show {
                    VisiblePOIsCounterView()
                        .transition(.fadeAndSlide)
                        .animation(.easeInOut(duration: 0.3))
                        .onAppear {
                            animateAndDelayWithSeconds(3) {
                                self.show = false
                            }
                    }
                    Spacer()
                }
                
            }
        }
    }
}

func animateAndDelayWithSeconds(_ seconds: TimeInterval, action: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        withAnimation {
            action()
        }
    }
    
}

struct CounterTestView: View {
    @EnvironmentObject var env: Environment
    
    var body: some View {
        ZStack {
            Button(action: {
                self.env.showCounter.toggle()
            }){
                Text("culo")
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
