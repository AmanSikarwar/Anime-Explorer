//
//  AsyncImageView.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: String?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var imageData: Data?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let urlString = url, !isLoading else { return }
        
        isLoading = true
        
        Task {
            do {
                if let data = try await ImageCache.shared.getImage(from: urlString) {
                    await MainActor.run {
                        imageData = data
                        isLoading = false
                    }
                }
            } catch {
                print("Error loading image: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}


struct AnimeImageView: View {
    let imageUrl: String?
    let width: CGFloat?
    let height: CGFloat?
    
    init(imageUrl: String?, width: CGFloat? = nil, height: CGFloat? = nil) {
        self.imageUrl = imageUrl
        self.width = width
        self.height = height
    }
    
    var body: some View {
        CachedAsyncImage(url: imageUrl) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    ProgressView()
                        .tint(.white)
                )
        }
        .frame(width: width, height: height)
        .clipped()
    }
}
