//
//  Anime_ExplorerApp.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import SwiftUI
import CoreData

@main
struct Anime_ExplorerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
