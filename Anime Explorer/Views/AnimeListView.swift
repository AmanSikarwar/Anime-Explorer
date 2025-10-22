//
//  AnimeListView.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import SwiftUI

struct AnimeListView: View {
    @StateObject private var viewModel: AnimeViewModel
    let title: String
    
    init(listType: AnimeViewModel.ListType, title: String) {
        _viewModel = StateObject(wrappedValue: AnimeViewModel(listType: listType))
        self.title = title
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.animeList.isEmpty {
                    ProgressView("Loading \(title)...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage, viewModel.animeList.isEmpty {
                    ErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadAnime()
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.animeList) { anime in
                                NavigationLink(destination: AnimeDetailView(animeId: anime.malId)) {
                                    AnimeListCardView(anime: anime)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                                .onAppear {
                                    // Load more when reaching the last item
                                    if anime.id == viewModel.animeList.last?.id {
                                        Task {
                                            await viewModel.loadMoreAnime()
                                        }
                                    }
                                }
                            }
                            
                            // Loading indicator for pagination
                            if viewModel.hasMorePages {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            if viewModel.animeList.isEmpty {
                await viewModel.loadAnime()
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: retry) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AnimeListView(listType: .topRated, title: "Top Anime")
}
