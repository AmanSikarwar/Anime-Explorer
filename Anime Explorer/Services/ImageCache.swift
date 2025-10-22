//
//  ImageCache.swift
//  Anime Explorer
//
//  Created by Aman Sikarwar on 10/10/25.
//

import Foundation

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, CacheEntry>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private class CacheEntry {
        let data: Data
        let expirationDate: Date
        
        init(data: Data, expirationDate: Date) {
            self.data = data
            self.expirationDate = expirationDate
        }
        
        var isExpired: Bool {
            return Date() > expirationDate
        }
    }
    
    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func getImage(from urlString: String) async throws -> Data? {
        let key = NSString(string: urlString)
        
        if let entry = cache.object(forKey: key), !entry.isExpired {
            return entry.data
        }
        
        let fileURL = cacheDirectory.appendingPathComponent(urlString.hash.description)
        if let data = try? Data(contentsOf: fileURL) {
            let entry = CacheEntry(data: data, expirationDate: Date().addingTimeInterval(86400)) // 24 hours
            cache.setObject(entry, forKey: key)
            return data
        }
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let entry = CacheEntry(data: data, expirationDate: Date().addingTimeInterval(86400))
        cache.setObject(entry, forKey: key)
        try? data.write(to: fileURL)
        
        return data
    }
    
    func clearCache() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}
