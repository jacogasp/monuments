//
//  WikipediaDetailView.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 07/07/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import SwiftUI
import Combine

struct Thumbnail: Codable {
    var height: Int?
    var width: Int?
    var source: URL?
}

struct WikiResponse: Codable {
    var extract: String?
    var originalimage: Thumbnail?
}

class WikiRequest: ObservableObject {
    
    @Published var response: WikiResponse?
    
    let didChange = ObservableObjectPublisher()
    
    var imageUrl: URL? = nil {
        didSet {
            didChange.send()
            print("did change")
        }
    }
    
    private let url: URL
    private var cancellable: AnyCancellable?
    
    
    init(title: String, lang: String) {
        let baseUrl = "https://\(lang).wikipedia.org/api/rest_v1/page/summary/"
        self.url = URL(string: baseUrl + title.replacingOccurrences(of: " ", with: "_"))!
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func load() {
        cancellable = URLSession.shared.dataTaskPublisher(for: self.url)
            .map{ self.decodeData(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.response, on: self)
    }
    
    private func decodeData(data: Data) -> WikiResponse? {
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(WikiResponse.self, from: data)
            self.imageUrl = decodedData.originalimage?.source
            return decodedData
        }
        catch {
            print(error)
        }
        return nil
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var url: URL?
    private var cancellable: AnyCancellable?
    
    init(url: URL?) {
        self.url = url
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func load() {
        if let url = self.url {
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map{ UIImage(data: $0.data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self)
        }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

struct AsyncImage<Placeholder: View>: View {
    
    @ObservedObject private var imageLoader: ImageLoader
    private let placeholder: Placeholder?
    
    init(url: URL, placeholder: Placeholder? = nil) {
        print(url)
        imageLoader = ImageLoader(url: url)
        self.placeholder = placeholder
    }
    
    var body: some View {
        image.onAppear(perform: imageLoader.load)
            .onDisappear(perform: imageLoader.cancel)
    }
    
    private var image: some View {
        Group {
            if imageLoader.image != nil {
                Image(uiImage: imageLoader.image!)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
    }
}

struct WikipediaDetailView: View {
    
    @ObservedObject private var loader: WikiRequest
    
    private let lang = "it"
    private var imageLoader: ImageLoader
    private let placeholder = Text("Loading...")
    
    private let title: String
    private let subtitle: String?
    
    init(monument: Monument) {
        self.title = monument.name.capitalized
        self.subtitle = monument.category.capitalized
        loader = WikiRequest(title: monument.wikiUrls![lang]!, lang: lang) // FIXME: lang cannot exists
        imageLoader = ImageLoader(url: nil)
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    HStack() {
                        self.subtitle.map({ Text($0) })
                            .padding(.leading)
                        Spacer()
                    }
                    Divider()
                    VStack(){
                        self.image.onAppear(perform: self.imageLoader.load)
                            .onDisappear(perform: self.imageLoader.cancel)
                            .frame(maxWidth: geometry.size.width)
                        self.text.onAppear(perform: self.loader.load)
                            .onDisappear(perform: self.loader.cancel)
                            .frame(maxHeight: .infinity)
                            .padding()
                    }
                }
            }
            .navigationBarTitle(title)
        }
    }
    
    private var text: some View {
        Group {
            if loader.response != nil {
                Text(loader.response?.extract ?? "No data found.")
            } else {
                placeholder
            }
        }
    }
    
    private var image: some View {
        Group {
            if loader.imageUrl != nil {
                AsyncImage(url: loader.imageUrl!, placeholder: placeholder)
            } else {
                placeholder
            }
        }
    }
}


struct WikiContentView: View {
    var monument: Monument
    @State var showDetail = false
    
    var body: some View {
        Button (action: {
            self.showDetail.toggle()
        }) {
            Text("Show detail")
        }.sheet(isPresented: $showDetail) {
            WikipediaDetailView(monument: self.monument)
        }
    }
}


struct WikipediaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let monument = Monument(context: context)
        monument.name = "Colosseo"
        monument.category = "Sito Archeologico"
        monument.wikiUrl = "{\"it\": \"Colosseo\", \"en\": \"Colosseo\"}"
        
        return WikiContentView(monument: monument)
    }
}
