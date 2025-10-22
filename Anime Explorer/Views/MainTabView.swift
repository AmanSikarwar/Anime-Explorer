//
//  MainTabView.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import SwiftUI
import CoreData

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "square.grid.2x2")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            AnimeListView(listType: .topRated, title: "Top Anime")
                .tabItem {
                    Label("Top", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            AnimeListView(listType: .upcoming, title: "Upcoming")
                .tabItem {
                    Label("Upcoming", systemImage: "calendar")
                }
                .tag(3)
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
