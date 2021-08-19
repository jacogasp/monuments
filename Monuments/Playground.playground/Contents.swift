//: A UIKit based Playground for presenting user interface
  
import SwiftUI
import PlaygroundSupport
import CoreLocation
import MapKit

struct MyView : View {
    var body: some View {
        Text(Locale.current.languageCode! + "_pl")
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.setLiveView(MyView())


let location = CLLocation(latitude: 44.4942646, longitude: 11.3426603)
let radius = CLLocationDistance(1000)
let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius * 2, longitudinalMeters: radius * 2)

let minLatitude = region.center.latitude - region.span.latitudeDelta
let maxLatitude = region.center.latitude + region.span.latitudeDelta
let minLongitude = region.center.longitude - region.span.longitudeDelta
let maxLongitude = region.center.longitude + region.span.longitudeDelta

print([minLatitude, maxLatitude, minLongitude, maxLongitude])

print("\"" + ["a", "b", "c"].joined(separator: "\",\"") + "\"")
