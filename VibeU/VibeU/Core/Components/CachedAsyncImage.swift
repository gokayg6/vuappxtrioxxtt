import SwiftUI

// MARK: - Image Cache Manager
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let memoryLimit = 100 // Max 100 images in memory
    
    private init() {
        cache.countLimit = memoryLimit
    }
    
    func image(for url: String) -> UIImage? {
        return cache.object(forKey: url as NSString)
    }
    
    func setImage(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
}

// MARK: - Cached Async Image
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        let urlString = url.absoluteString
        
        // Check cache first
        if let cached = ImageCacheManager.shared.image(for: urlString) {
            self.image = cached
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    // Save to cache
                    ImageCacheManager.shared.setImage(uiImage, for: urlString)
                    
                    await MainActor.run {
                        self.image = uiImage
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Convenience Extensions
extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(url: url, content: content, placeholder: { ProgressView() })
    }
}

// MARK: - Profile Photo View (Optimized)
struct ProfilePhotoView: View {
    let url: String?
    let size: CGFloat
    var placeholder: String = "person.fill"
    
    var body: some View {
        CachedAsyncImage(url: URL(string: url ?? "")) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Image(systemName: placeholder)
                        .font(.system(size: size * 0.4))
                        .foregroundStyle(.gray)
                )
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// MARK: - Card Photo View (Optimized)
struct CardPhotoView: View {
    let url: String?
    let width: CGFloat
    let height: CGFloat
    var cornerRadius: CGFloat = 16
    
    var body: some View {
        CachedAsyncImage(url: URL(string: url ?? "")) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    ProgressView()
                        .tint(.gray)
                )
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

#Preview {
    VStack(spacing: 20) {
        ProfilePhotoView(
            url: "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg",
            size: 80
        )
        
        CardPhotoView(
            url: "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg",
            width: 200,
            height: 250
        )
    }
    .padding()
}
