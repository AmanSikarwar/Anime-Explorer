//
//  SearchView.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var isSearchFieldFocused = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search anime...", text: $viewModel.searchQuery)
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.searchQuery) {
                            viewModel.search()
                        }
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: {
                            viewModel.searchQuery = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // Content
                Group {
                    if viewModel.searchQuery.isEmpty {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("Search for Anime")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Find your favorite anime by title")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.isSearching && viewModel.searchResults.isEmpty {
                        ProgressView("Searching...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.searchResults.isEmpty {
                        // No results
                        VStack(spacing: 16) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("No Results Found")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Try searching with different keywords")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Results
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.searchResults) { anime in
                                    NavigationLink(destination: AnimeDetailView(animeId: anime.malId)) {
                                        AnimeListCardView(anime: anime)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal)
                                    .onAppear {
                                        // Load more when reaching the last item
                                        if anime.id == viewModel.searchResults.last?.id {
                                            Task {
                                                await viewModel.loadMoreResults()
                                            }
                                        }
                                    }
                                }
                                
                                // Loading indicator for pagination
                                if viewModel.hasMorePages && !viewModel.isSearching {
                                    ProgressView()
                                        .padding()
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SearchView()
}

