//
//  AsyncImageLoader.swift
//  Monuments
//
//  Created by Jacopo Gasparetto on 19/09/2020.
//  Copyright © 2020 Jacopo Gasparetto. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var url: URL
    private var cancellable: AnyCancellable?
    private var cache: ImageCache?
    private var didAppear = false
    private(set) var isLoading = false
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    init(url: URL, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }
    
    deinit {
        cancellable?.cancel()
        didAppear = false
    }
    
    func load() {
        
        guard !isLoading else { return }
        
        if !didAppear {
            if let image = cache?[url] {
                self.image = image
                logger.debug("Image loaded from cache")
                return
            }
            
            logger.debug("Downloading image...")
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .subscribe(on: Self.imageProcessingQueue)
                .map{ UIImage(data: $0.data) }
                .replaceError(with: nil)
                .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                              receiveOutput: { [weak self] in self?.cache($0) },
                              receiveCompletion: { [weak self] _ in self?.onFinish()},
                              receiveCancel: { [weak self] in self?.onFinish() })
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self)
        }
        didAppear = true
    }
    
    private func cache(_ image: UIImage?) {
        image.map { cache?[url] = $0 }
    }
    
    func cancel() {
        logger.debug("Cancel")
        cancellable?.cancel()
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
}

// MARK: - AsyncImage View

struct AsyncImage<Placeholder: View>: View {
    
    @ObservedObject private var imageLoader: ImageLoader
    private let placeholder: Placeholder?
    private let configuration: (Image) -> Image
    
    init(url: URL, placeholder: Placeholder? = nil, cache: ImageCache? = nil, configuration: @escaping (Image) -> Image = { $0 }) {
        imageLoader = ImageLoader(url: url, cache: cache)
        self.placeholder = placeholder
        self.configuration = configuration
    }
    
    var body: some View {
        image
            .onAppear(perform: imageLoader.load)
            .onDisappear(perform: imageLoader.cancel)
    }
    
    private var image: some View {
        Group {
            if imageLoader.image != nil {
                configuration(Image(uiImage: imageLoader.image!))
            } else {
                placeholder
            }
        }
    }
}

// MARK: - Cache

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct TemporayImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        
        set {
            if (newValue == nil) {
                cache.removeObject(forKey: key as NSURL)
            } else {
                cache.setObject(newValue!, forKey: key as NSURL)
            }
        }
    }
}

// MARK: - Environment

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporayImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
