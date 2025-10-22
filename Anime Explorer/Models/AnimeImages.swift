//
//  AnimeImages.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import Foundation

struct AnimeImages: Codable {
    let jpg: ImageFormat?
    let webp: ImageFormat?
}

struct ImageFormat: Codable {
    let imageUrl: String?
    let smallImageUrl: String?
    let largeImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case smallImageUrl = "small_image_url"
        case largeImageUrl = "large_image_url"
    }
}
