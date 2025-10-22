//
//  BrowseView.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import SwiftUI

struct BrowseView: View {
    @StateObject private var topViewModel = AnimeViewModel(listType: .topRated)
    @StateObject private var popularViewModel = AnimeViewModel(listType: .popular)
    @StateObject private var seasonalViewModel = AnimeViewModel(listType: .seasonal)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    animeSection(
                        title: "Top Rated Anime",
                        viewModel: topViewModel,
                        destination: AnimeListView(listType: .topRated, title: "Top Rated")
                    )
                    
                    animeSection(
                        title: "Popular This Season",
                        viewModel: popularViewModel,
                        destination: AnimeListView(listType: .popular, title: "Popular")
                    )
                    
                    animeSection(
                        title: "Current Season",
                        viewModel: seasonalViewModel,
                        destination: AnimeListView(listType: .seasonal, title: "This Season")
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("Browse")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            if topViewModel.animeList.isEmpty {
                await topViewModel.loadAnime()
            }
            if popularViewModel.animeList.isEmpty {
                await popularViewModel.loadAnime()
            }
            if seasonalViewModel.animeList.isEmpty {
                await seasonalViewModel.loadAnime()
            }
        }
    }
    
    @ViewBuilder
    private func animeSection<Destination: View>(
        title: String,
        viewModel: AnimeViewModel,
        destination: Destination
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: destination) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            if viewModel.isLoading && viewModel.animeList.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
            } else if !viewModel.animeList.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.animeList.prefix(10)) { anime in
                            NavigationLink(destination: AnimeDetailView(animeId: anime.malId)) {
                                AnimeCardView(anime: anime)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

#Preview {
    BrowseView()
}
