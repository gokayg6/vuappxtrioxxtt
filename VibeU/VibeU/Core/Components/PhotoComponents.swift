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

// MARK: - Async Image with Glass Loading (CACHED)

struct GlassAsyncImage: View {
    let url: String?
    let contentMode: ContentMode
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(url: String?, contentMode: ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                GlassSkeletonCard()
            } else {
                placeholderView
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let urlString = url, let imageURL = URL(string: urlString) else { return }
        
        // Check cache first
        if let cached = ImageCacheManager.shared.image(for: urlString) {
            self.image = cached
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
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
    
    private var placeholderView: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Photo Slider (For Cards)

struct PhotoSlider: View {
    let photos: [UserPhoto]
    let profilePhotoURL: String
    @State private var currentIndex = 0
    
    private var allPhotos: [String] {
        if photos.isEmpty {
            return [profilePhotoURL]
        }
        return photos.sorted { $0.orderIndex < $1.orderIndex }.map { $0.url }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(Array(allPhotos.enumerated()), id: \.offset) { index, url in
                    GlassAsyncImage(url: url)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom Page Indicator
            if allPhotos.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<allPhotos.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentIndex ? Color.white : Color.white.opacity(0.4))
                            .frame(width: index == currentIndex ? 20 : 8, height: 4)
                            .animation(.spring(response: 0.3), value: currentIndex)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .glassEffect()
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Profile Photo Grid

struct ProfilePhotoGrid: View {
    let photos: [UserPhoto]
    let maxPhotos: Int
    let onAddPhoto: () -> Void
    let onDeletePhoto: (UserPhoto) -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(photos.sorted { $0.orderIndex < $1.orderIndex }) { photo in
                ProfilePhotoGridItem(photo: photo, onDelete: { onDeletePhoto(photo) })
            }
            
            if photos.count < maxPhotos {
                ProfileAddPhotoButton(action: onAddPhoto)
            }
        }
    }
}

struct ProfilePhotoGridItem: View {
    let photo: UserPhoto
    let onDelete: () -> Void
    @State private var showDeleteConfirm = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            GlassAsyncImage(url: photo.url)
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .glassEffect()
            
            if photo.isPrimary {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                    .padding(6)
                    .glassEffect()
                    .padding(4)
            } else {
                Button {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(4)
            }
        }
        .confirmationDialog(
            "delete_photo_confirm",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("delete", role: .destructive, action: onDelete)
            Button("cancel", role: .cancel) {}
        }
    }
}

struct ProfileAddPhotoButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.title2)
                Text("add_photo")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .glassEffect()
        }
        .buttonStyle(GlassButtonPressStyle())
    }
}

// MARK: - Avatar

struct GlassAvatar: View {
    let url: String?
    let size: CGFloat
    let showOnlineIndicator: Bool
    let isOnline: Bool
    
    init(
        url: String?,
        size: CGFloat = 48,
        showOnlineIndicator: Bool = false,
        isOnline: Bool = false
    ) {
        self.url = url
        self.size = size
        self.showOnlineIndicator = showOnlineIndicator
        self.isOnline = isOnline
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GlassAsyncImage(url: url)
                .frame(width: size, height: size)
                .clipShape(Circle())
                .glassEffect()
            
            if showOnlineIndicator {
                Circle()
                    .fill(isOnline ? Color.green : Color.gray)
                    .frame(width: size * 0.25, height: size * 0.25)
                    .overlay {
                        Circle()
                            .stroke(Color.black, lineWidth: 2)
                    }
            }
        }
    }
}

// MARK: - Premium Frame

struct PremiumPhotoFrame: View {
    let url: String?
    let size: CGFloat
    let isPremium: Bool
    
    var body: some View {
        GlassAsyncImage(url: url)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay {
                if isPremium {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.purple, .pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .shadow(color: .purple.opacity(0.5), radius: 8)
                }
            }
            .glassEffect()
    }
}

// MARK: - Photo Gallery View (Swipeable Gallery with Page Indicator)
// Requirements: 3.3 - Kaydırmalı galeri (swipeable gallery) with page indicators (dots)

struct PhotoGalleryView: View {
    let photos: [UserPhoto]
    let profilePhotoURL: String
    @Binding var currentIndex: Int
    var height: CGFloat = 400
    var showPageIndicator: Bool = true
    
    private var allPhotos: [String] {
        if photos.isEmpty {
            return [profilePhotoURL]
        }
        return photos.sorted { $0.orderIndex < $1.orderIndex }.map { $0.url }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // TabView with PageTabViewStyle for swipeable gallery
            TabView(selection: $currentIndex) {
                ForEach(Array(allPhotos.enumerated()), id: \.offset) { index, url in
                    GlassAsyncImage(url: url)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: height)
            
            // Custom Page Indicator (dots)
            if showPageIndicator && allPhotos.count > 1 {
                PhotoPageIndicator(
                    totalPages: allPhotos.count,
                    currentPage: currentIndex
                )
                .padding(.bottom, 16)
            }
        }
    }
}

// MARK: - Photo Page Indicator (Dots)

struct PhotoPageIndicator: View {
    let totalPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.4))
                .blur(radius: 0.5)
        )
    }
}

// MARK: - Photo Gallery View with Local Images (UIImage)

struct LocalPhotoGalleryView: View {
    let images: [UIImage]
    @Binding var currentIndex: Int
    var height: CGFloat = 400
    var showPageIndicator: Bool = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // TabView with PageTabViewStyle for swipeable gallery
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: height)
            
            // Custom Page Indicator (dots)
            if showPageIndicator && images.count > 1 {
                PhotoPageIndicator(
                    totalPages: images.count,
                    currentPage: currentIndex
                )
                .padding(.bottom, 16)
            }
        }
    }
}
