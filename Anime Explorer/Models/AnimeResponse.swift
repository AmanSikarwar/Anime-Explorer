//
//  AnimeResponse.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import Foundation


struct AnimeResponse: Codable {
    let data: [Anime]
    let pagination: Pagination?
}

struct SingleAnimeResponse: Codable {
    let data: Anime
}
