//
//  MapViewContainer.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 26/06/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI
import MapKit
import CoreData

struct MapViewContainer: UIViewControllerRepresentable {

    @Binding var selectedMonument: Monument?

    class Coordinator: NSObject, MapViewControllerDelegate {
        
        
        var parent: MapViewContainer
        
        init(_ parent: MapViewContainer) {
            self.parent = parent
        }
        
        func monumentTouched(monument: Monument) {
            parent.selectedMonument = monument
        }
    }

    func makeUIViewController(context: Context) -> some MapViewController {
        let mapVC = MapViewController()
        mapVC.delegate = context.coordinator
        return mapVC
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

struct MapView: View {
    @State private var monument: Monument? = nil

    var body: some View {
        MapViewContainer(selectedMonument: $monument)
        .sheet(item: $monument) { aMonument in
            WikipediaDetailView(monument: aMonument)
                .onDisappear() {
                    monument = nil
                }
        }
    }
}
