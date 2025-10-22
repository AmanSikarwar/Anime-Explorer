//
//  APIService.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import Foundation


class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api.jikan.moe/v4"
    private let session: URLSession
    
    private var lastRequestTime: Date?
    private let minimumRequestInterval: TimeInterval = 0.5
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)
    }
        
    private func enforceRateLimit() async {
        if let lastRequest = lastRequestTime {
            let timeSinceLastRequest = Date().timeIntervalSince(lastRequest)
            if timeSinceLastRequest < minimumRequestInterval {
                let waitTime = minimumRequestInterval - timeSinceLastRequest
                try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }
        lastRequestTime = Date()
    }
        
    private func request<T: Decodable>(_ endpoint: String) async throws -> T {
        await enforceRateLimit()
        
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimitExceeded
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let decodingError as DecodingError {
            throw APIError.decodingError(decodingError)
        } catch {
            throw APIError.networkError(error)
        }
    }
        
    /// Search for anime by query
    func searchAnime(query: String, page: Int = 1, limit: Int = 20) async throws -> AnimeResponse {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return try await request("/anime?q=\(encodedQuery)&page=\(page)&limit=\(limit)&order_by=popularity")
    }
    
    /// Get top anime
    func getTopAnime(page: Int = 1, limit: Int = 20) async throws -> AnimeResponse {
        return try await request("/top/anime?page=\(page)&limit=\(limit)")
    }
    
    /// Get seasonal anime (current season)
    func getSeasonalAnime(year: Int? = nil, season: String? = nil, page: Int = 1) async throws -> AnimeResponse {
        let currentYear = year ?? Calendar.current.component(.year, from: Date())
        let currentSeason = season ?? getCurrentSeason()
        return try await request("/seasons/\(currentYear)/\(currentSeason)?page=\(page)")
    }
    
    /// Get upcoming anime
    func getUpcomingAnime(page: Int = 1, limit: Int = 20) async throws -> AnimeResponse {
        return try await request("/seasons/upcoming?page=\(page)&limit=\(limit)")
    }
    
    /// Get anime by ID
    func getAnimeDetails(id: Int) async throws -> SingleAnimeResponse {
        return try await request("/anime/\(id)")
    }
    
    /// Get anime characters
    func getAnimeCharacters(animeId: Int) async throws -> CharacterResponse {
        return try await request("/anime/\(animeId)/characters")
    }
    
    /// Get anime recommendations
    func getAnimeRecommendations(animeId: Int) async throws -> RecommendationResponse {
        return try await request("/anime/\(animeId)/recommendations")
    }
    
    /// Get popular anime (currently airing)
    func getPopularAnime(page: Int = 1, limit: Int = 20) async throws -> AnimeResponse {
        return try await request("/anime?order_by=popularity&sort=asc&page=\(page)&limit=\(limit)&status=airing")
    }
        
    private func getCurrentSeason() -> String {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 1...3:
            return "winter"
        case 4...6:
            return "spring"
        case 7...9:
            return "summer"
        case 10...12:
            return "fall"
        default:
            return "winter"
        }
    }
}
