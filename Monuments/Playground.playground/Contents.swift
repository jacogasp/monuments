//: A UIKit based Playground for presenting user interface
  
import SwiftUI
import PlaygroundSupport

struct MyView : View {
    var body: some View {
        Text(Locale.current.languageCode! + "_pl")
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.setLiveView(MyView())
