//
//  Pagination.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import Foundation

struct Pagination: Codable {
    let lastVisiblePage: Int?
    let hasNextPage: Bool?
    let currentPage: Int?
    let items: PaginationItems?
}

struct PaginationItems: Codable {
    let count: Int?
    let total: Int?
    let perPage: Int?
    
    enum CodingKeys: String, CodingKey {
        case count, total
        case perPage = "per_page"
    }
}
