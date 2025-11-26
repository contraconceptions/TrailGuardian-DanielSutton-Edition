import UIKit
import SwiftUI

/// Helper for photo compression and management
class PhotoHelper {
    /// Compress and resize a photo to reduce storage footprint
    /// - Parameter data: Original image data
    /// - Returns: Compressed image data, or nil if compression fails
    static func compressPhoto(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }

        // Calculate new size maintaining aspect ratio
        let size = image.size
        let maxWidth = Constants.Photo.maxWidth
        let maxHeight = Constants.Photo.maxHeight

        var newSize = size
        if size.width > maxWidth || size.height > maxHeight {
            let widthRatio = maxWidth / size.width
            let heightRatio = maxHeight / size.height
            let ratio = min(widthRatio, heightRatio)

            newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        }

        // Resize image
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        // Compress to JPEG
        return resizedImage.jpegData(compressionQuality: Constants.Photo.compressionQuality)
    }

    /// Save photo data to the camp site photos directory
    /// - Parameter data: Image data (should be pre-compressed)
    /// - Returns: Filename if successful, nil otherwise
    static func savePhoto(_ data: Data) -> String? {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosDirectory = documentsPath.appendingPathComponent("CampSitePhotos")

        // Create directory if needed
        try? fileManager.createDirectory(at: photosDirectory, withIntermediateDirectories: true)

        let filename = "\(UUID().uuidString).jpg"
        let photoPath = photosDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: photoPath)
            return filename
        } catch {
            print("Failed to save photo: \(error.localizedDescription)")
            return nil
        }
    }

    /// Load photo from filename
    /// - Parameter filename: Photo filename (not full path)
    /// - Returns: UIImage if found, nil otherwise
    static func loadPhoto(filename: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photoPath = documentsPath.appendingPathComponent("CampSitePhotos").appendingPathComponent(filename)

        guard let data = try? Data(contentsOf: photoPath) else { return nil }
        return UIImage(data: data)
    }

    /// Delete photo from storage
    /// - Parameter filename: Photo filename to delete
    static func deletePhoto(filename: String) {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photoPath = documentsPath.appendingPathComponent("CampSitePhotos").appendingPathComponent(filename)

        try? fileManager.removeItem(at: photoPath)
    }

    /// Get total size of all photos in bytes
    static func getTotalPhotoStorageSize() -> Int64 {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosDirectory = documentsPath.appendingPathComponent("CampSitePhotos")

        guard let files = try? fileManager.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }

        var totalSize: Int64 = 0
        for file in files {
            if let size = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }
        return totalSize
    }

    /// Format bytes to human-readable string (e.g., "2.5 MB")
    static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
