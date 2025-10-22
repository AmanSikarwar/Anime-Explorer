//
//  FavoritesView.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import SwiftUI
import CoreData

struct FavoritesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteAnime.addedDate, ascending: false)],
        animation: .default)
    private var favorites: FetchedResults<FavoriteAnime>
    
    var body: some View {
        NavigationView {
            Group {
                if favorites.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(favorites) { favorite in
                                NavigationLink(destination: AnimeDetailView(animeId: Int(favorite.malId))) {
                                    FavoriteCardView(favorite: favorite)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !favorites.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: clearAllFavorites) {
                            Text("Clear All")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start adding anime to your favorites by tapping the heart icon")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func clearAllFavorites() {
        for favorite in favorites {
            viewContext.delete(favorite)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error clearing favorites: \(error)")
        }
    }
}

struct FavoriteCardView: View {
    @ObservedObject var favorite: FavoriteAnime
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            AnimeImageView(imageUrl: favorite.imageUrl, width: 100, height: 140)
                .cornerRadius(8)
            
            // Info
            VStack(alignment: .leading, spacing: 8) {
                Text(favorite.title ?? "Unknown")
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.2f", favorite.score))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                if let type = favorite.type {
                    Text(type)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
                
                if let genres = favorite.genres, !genres.isEmpty {
                    Text(genres)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            Spacer()
            
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .font(.title3)
        }
        .frame(height: 140)
        .background(Color(.systemBackground))
    }
}

#Preview {
    FavoritesView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
