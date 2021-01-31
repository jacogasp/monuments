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
    private let delayAfterHide = 3.0
    
    @State private var isOpen = false
    @State private var isZooming = false
    @State private var offset: CGSize = .zero
    @EnvironmentObject private var env: Environment
    
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var remaining = 3.0
    
    var rangeHeight: CGFloat {
        buttonHeight - innerOffset / 2
    }
    
    var tap: some Gesture {
        LongPressGesture(minimumDuration: 0.2)
            .onEnded { _ in
                timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
                remaining = delayAfterHide
                withAnimation {
                    self.isOpen = true
                }
            }
    }
    
    var drag: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { gesture in
                remaining = delayAfterHide
                let translationY = gesture.translation.height
                self.offset = CGSize(width: 0, height: min(max(-rangeHeight, translationY), rangeHeight))
                if !isZooming {
                    self.isZooming = true
                }
            }
            .onEnded { _ in
                self.isZooming = false
                withAnimation {
                    self.offset = .zero
                }
            }
    }
    
    var body: some View {
        let combined = tap.sequenced(before: drag)
        
        if isZooming {
            DispatchQueue.main.async {
                var increment = pow(abs(Double(offset.height) / 100), speedFactor)
                increment = offset.height > 0 ? increment * -1 : increment
                env.maxDistance = max(min(env.maxDistance + increment, 5000), 0)
            }
        }
        
        return HStack {
            Text("\(Int(env.maxDistance)) m")
                .font(Font.subtitle)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.white)
                .clipShape(Capsule(style: .circular))
                .opacity(isOpen ? 1 : 0)
                .offset(offset)
                .padding(.trailing)
            
            ZStack {
                RoundedRectangle(cornerRadius: width / 2)
                    .foregroundColor(Color.white.opacity(0.8))
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .opacity(isOpen ? 0 : 1)
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
                    .frame(height: isOpen ? buttonHeight : 0)
                    .opacity(isOpen ? 1 : 0)
                    .offset(offset)
                    .shadow(radius: 9, y: 4)
                    .padding(.leading, 4)
                    .padding(.trailing, 4)
            }
                .gesture(combined)
                .frame(width: width, height: isOpen ? height : width)
        }
            .padding()
            .onReceive(timer) { _ in
                remaining -= 0.1
                if remaining <= 0 {
                    cancelTimer()
                    withAnimation {
                        isOpen = false
                    }
                }
            }
    }
    
    func cancelTimer() {
        timer.upstream.connect().cancel()
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
