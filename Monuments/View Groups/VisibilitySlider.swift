//
//  VisibilitySlider.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 07/08/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI

struct VisibilitySlider: View {
    
    private let width: CGFloat = 45
    private let height: CGFloat = 240
    private let innerOffset: CGFloat = 8
    private let buttonHeight: CGFloat = 80
    private let speedFactor = 1.8
    
    @State private var isOpen = false
    @State private var isZooming = false
    @State private var offset: CGSize = .zero
    @EnvironmentObject private var env: Environment
    
    var rangeHeight: CGFloat {
        return buttonHeight - innerOffset / 2
    }
    
    var tap: some Gesture {
        LongPressGesture(minimumDuration: 0.2)
            .onEnded { _ in
                withAnimation {
                    self.isOpen = true
                }
                DispatchQueue.main.asyncAfter(timeInterval: 1, execute: {
                    if self.offset == .zero {
                        withAnimation {
                            self.isOpen = false
                        }
                    }
                })
        }
    }
    
    var drag: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { gesture in
                let translationY = gesture.translation.height
                self.offset = CGSize(
                    width: 0,
                    height: min(max(-self.rangeHeight, translationY), self.rangeHeight)
                )
                if !self.isZooming {
                    self.isZooming = true
                }
        }
        .onEnded { _ in
            self.isZooming = false
            withAnimation {
                self.offset = .zero
            }
            DispatchQueue.main.asyncAfter(timeInterval: 1, execute: {
                withAnimation {
                    self.isOpen = false
                }
            })
            
        }
    }
    
    var body: some View {
        let combined = tap.sequenced(before: drag)
        
        if self.isZooming {
            DispatchQueue.main.async {
                var increment = pow(abs(Double(self.offset.height) / 100), self.speedFactor)
                increment = self.offset.height > 0 ? increment * -1 : increment
                self.env.maxDistance = max(min(self.env.maxDistance + increment, 5000), 0)
            }
        }
        
        return HStack {
            Group {
                Text("\(Int(self.env.maxDistance)) m")
                    .font(Font.subtitle)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
            }
            .background(Color.white)
            .opacity(self.isOpen ? 1 : 0)
            .cornerRadius(.infinity)
            .offset(self.offset)
            .padding(.trailing)
            
            ZStack {
                RoundedRectangle(cornerRadius: width / 2)
                    .foregroundColor(Color.white.opacity(0.8))
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .opacity(self.isOpen ? 0 : 1)
                ZStack {
                    RoundedRectangle(cornerRadius: (width - innerOffset) / 2)
                        .foregroundColor(.white)
                    
                    VStack {
                        Image(systemName: "chevron.up")
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding(.top)
                    .padding(.bottom)
                }
                .frame(height: self.isOpen ? buttonHeight : 0)
                .opacity(self.isOpen ? 1 : 0)
                .offset(self.offset)
                .shadow(radius: 9, y: 4)
                .padding(.leading, 4)
                .padding(.trailing, 4)
                
            }
            .gesture(combined)
            .frame(width: width, height: self.isOpen ? height : width)
        }
        .padding()
    }
}

struct VisibilitySliderTest: View {
    var body: some View {
        ZStack {
            Color.black
            HStack {
                Spacer()
                VisibilitySlider()
                .environmentObject(Environment())
            }
        }
    }
}

struct VisibilitySlider_Previews: PreviewProvider {
    static var previews: some View {
        VisibilitySliderTest()
    }
}
