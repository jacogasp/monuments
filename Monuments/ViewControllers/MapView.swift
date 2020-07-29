////
////  MapView.swift
////  Monuments
////
////  Created by Jacopo Gasparetto on 26/06/2020.
////  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
////
//
//import SwiftUI
//import MapKit
//import CoreData
//
//struct MapView: UIViewRepresentable {
//
//    func makeUIView(context: Context) -> MKMapView {
//        MKMapView(frame: .zero)
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//
//    }
//}
//
//
//struct ContentView: View {
//
////    @FetchRequest(entity: Monument.entity(), sortDescriptors: []) var monuments: FetchedResults<Monument>
//    var fetchRequest: FetchRequest<Monument>
//    var monuments: FetchedResults<Monument>
//
//
//    init() {
//        let request: NSFetchRequest<Monument> = Monument.fetchRequest()
//        request.fetchLimit = 10
//        fetchRequest = FetchRequest<Monument>(fetchRequest: request)
//    }
//
//
//
//    var body: some View {
//        //MapView()
//        //        Text(monuments.first!.title!)
//        ForEach(monuments, id: \.self) { monument in
//            Text("\(monument.title!)")
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//        return ContentView().environment(\.managedObjectContext, context)
//    }
//}
