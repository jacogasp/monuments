//
//  RightDrawer.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 09/08/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI
import Combine

struct RightDrawer: View {
    
    @EnvironmentObject private var env: Environment
    @State private var xOffset: CGFloat = UIScreen.main.bounds.width
    @State private var isDragging = false
    //    @State var options: [RightOption]
    @Binding var isOpen: Bool
    
    init(isOpen: Binding<Bool>) {
        self._isOpen = isOpen
    }
    
    let startColor = Color.secondary
    let endColor = Color.primary
    let drawerPadding = UIScreen.main.bounds.width - CGFloat.drawerWidth
    
    func Background(opacity: Double) -> some View {
        var background: some View {
            
            Button(action: {self.isOpen.toggle()}) {
                Color.black
                    .edgesIgnoringSafeArea(.vertical)
                    .opacity(opacity)
                    .animation(.default)
            }
        }
        return background
    }
    
    var GrandientBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            startPoint: .top,
            endPoint: .bottom
        )
            .edgesIgnoringSafeArea(.vertical)
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if gesture.translation.width > 0 {
                    self.isDragging = true
                    self.xOffset = gesture.translation.width
                }
        }
        .onEnded { _ in
            self.isDragging = false
            if abs(self.xOffset) > 100 {
                // remove the card
                self.xOffset = UIScreen.main.bounds.width
                self.isOpen = false
            } else {
                self.xOffset = .zero
            }
        }
    }
    
    
    var body: some View {
        //        let options = env.activeCategories.map{(key, value) in RightOption(name: key, isSelected: value) }
        
        var offset: CGFloat = .zero
        
        if !isDragging{
            offset = self.isOpen ? 0 : UIScreen.main.bounds.width
        } else {
            offset = self.xOffset
        }
        return
            ZStack {
                Background(opacity: 0.5 - 0.5 * Double(offset / UIScreen.main.bounds.width))
                    .allowsHitTesting(self.isOpen)
                VStack {
                    VStack {
                        Text("visible_categories")
                            .font(.trajanTitle)
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                        ScrollView() {
                            ForEach(env.activeCategories, id: \.name) { option in
                                RightDrawerItem(option: option)
                                    .onTapGesture {
                                        print(option.name)
//                                        option.isSelected.toggle()
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                    }
                    Spacer()
                }
                .background(GrandientBackground)
                .padding(.leading, drawerPadding)
                .edgesIgnoringSafeArea(.bottom)
                .offset(x: offset)
                .animation(.default)
                .gesture(drag)
        }
    }
}

struct RightDrawerItem: View {
    
    
//    var isSelected: Bool
    var circleRadius: CGFloat = 15.0
//    var name: String
     var option: RightOption
    
    var body: some View {
       HStack {
            ZStack {
                Image(systemName: "circle")
                    .resizable()
                    .frame(width: circleRadius, height: circleRadius)
                    .foregroundColor(.white)
                Image(systemName: option.isSelected ? "circle.fill" : "circle")
                    .resizable()
                    .frame(width: circleRadius - 5, height: circleRadius - 5)
                    .foregroundColor(.white)
            }
            Text(LocalizedStringKey(option.name))
                .font(.main)
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
        .frame(height: 44)
        .padding(.leading)
    }
}


struct RightOption {
//    var didChange = PassthroughSubject<Void, Never>()
//    var id = UUID()
    var name: String
    var isSelected = true {
        didSet {
            print("\(name), \(isSelected)")
//            didChange.send()
        }
    }
    
    init(name: String, isSelected: Bool) {
        self.name = name
        self.isSelected = isSelected
    }
    
}

struct RightDrawer_Previews: PreviewProvider {
    @State static var isOpen = true
    static var previews: some View {
        RightDrawer(isOpen: $isOpen).environmentObject(Environment())
            .environment(\.locale, Locale(identifier: "it"))
    }
}
