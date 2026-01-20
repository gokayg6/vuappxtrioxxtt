import Foundation
import UIKit
import FirebaseStorage

// MARK: - Storage Service
/// Service for handling file uploads to Firebase Storage
@MainActor
final class StorageService {
    static let shared = StorageService()
    
    private let storage = Storage.storage()
    private var storageRef: StorageReference {
        storage.reference()
    }
    
    private init() {}
    
    // MARK: - Upload Methods
    
    /// Uploads an image to Firebase Storage
    /// - Parameters:
    ///   - image: The UIImage to upload
    ///   - path: The storage path (e.g., "profile_photos/user_id/photo.jpg")
    ///   - completion: Progress handler maps progress from 0.0 to 1.0
    /// - Returns: The download URL of the uploaded image
    func uploadImage(
        image: UIImage,
        path: String,
        compressionQuality: CGFloat = 0.8,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw StorageError.compressionFailed
        }
        
        return try await uploadData(imageData, path: path, contentType: "image/jpeg", progressHandler: progressHandler)
    }
    
    /// Uploads raw data to Firebase Storage
    /// - Parameters:
    ///   - data: The data to upload
    ///   - path: The storage path
    ///   - contentType: The MIME type of the content
    ///   - completion: Progress handler
    /// - Returns: The download URL
    func uploadData(
        _ data: Data,
        path: String,
        contentType: String,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> String {
        let fileRef = storageRef.child(path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        // Create upload task
        return try await withCheckedThrowingContinuation { continuation in
            let uploadTask = fileRef.putData(data, metadata: metadata) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // Get download URL
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
            
            // Handle progress
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
    
    // MARK: - Delete Methods
    
    /// Deletes a file at the specified path
    func deleteFile(at path: String) async throws {
        let fileRef = storageRef.child(path)
        try await fileRef.delete()
    }
}

// MARK: - Storage Error
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
