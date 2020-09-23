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

// MARK: - WikiRequest Handler

class WikiRequest: ObservableObject {
    
    @Published var response: WikiResponse?
    
    let didChange = ObservableObjectPublisher()
    
    var imageUrl: URL? = nil {
        didSet {
            didChange.send()
            logger.debug("Image url retrieved")
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
            logger.error(error)
        }
        return nil
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

struct WikiImage: View {
    var url: URL
    
    @SwiftUI.Environment(\.imageCache) var cache: ImageCache
    
    var body: some View {
        AsyncImage(url: url, placeholder: Text("Loading..."), cache: cache, configuration: {$0.resizable()})
            .scaledToFill()
            
    }
}

// MARK: - ImageLoader

struct WikipediaDetailView: View {
    
    @ObservedObject private var wikiRequest: WikiRequest
    
    private let lang = "it"
    private let placeholder = Text("Loading...")
    
    private let title: String
    private let subtitle: String?
    
    init(monument: Monument) {
        self.title = monument.name.capitalized
        self.subtitle = monument.category.capitalized
        wikiRequest = WikiRequest(title: monument.wikiUrl![lang]!, lang: lang) // FIXME: lang cannot exists
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
                        
                        if let imageUrl = wikiRequest.imageUrl {
                            WikiImage(url: imageUrl)
                        }
                        self.text
                            .onAppear(perform: self.wikiRequest.load)
                            .onDisappear(perform: self.wikiRequest.cancel)
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
            if wikiRequest.response != nil {
                Text(wikiRequest.response?.extract ?? "No data found.")
            } else {
                placeholder
            }
        }
    }
    
    private var image: some View {
        Group {
            if wikiRequest.imageUrl != nil {
                AsyncImage(url: wikiRequest.imageUrl!, placeholder: placeholder)
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

import CoreLocation.CLLocation
struct WikipediaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        let monument = Monument(
            id: 0,
            title: "Colosseo",
            subtitle: "Sito Archeologico",
            location: CLLocation(latitude: 44.1, longitude: 11.3),
            wiki: "{\"it\": \"Colosseo\", \"en\": \"Colosseo\"}")
        
        return WikiContentView(monument: monument)
    }
}
