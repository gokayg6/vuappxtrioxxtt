import Foundation
import UIKit
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestore
import FirebaseAuth


// MARK: - Storage Service (Injected)
import FirebaseStorage

// MARK: - Storage Service (Injected)
@MainActor
final class StorageService {
    static let shared = StorageService()
    
    private let storage = Storage.storage()
    private var storageRef: StorageReference {
        storage.reference()
    }
    
    // Config - VibeU Bucket
    private let bucket = "vibeu-d55ea.firebasestorage.app"
    
    private init() {}
    
    // MARK: - Upload Methods
    func uploadImage(
        image: UIImage,
        path: String,
        compressionQuality: CGFloat = 0.8,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> String {
        // Resize if too big (simple check)
        var finalImage = image
        if image.size.width > 1500 || image.size.height > 1500 {
            let scale = 1500 / max(image.size.width, image.size.height)
            let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.8)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            finalImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }

        guard let imageData = finalImage.jpegData(compressionQuality: compressionQuality) else {
            throw StorageError.compressionFailed
        }
        
        return try await uploadData(imageData, path: path, contentType: "image/jpeg", progressHandler: progressHandler)
    }
    
    func uploadData(
        _ data: Data,
        path: String,
        contentType: String,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> String {
        let fileRef = storageRef.child(path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        return try await withCheckedThrowingContinuation { continuation in
            let uploadTask = fileRef.putData(data, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                fileRef.downloadURL { url, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    if let downloadURL = url?.absoluteString {
                        continuation.resume(returning: downloadURL)
                    } else {
                        continuation.resume(throwing: StorageError.unknown)
                    }
                }
            }
            
            if let progressHandler = progressHandler {
                uploadTask.observe(.progress) { snapshot in
                    guard let progress = snapshot.progress else { return }
                    let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                    Task { @MainActor in
                        progressHandler(percentComplete)
                    }
                }
            }
        }
    }
    
    func deleteFile(at path: String) async throws {
        let fileRef = storageRef.child(path)
        try await fileRef.delete()
    }
}

enum StorageError: Error, LocalizedError {
    case compressionFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Resim sıkıştırılamadı."
        case .unknown:
            return "Bilinmeyen bir hata oluştu."
        }
    }
}

// MARK: - Photo Upload Service
// Requirements: 3.2 - Max 2048px resize, JPEG compression (0.8 quality), Progress indicator

/// Service for handling photo uploads with image processing
/// - Resizes images to max 2048px while maintaining aspect ratio
/// - Compresses to JPEG with 0.8 quality
/// - Provides upload progress tracking
@MainActor
final class PhotoUploadService: ObservableObject {
    static let shared = PhotoUploadService()
    
    // MARK: - Configuration
    private let maxDimension: CGFloat = 2048
    private let compressionQuality: CGFloat = 0.8

    private let db = Firestore.firestore()
    
    // MARK: - Published Properties
    @Published var uploadProgress: Double = 0
    @Published var isUploading: Bool = false
    @Published var lastError: PhotoUploadError?
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Process and upload a photo
    /// - Parameters:
    ///   - image: The UIImage to upload
    ///   - userId: The user's ID
    ///   - orderIndex: The order index for the photo
    /// - Returns: The uploaded photo model
    func uploadPhoto(
        image: UIImage,
        userId: String,
        orderIndex: Int
    ) async throws -> PhotoModel {
        isUploading = true
        uploadProgress = 0
        lastError = nil
        
        defer {
            isUploading = false
        }
        
        // Step 1: Resize image (20% progress)
        uploadProgress = 0.1
        let resizedImage = resizeImage(image, maxDimension: maxDimension)
        uploadProgress = 0.2
        
        // Step 2: Compress to JPEG (40% progress)
        guard let imageData = compressImage(resizedImage, quality: compressionQuality) else {
            let error = PhotoUploadError.compressionFailed
            lastError = error
            throw error
        }
        uploadProgress = 0.4
        
        // Step 3: Upload to Firebase Storage (70% progress)
        let downloadURL = try await StorageService.shared.uploadImage(
            image: resizedImage,
            path: "users/\(userId)/photos/\(UUID().uuidString).jpg",
            compressionQuality: compressionQuality
        ) { [weak self] progress in
             Task { @MainActor in
                 self?.uploadProgress = 0.4 + (progress * 0.3)
             }
        }
        
        uploadProgress = 0.7
        
        // Step 4: Save metadata to Firestore (100% progress)
        let photo = try await saveToFirestore(
            url: downloadURL,
            userId: userId,
            orderIndex: orderIndex
        )
        
        uploadProgress = 1.0
        return photo
    }
    
    /// Process image without uploading (for local preview/validation)
    /// - Parameter image: The UIImage to process
    /// - Returns: Processed image data
    func processImage(_ image: UIImage) -> Data? {
        let resizedImage = resizeImage(image, maxDimension: maxDimension)
        return compressImage(resizedImage, quality: compressionQuality)
    }
    
    /// Validate image meets minimum requirements
    /// - Parameter image: The UIImage to validate
    /// - Returns: Validation result
    func validateImage(_ image: UIImage) -> PhotoValidationResult {
        // Check minimum resolution (500x500)
        if image.size.width < 500 || image.size.height < 500 {
            return .invalid(reason: "Fotoğraf en az 500x500 piksel olmalı")
        }
        
        return .valid
    }
    
    // MARK: - Private Methods
    
    /// Resize image to max dimension while maintaining aspect ratio
    /// - Parameters:
    ///   - image: Original image
    ///   - maxDimension: Maximum width or height
    /// - Returns: Resized image
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let originalSize = image.size
        
        // Check if resize is needed
        if originalSize.width <= maxDimension && originalSize.height <= maxDimension {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let aspectRatio = originalSize.width / originalSize.height
        var newSize: CGSize
        
        if originalSize.width > originalSize.height {
            // Landscape
            newSize = CGSize(
                width: maxDimension,
                height: maxDimension / aspectRatio
            )
        } else {
            // Portrait or square
            newSize = CGSize(
                width: maxDimension * aspectRatio,
                height: maxDimension
            )
        }
        
        // Render resized image
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
    
    /// Compress image to JPEG with specified quality
    /// - Parameters:
    ///   - image: Image to compress
    ///   - quality: Compression quality (0.0 - 1.0)
    /// - Returns: Compressed JPEG data
    private func compressImage(_ image: UIImage, quality: CGFloat) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
    
    /// Upload image data to server
    /// - Parameters:
    ///   - imageData: JPEG image data
    ///   - userId: User ID
    ///   - orderIndex: Photo order index
    /// - Returns: Uploaded photo model
    /// Save photo metadata to Firestore
    /// - Parameters:
    ///   - url: Download URL from Storage
    ///   - userId: User ID
    ///   - orderIndex: Photo order index
    /// - Returns: Uploaded photo model
    private func saveToFirestore(
        url: String,
        userId: String,
        orderIndex: Int
    ) async throws -> PhotoModel {
        let photoId = UUID().uuidString
        let now = Date().ISO8601Format()
        
        let photoData: [String: Any] = [
            "id": photoId,
            "userId": userId,
            "url": url,
            "thumbnailUrl": url,
            "orderIndex": orderIndex,
            "isPrimary": orderIndex == 0,
            "moderationStatus": "pending",
            "createdAt": now
        ]
        
        // Data for main user document array (Keys must match UserPhoto CodingKeys)
        let userPhotoData: [String: Any] = [
            "id": photoId,
            "url": url,
            "thumbnail_url": url,
            "order_index": orderIndex,
            "is_primary": orderIndex == 0
        ]
        
        do {
            // 1. Save to subcollection (Legacy/Backup) - Make NON-FATAL
            do {
                try await db.collection("users").document(userId).collection("photos").document(photoId).setData(photoData)
            } catch {
                print("PhotoUploadService: Subcollection write failed (ignoring as legacy): \(error)")
            }
            
            // 2. Save to main user document "photos" array (Redundancy Fix)
            // Use FieldValue.arrayUnion to append safely
            try await db.collection("users").document(userId).updateData([
                "photos": FieldValue.arrayUnion([userPhotoData])
            ])
            
            // 3. Update profile photo URL if primary
            if orderIndex == 0 {
                try await db.collection("users").document(userId).updateData([
                    "profile_photo_url": url
                ])
            }
            
            return PhotoModel(
                id: photoId,
                userId: userId,
                url: url,
                thumbnailUrl: url,
                orderIndex: orderIndex,
                isPrimary: orderIndex == 0,
                moderationStatus: "pending",
                createdAt: now
            )
        } catch {
            print("PhotoUploadService: Save error - \(error)")
            throw PhotoUploadError.serverError(statusCode: 500)
        }
    }
}


// MARK: - Photo Upload Error

enum PhotoUploadError: Error, LocalizedError {
    case invalidURL
    case compressionFailed
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingFailed(Error)
    case networkError(Error)
    case imageTooSmall
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .compressionFailed:
            return "Fotoğraf sıkıştırılamadı"
        case .invalidResponse:
            return "Sunucudan geçersiz yanıt"
        case .serverError(let code):
            return "Sunucu hatası: \(code)"
        case .decodingFailed:
            return "Yanıt işlenemedi"
        case .networkError:
            return "Ağ hatası"
        case .imageTooSmall:
            return "Fotoğraf en az 500x500 piksel olmalı"
        }
    }
}

// MARK: - Photo Validation Result

enum PhotoValidationResult {
    case valid
    case invalid(reason: String)
    
    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .invalid(let reason) = self { return reason }
        return nil
    }
}

// MARK: - Upload Progress View

/// A reusable progress indicator view for photo uploads
struct PhotoUploadProgressView: View {
    @ObservedObject var uploadService: PhotoUploadService
    
    var body: some View {
        if uploadService.isUploading {
            VStack(spacing: 16) {
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(Color(white: 0.2), lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: uploadService.uploadProgress)
                        .stroke(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.2), value: uploadService.uploadProgress)
                    
                    Text("\(Int(uploadService.uploadProgress * 100))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                // Status text
                Text(statusText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(white: 0.6))
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(white: 0.1))
                    .shadow(color: .black.opacity(0.3), radius: 20)
            )
        }
    }
    
    private var statusText: String {
        if uploadService.uploadProgress < 0.2 {
            return "Fotoğraf hazırlanıyor..."
        } else if uploadService.uploadProgress < 0.4 {
            return "Sıkıştırılıyor..."
        } else if uploadService.uploadProgress < 1.0 {
            return "Yükleniyor..."
        } else {
            return "Tamamlandı!"
        }
    }
}

// MARK: - Photo Upload Button

/// A button that handles photo selection and upload with progress
struct PhotoUploadButton: View {
    let userId: String
    let orderIndex: Int
    let onSuccess: (PhotoModel) -> Void
    let onError: (Error) -> Void
    
    @StateObject private var uploadService = PhotoUploadService.shared
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showSourcePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            Button {
                showSourcePicker = true
            } label: {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color(white: 0.12))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color(white: 0.4))
                    }
                    
                    Text("Fotoğraf Ekle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(white: 0.4))
                }
            }
            .disabled(uploadService.isUploading)
            
            if uploadService.isUploading {
                PhotoUploadProgressView(uploadService: uploadService)
            }
        }
        .confirmationDialog("Fotoğraf Kaynağı", isPresented: $showSourcePicker) {
            Button("Kamera") { showCamera = true }
            Button("Galeri") { showImagePicker = true }
            Button("İptal", role: .cancel) { }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                Task {
                    await uploadImage(image)
                }
            }
        }
    }
    
    private func uploadImage(_ image: UIImage) async {
        // Validate first
        let validation = uploadService.validateImage(image)
        guard validation.isValid else {
            onError(PhotoUploadError.imageTooSmall)
            return
        }
        
        do {
            let photo = try await uploadService.uploadPhoto(
                image: image,
                userId: userId,
                orderIndex: orderIndex
            )
            onSuccess(photo)
        } catch {
            onError(error)
        }
        
        selectedImage = nil
    }
}

// MARK: - Image Picker (UIKit Bridge)

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        if sourceType == .camera {
            picker.cameraDevice = .front
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
