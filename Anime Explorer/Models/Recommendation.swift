//
//  Recommendation.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import Foundation

struct Recommendation: Codable, Identifiable {
    let malId: String?
    let entry: [RecommendationEntry]
    let content: String?
    let user: RecommendationUser?
    
    var id: String { malId ?? UUID().uuidString }
    
    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case entry, content, user
    }
}

struct RecommendationEntry: Codable {
    let malId: Int
    let url: String?
    let images: AnimeImages?
    let title: String?
    
    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case url, images, title
    }
}

struct RecommendationUser: Codable {
    let url: String?
    let username: String?
}

struct RecommendationResponse: Codable {
    let data: [Recommendation]
}
