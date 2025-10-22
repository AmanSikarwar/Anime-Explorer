//
//  AnimeDetailView.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import SwiftUI
import CoreData

struct AnimeDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: AnimeDetailViewModel
    @State private var isFavorite = false
    
    let animeId: Int
    
    init(animeId: Int) {
        self.animeId = animeId
        _viewModel = StateObject(wrappedValue: AnimeDetailViewModel(animeId: animeId))
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.anime == nil {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
            } else if let anime = viewModel.anime {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with image and basic info
                    headerSection(anime: anime)
                    
                    // Synopsis
                    synopsisSection(anime: anime)
                    
                    // Details
                    detailsSection(anime: anime)
                    
                    // Genres
                    genresSection(anime: anime)
                    
                    // Characters
                    if !viewModel.characters.isEmpty {
                        charactersSection()
                    }
                    
                    // Recommendations
                    if !viewModel.recommendations.isEmpty {
                        recommendationsSection()
                    }
                }
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    Task {
                        await viewModel.loadDetails()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .font(.title3)
                }
            }
        }
        .task {
            await viewModel.loadDetails()
            checkIfFavorite()
        }
    }
    
    // MARK: - Header Section
    
    @ViewBuilder
    private func headerSection(anime: Anime) -> some View {
        ZStack(alignment: .bottom) {
            // Background Image with Gradient
            AnimeImageView(imageUrl: anime.imageURL, height: 400)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
            
            // Title and basic info
            VStack(alignment: .leading, spacing: 8) {
                Text(anime.displayTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                HStack(spacing: 16) {
                    // Score
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(anime.displayScore)
                            .fontWeight(.semibold)
                    }
                    
                    // Type
                    if let type = anime.type {
                        Text(type)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(4)
                    }
                    
                    // Status
                    if let status = anime.status {
                        Text(status)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.8))
                            .cornerRadius(4)
                    }
                }
                .font(.caption)
                .foregroundColor(.white)
                
                // Episodes and Duration
                HStack(spacing: 8) {
                    if anime.episodes != nil {
                        Text(anime.displayEpisodes)
                    }
                    
                    if let duration = anime.duration {
                        Text("•")
                        Text(duration)
                    }
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Synopsis Section
    
    @ViewBuilder
    private func synopsisSection(anime: Anime) -> some View {
        if let synopsis = anime.synopsis {
            VStack(alignment: .leading, spacing: 8) {
                Text("Synopsis")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(synopsis)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Details Section
    
    @ViewBuilder
    private func detailsSection(anime: Anime) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                if let rating = anime.rating {
                    DetailRow(title: "Rating", value: rating)
                }
                
                if let source = anime.source {
                    DetailRow(title: "Source", value: source)
                }
                
                if let season = anime.season, let year = anime.year {
                    DetailRow(title: "Season", value: "\(season.capitalized) \(year)")
                }
                
                if let studios = anime.studios, !studios.isEmpty {
                    DetailRow(title: "Studios", value: studios.map { $0.name }.joined(separator: ", "))
                }
                
                if let rank = anime.rank {
                    DetailRow(title: "Rank", value: "#\(rank)")
                }
                
                if let popularity = anime.popularity {
                    DetailRow(title: "Popularity", value: "#\(popularity)")
                }
                
                if let members = anime.members {
                    DetailRow(title: "Members", value: formatNumber(members))
                }
                
                if let favorites = anime.favorites {
                    DetailRow(title: "Favorites", value: formatNumber(favorites))
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Genres Section
    
    @ViewBuilder
    private func genresSection(anime: Anime) -> some View {
        if let genres = anime.genres, !genres.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Genres")
                    .font(.title2)
                    .fontWeight(.bold)
                
                FlowLayout(spacing: 8) {
                    ForEach(genres) { genre in
                        Text(genre.name)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Characters Section
    
    @ViewBuilder
    private func charactersSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Characters")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.characters) { character in
                        CharacterCard(character: character)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Recommendations Section
    
    @ViewBuilder
    private func recommendationsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("You May Also Like")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recommendations, id: \.malId) { recommendation in
                        NavigationLink(destination: AnimeDetailView(animeId: recommendation.malId)) {
                            RecommendationCard(recommendation: recommendation)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkIfFavorite() {
        isFavorite = PersistenceController.shared.isFavorite(malId: animeId, context: viewContext)
    }
    
    private func toggleFavorite() {
        if isFavorite {
            PersistenceController.shared.removeFromFavorites(malId: animeId, context: viewContext)
        } else {
            if let anime = viewModel.anime {
                PersistenceController.shared.addToFavorites(anime: anime, context: viewContext)
            }
        }
        isFavorite.toggle()
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - Supporting Views

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct CharacterCard: View {
    let character: Character
    
    var body: some View {
        VStack(spacing: 8) {
            if let imageUrl = character.images?.jpg?.imageUrl {
                AnimeImageView(imageUrl: imageUrl, width: 80, height: 110)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 110)
                    .cornerRadius(8)
            }
            
            Text(character.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
    }
}

struct RecommendationCard: View {
    let recommendation: RecommendationEntry
    
    var body: some View {
        VStack(spacing: 8) {
            if let imageUrl = recommendation.images?.jpg?.imageUrl {
                AnimeImageView(imageUrl: imageUrl, width: 120, height: 170)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 170)
                    .cornerRadius(8)
            }
            
            if let title = recommendation.title {
                Text(title)
                    .font(.caption)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 120)
            }
        }
    }
}

// FlowLayout for genres
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
