import SwiftUI
import Combine

// MARK: - Image Cache Service
actor ImageCacheService {
    static let shared = ImageCacheService()
    
    private var cache: [String: UIImage] = [:]
    private var loadingTasks: [String: Task<UIImage?, Never>] = [:]
    private let urlCache = URLCache.shared
    
    private init() {
        // Configure URLCache for better image caching
        urlCache.memoryCapacity = 100 * 1024 * 1024 // 100 MB
        urlCache.diskCapacity = 200 * 1024 * 1024 // 200 MB
    }
    
    // Get cached image or load it
    func getImage(url: String) async -> UIImage? {
        // Check memory cache first
        if let cached = cache[url] {
            return cached
        }
        
        // Check if already loading
        if let task = loadingTasks[url] {
            return await task.value
        }
        
        // Start loading
        let task = Task<UIImage?, Never> {
            await loadImage(url: url)
        }
        loadingTasks[url] = task
        
        let image = await task.value
        loadingTasks[url] = nil
        
        return image
    }
    
    // Prefetch multiple images in background
    func prefetchImages(urls: [String]) {
        Task {
            for url in urls {
                // Skip if already cached
                if cache[url] != nil { continue }
                
                // Load in background
                _ = await getImage(url: url)
            }
        }
    }
    
    // Load image from URL
    private func loadImage(url: String) async -> UIImage? {
        guard let imageURL = URL(string: url) else { return nil }
        
        // Check URLCache first
        let request = URLRequest(url: imageURL)
        if let cachedResponse = urlCache.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            cache[url] = image
            return image
        }
        
        // Download image
        do {
            let (data, response) = try await URLSession.shared.data(from: imageURL)
            
            // Cache the response
            let cachedData = CachedURLResponse(response: response, data: data)
            urlCache.storeCachedResponse(cachedData, for: request)
            
            // Create and cache image
            if let image = UIImage(data: data) {
                cache[url] = image
                return image
            }
        } catch {
            print("⚠️ Failed to load image: \(url) - \(error)")
        }
        
        return nil
    }
    
    // Clear cache
    func clearCache() {
        cache.removeAll()
        urlCache.removeAllCachedResponses()
    }
    
    // Clear old entries to manage memory
    func pruneCache(keepRecent: Int = 50) {
        if cache.count > keepRecent {
            let keysToRemove = Array(cache.keys.prefix(cache.count - keepRecent))
            for key in keysToRemove {
                cache.removeValue(forKey: key)
            }
        }
    }
}

// MARK: - Cached Async Image View
struct CachedAsyncImage: View {
    let url: String
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color(white: 0.15))
                    .overlay {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                    }
            }
        }
        .task(id: url) {
            await loadImage()
        }
        .onChange(of: url) { _, newUrl in
            Task {
                isLoading = true
                image = nil
                await loadImage()
            }
        }
    }
    
    private func loadImage() async {
        image = await ImageCacheService.shared.getImage(url: url)
        isLoading = false
    }
}
