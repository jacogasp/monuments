//
//  SettingsView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 05/08/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    private let settings: [SettingUI] = [SettingUI()]
    
    var body: some View {
        GeometryReader { geometry in
            List {
                SettingUI()
            }
            .navigationBarTitle("Settings")
            .listStyle(GroupedListStyle())
            .padding(geometry.safeAreaInsets)
        }
        
    }
}

struct SettingUI: View {
    
    
    @EnvironmentObject var env: Environment
    
    var body: some View {
        HStack {
            Image(systemName: "photo")
            Toggle(isOn: self.$env.showOvalMap) {
                Text("Show map overlay")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView().environmentObject(Environment())
        }
    }
}
