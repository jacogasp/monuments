//
//  OvalMapViewUI.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 03/08/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI

struct OvalMapViewUI: View {
    
    let offset: CGFloat = 25.0
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                MapView(userTrackingMode: .followWithHeading).mask(
                    OvalShape()
                )
                .edgesIgnoringSafeArea(.bottom)
                .frame(width: geometry.size.width, height: 180, alignment: .bottom)
                    
            }
        }
    }
}

struct OvalShape : Shape {
    let offset: CGFloat = 25.0
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let width: CGFloat = rect.size.width
        
        let arcCenter: CGPoint = CGPoint(
            x: 0.5 * width,
            y: 0.5 * (self.offset + pow(width, 2) / (4 * self.offset))
        )
        
        let alpha = Double(atan(arcCenter.x / (arcCenter.y - self.offset)))
        
        p.addArc(
            center: arcCenter,
            radius: arcCenter.y,
            startAngle: Angle(radians: .pi + alpha),
            endAngle: Angle(radians: -alpha),
            clockwise: false
        )
        return p
    }
}

struct OvalMapViewUI_Previews: PreviewProvider {
    static var previews: some View {
        OvalMapViewUI()
    }
}
