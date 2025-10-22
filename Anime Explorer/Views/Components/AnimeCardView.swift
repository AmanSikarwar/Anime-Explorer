//
//  AnimeCardView.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import SwiftUI

struct AnimeCardView: View {
    let anime: Anime
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AnimeImageView(imageUrl: anime.imageURL, width: nil, height: 200)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            
            Text(anime.displayTitle)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(anime.displayScore)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if anime.episodes != nil {
                    Text(anime.displayEpisodes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !anime.genresList.isEmpty {
                Text(anime.genresList)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 160)
    }
}

struct AnimeListCardView: View {
    let anime: Anime
    
    var body: some View {
        HStack(spacing: 12) {
            AnimeImageView(imageUrl: anime.imageURL, width: 100, height: 140)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(anime.displayTitle)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(anime.displayScore)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                if let type = anime.type {
                    Text(type)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
                
                if !anime.genresList.isEmpty {
                    Text(anime.genresList)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            Spacer()
        }
        .frame(height: 140)
        .background(Color(.systemBackground))
    }
}

#Preview {
    let sampleAnime = Anime(
        malId: 1,
        url: nil,
        images: AnimeImages(
            jpg: ImageFormat(
                imageUrl: "https://cdn.myanimelist.net/images/anime/1208/94745.jpg",
                smallImageUrl: nil,
                largeImageUrl: nil
            ),
            webp: nil
        ),
        trailer: nil,
        approved: true,
        titles: nil,
        title: "Cowboy Bebop",
        titleEnglish: "Cowboy Bebop",
        titleJapanese: "カウボーイビバップ",
        type: "TV",
        source: "Original",
        episodes: 26,
        status: "Finished Airing",
        airing: false,
        aired: nil,
        duration: "24 min",
        rating: "R - 17+",
        score: 8.75,
        scoredBy: 500000,
        rank: 28,
        popularity: 43,
        members: 1500000,
        favorites: 50000,
        synopsis: "In the year 2071, humanity has colonized several of the planets and moons...",
        background: nil,
        season: "spring",
        year: 1998,
        broadcast: nil,
        producers: nil,
        licensors: nil,
        studios: nil,
        genres: [
            MALEntity(malId: 1, type: "anime", name: "Action", url: nil),
            MALEntity(malId: 24, type: "anime", name: "Sci-Fi", url: nil)
        ],
        themes: nil,
        demographics: nil
    )
    
    VStack {
        AnimeCardView(anime: sampleAnime)
        AnimeListCardView(anime: sampleAnime)
    }
}
