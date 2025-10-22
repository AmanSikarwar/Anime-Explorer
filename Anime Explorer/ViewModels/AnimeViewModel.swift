//
//  AnimeViewModel.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AnimeViewModel: ObservableObject {
    @Published var animeList: [Anime] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    
    private let apiService = APIService.shared
    private var currentPage = 1
    private var isFetchingMore = false
    
    enum ListType {
        case topRated
        case popular
        case upcoming
        case seasonal
    }
    
    private var listType: ListType
    
    init(listType: ListType = .topRated) {
        self.listType = listType
    }
    
    func loadAnime() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        do {
            let response: AnimeResponse
            
            switch listType {
            case .topRated:
                response = try await apiService.getTopAnime(page: currentPage)
            case .popular:
                response = try await apiService.getPopularAnime(page: currentPage)
            case .upcoming:
                response = try await apiService.getUpcomingAnime(page: currentPage)
            case .seasonal:
                response = try await apiService.getSeasonalAnime(page: currentPage)
            }
            
            animeList = response.data
            hasMorePages = response.pagination?.hasNextPage ?? false
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadMoreAnime() async {
        guard !isFetchingMore && hasMorePages && !isLoading else { return }
        
        isFetchingMore = true
        currentPage += 1
        
        do {
            let response: AnimeResponse
            
            switch listType {
            case .topRated:
                response = try await apiService.getTopAnime(page: currentPage)
            case .popular:
                response = try await apiService.getPopularAnime(page: currentPage)
            case .upcoming:
                response = try await apiService.getUpcomingAnime(page: currentPage)
            case .seasonal:
                response = try await apiService.getSeasonalAnime(page: currentPage)
            }
            
            animeList.append(contentsOf: response.data)
            hasMorePages = response.pagination?.hasNextPage ?? false
            
        } catch {
            errorMessage = error.localizedDescription
            currentPage -= 1
        }
        
        isFetchingMore = false
    }
    
    func refresh() async {
        await loadAnime()
    }
}

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchResults: [Anime] = []
    @Published var searchQuery = ""
    @Published var isSearching = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    
    private let apiService = APIService.shared
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    
    func search() {
        searchTask?.cancel()
        
        searchResults = []
        currentPage = 1
        errorMessage = nil
        
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            
            await performSearch()
        }
    }
    
    private func performSearch() async {
        isSearching = true
        
        do {
            let response = try await apiService.searchAnime(query: searchQuery, page: currentPage)
            searchResults = response.data
            hasMorePages = response.pagination?.hasNextPage ?? false
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isSearching = false
    }
    
    func loadMoreResults() async {
        guard hasMorePages && !isSearching else { return }
        
        currentPage += 1
        isSearching = true
        
        do {
            let response = try await apiService.searchAnime(query: searchQuery, page: currentPage)
            searchResults.append(contentsOf: response.data)
            hasMorePages = response.pagination?.hasNextPage ?? false
        } catch {
            errorMessage = error.localizedDescription
            currentPage -= 1
        }
        
        isSearching = false
    }
}

@MainActor
class AnimeDetailViewModel: ObservableObject {
    @Published var anime: Anime?
    @Published var characters: [Character] = []
    @Published var recommendations: [RecommendationEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    let animeId: Int
    
    init(animeId: Int) {
        self.animeId = animeId
    }
    
    func loadDetails() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        async let animeTask: () = loadAnime()
        async let charactersTask: () = loadCharacters()
        async let recommendationsTask: () = loadRecommendations()
        await animeTask
        await charactersTask
        await recommendationsTask
        
        isLoading = false
    }

    private func loadAnime() async {
        do {
            let response = try await apiService.getAnimeDetails(id: animeId)
            anime = response.data
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func loadCharacters() async {
        do {
            let response = try await apiService.getAnimeCharacters(animeId: animeId)
            characters = Array(response.data.prefix(10))        } catch {
            print("Error loading characters: \(error)")
        }
    }
    
    private func loadRecommendations() async {
        do {
            let response = try await apiService.getAnimeRecommendations(animeId: animeId)
            recommendations = response.data.flatMap { $0.entry }.filter { $0.malId != animeId }
            recommendations = Array(Set(recommendations.map { $0.malId })).compactMap { malId in
                recommendations.first { $0.malId == malId }
            }.prefix(6).map { $0 }
        } catch {
            print("Error loading recommendations: \(error)")
        }
    }
}

