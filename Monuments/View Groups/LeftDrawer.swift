//
//  LeftDrawer.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 26/07/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI


struct LeftDrawer: View {
    @Binding var isNavigationBarHidden: Bool
    var options: [LeftDrawerOptionView]
    
    let startColor = Color.secondary
    let endColor = Color.primary
    
    var offset: CGSize = .zero
    let destination = MapView()
    
    var body: some View {
        HStack {
            VStack {
                ZStack {
                    VStack{
                        HStack {
                            Spacer()
                            Text("Monuments")
                                .font(.trajanTitle)
                                .foregroundColor(Color.white)
                                .padding(.top, 64)
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    VStack {
                        Spacer()
                        ForEach(self.options) { option in
                            NavigationLink(destination:
                            self.destination
                                .edgesIgnoringSafeArea(.all)
                                .navigationBarTitle("Map", displayMode: .inline)
                                .onAppear {
                                    self.isNavigationBarHidden = false
                                }
                            .onDisappear {
                                self.isNavigationBarHidden = true
                                }
                           
                            ){
                                LeftItemCell(option: option)}
                        }
                        Spacer()
                    }
                }.background(Color.clear)
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all))
                .frame(width: UIScreen.main.bounds.width * 0.75)
                .offset(offset)
            Spacer()
        }
    }
}


struct LeftItemCell: View {
    
    var option: LeftDrawerOptionView
    var imageSize: CGFloat = 25
    
    var body: some View {
        
        HStack {
            Image(systemName: option.imageName)
                .resizable()
                .frame(width: Constants.drawerItemIconSize, height: Constants.drawerItemIconSize)
                .foregroundColor(.white)
            Text(option.name)
                .font(.main)
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
    }
}


struct LeftDrawerOptionView: Identifiable {
    var id = UUID()
    var name: String
    var imageName: String
}

let ooptions: [LeftDrawerOptionView] = [
    LeftDrawerOptionView(name: "Map", imageName: "map"),
    LeftDrawerOptionView(name: "Settings", imageName: "gear"),
    LeftDrawerOptionView(name: "Info", imageName: "info.circle")
]

//struct LeftDrawer_Previews: PreviewProvider {
//    @State var isNavigationBarHidden = false
//    static var previews: some View {
//        LeftDrawer(isNavigationBarHidden: $isNavigationBarHidden, options: ooptions)
//    }
//}
