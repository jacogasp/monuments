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
                            LeftItemCell(option: option, isNavigationBarHidden: self.$isNavigationBarHidden)
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
    @Binding var isNavigationBarHidden: Bool
    
    var body: some View {
        
        NavigationLink(destination:
            getDestination()
                .edgesIgnoringSafeArea(.all)
                .navigationBarTitle("\(option.name)", displayMode: .inline)
                .onAppear {
                    self.isNavigationBarHidden = false
            }
            .onDisappear {
                self.isNavigationBarHidden = true
            }
            
        ){
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
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                    .padding(.trailing)
            }
        }
    }
    
    func getDestination() -> some View {
        switch self.option.name {
        case "Map":
            return AnyView(MapView())
        case "Settings":
            return AnyView(SettingsView())
        case "Info":
            return AnyView(CreditsView())
        default:
            return AnyView(MapView())
        }
    }
}


struct LeftDrawerOptionView: Identifiable {
    var id = UUID()
    var name: String
    var imageName: String
}

private let _options = [
     LeftDrawerOptionView(name: "Map", imageName: "map"),
     LeftDrawerOptionView(name: "Settings", imageName: "gear"),
     LeftDrawerOptionView(name: "Info", imageName: "info.circle")
 ]

struct LeftDrawer_Previews: PreviewProvider {
    @State static var isNavigationBarHidden = false
    static var previews: some View {
        LeftDrawer(isNavigationBarHidden: $isNavigationBarHidden, options: _options)
    }
}
