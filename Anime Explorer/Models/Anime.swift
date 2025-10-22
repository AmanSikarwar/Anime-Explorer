//
//  Anime.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import Foundation

struct Anime: Codable, Identifiable {
    let malId: Int
    let url: String?
    let images: AnimeImages?
    let trailer: Trailer?
    let approved: Bool?
    let titles: [Title]?
    let title: String?
    let titleEnglish: String?
    let titleJapanese: String?
    let type: String?
    let source: String?
    let episodes: Int?
    let status: String?
    let airing: Bool?
    let aired: Aired?
    let duration: String?
    let rating: String?
    let score: Double?
    let scoredBy: Int?
    let rank: Int?
    let popularity: Int?
    let members: Int?
    let favorites: Int?
    let synopsis: String?
    let background: String?
    let season: String?
    let year: Int?
    let broadcast: Broadcast?
    let producers: [MALEntity]?
    let licensors: [MALEntity]?
    let studios: [MALEntity]?
    let genres: [MALEntity]?
    let themes: [MALEntity]?
    let demographics: [MALEntity]?
    
    var id: Int { malId }
    
    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case url, images, trailer, approved, titles, title
        case titleEnglish = "title_english"
        case titleJapanese = "title_japanese"
        case type, source, episodes, status, airing, aired, duration, rating, score
        case scoredBy = "scored_by"
        case rank, popularity, members, favorites, synopsis, background, season, year, broadcast
        case producers, licensors, studios, genres, themes, demographics
    }
    
    // Helper computed properties
    var displayTitle: String {
        titleEnglish ?? title ?? "Unknown Title"
    }
    
    var imageURL: String? {
        images?.jpg?.largeImageUrl ?? images?.jpg?.imageUrl
    }
    
    var genresList: String {
        genres?.map { $0.name }.joined(separator: ", ") ?? "N/A"
    }
    
    var displayScore: String {
        if let score = score {
            return String(format: "%.2f", score)
        }
        return "N/A"
    }
    
    var displayEpisodes: String {
        if let episodes = episodes {
            return "\(episodes) episodes"
        }
        return "Unknown"
    }
}

struct Trailer: Codable {
    let youtubeId: String?
    let url: String?
    let embedUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case youtubeId = "youtube_id"
        case url
        case embedUrl = "embed_url"
    }
}

struct Title: Codable {
    let type: String?
    let title: String?
}

struct Aired: Codable {
    let from: String?
    let to: String?
    let prop: AiredProp?
}

struct AiredProp: Codable {
    let from: DateProp?
    let to: DateProp?
}

struct DateProp: Codable {
    let day: Int?
    let month: Int?
    let year: Int?
}

struct Broadcast: Codable {
    let day: String?
    let time: String?
    let timezone: String?
    let string: String?
}

struct MALEntity: Codable, Identifiable {
    let malId: Int
    let type: String?
    let name: String
    let url: String?
    
    var id: Int { malId }
    
    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case type, name, url
    }
}
