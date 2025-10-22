//
//  Character.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import Foundation

struct Character: Codable, Identifiable {
    let malId: Int
    let url: String?
    let images: CharacterImages?
    let name: String
    let nameKanji: String?
    let nicknames: [String]?
    let favorites: Int?
    let about: String?
    
    var id: Int { malId }
    
    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case url, images, name
        case nameKanji = "name_kanji"
        case nicknames, favorites, about
    }
}

struct CharacterResponse: Codable {
    let data: [Character]
}

struct CharacterImages: Codable {
    let jpg: ImageFormat?
    let webp: ImageFormat?
}
