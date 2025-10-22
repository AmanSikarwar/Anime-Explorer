//
//  ContentView.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
