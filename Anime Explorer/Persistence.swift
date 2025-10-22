//
//  Persistence.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Preview data can be added here if needed
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Anime_Explorer")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Favorites Management
    
    func addToFavorites(anime: Anime, context: NSManagedObjectContext) {
        let favorite = FavoriteAnime(context: context)
        favorite.malId = Int64(anime.malId)
        favorite.title = anime.displayTitle
        favorite.imageUrl = anime.imageURL
        favorite.score = anime.score ?? 0
        favorite.episodes = Int64(anime.episodes ?? 0)
        favorite.synopsis = anime.synopsis
        favorite.genres = anime.genresList
        favorite.rating = anime.rating
        favorite.status = anime.status
        favorite.type = anime.type
        favorite.addedDate = Date()
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Error saving favorite: \(nsError), \(nsError.userInfo)")
        }
    }
    
    func removeFromFavorites(malId: Int, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<FavoriteAnime> = FavoriteAnime.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "malId == %d", malId)
        
        do {
            let results = try context.fetch(fetchRequest)
            for favorite in results {
                context.delete(favorite)
            }
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Error removing favorite: \(nsError), \(nsError.userInfo)")
        }
    }
    
    func isFavorite(malId: Int, context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteAnime> = FavoriteAnime.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "malId == %d", malId)
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            return false
        }
    }
}
