// Features/Onboarding/Services/ProfileImageService.swift
import UIKit
import Foundation
import SwiftUI

protocol ProfileImageServiceProtocol: Sendable {
    func saveProfileImage(_ image: UIImage?, for userID: String) async throws
    func loadProfileImage(for userID: String) async -> UIImage?
    func deleteProfileImage(for userID: String) async throws
}

actor ProfileImageService: ProfileImageServiceProtocol {
    private let fileManager: FileManager
    private let imageCompressionQuality: CGFloat = 0.85
    private let maxImageDimension: CGFloat = 1200
    private let maxImageFileSize: Int = 2_000_000 // 2MB
    
    private var profileImagesDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("ProfileImages", isDirectory: true)
    }
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        try? fileManager.createDirectory(
            at: profileImagesDirectory,
            withIntermediateDirectories: true
        )
    }
    
    func saveProfileImage(_ image: UIImage?, for userID: String) async throws {
        guard let image = image else { return }
        
        let compressed = compressImage(image)
        guard let jpegData = compressed.jpegData(
            compressionQuality: imageCompressionQuality
        ) else {
            throw ProfileImageError.compressionFailed
        }
        
        guard jpegData.count <= maxImageFileSize else {
            throw ProfileImageError.fileTooLarge
        }
        
        let fileName = "\(userID).jpg"
        let filePath = profileImagesDirectory.appendingPathComponent(fileName)
        
        try jpegData.write(to: filePath, options: .atomic)
    }
    
    func loadProfileImage(for userID: String) async -> UIImage? {
        let fileName = "\(userID).jpg"
        let filePath = profileImagesDirectory.appendingPathComponent(fileName)
        
        guard fileManager.fileExists(atPath: filePath.path) else {
            return nil
        }
        
        return UIImage(contentsOfFile: filePath.path)
    }
    
    func deleteProfileImage(for userID: String) async throws {
        let fileName = "\(userID).jpg"
        let filePath = profileImagesDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: filePath.path) {
            try fileManager.removeItem(at: filePath)
        }
    }
    
    // MARK: - Private Helpers
    
    private func compressImage(_ image: UIImage) -> UIImage {
        let scaledSize = calculateScaledSize(for: image)
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }
    
    private func calculateScaledSize(for image: UIImage) -> CGSize {
        let aspectRatio = image.size.width / image.size.height
        
        if image.size.width > maxImageDimension {
            let newWidth = maxImageDimension
            let newHeight = newWidth / aspectRatio
            return CGSize(width: newWidth, height: newHeight)
        }
        
        return image.size
    }
}

enum ProfileImageError: LocalizedError {
    case compressionFailed
    case fileTooLarge
    case saveFailed
    case loadFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Bild konnte nicht komprimiert werden"
        case .fileTooLarge:
            return "Bild ist zu groß (max. 2MB)"
        case .saveFailed:
            return "Bild konnte nicht gespeichert werden"
        case .loadFailed:
            return "Bild konnte nicht geladen werden"
        case .deleteFailed:
            return "Bild konnte nicht gelöscht werden"
        }
    }
}

// Mock for Testing
final class MockProfileImageService: ProfileImageServiceProtocol {
    var shouldFail = false
    private(set) var savedImages: [String: UIImage] = [:]
    
    func saveProfileImage(_ image: UIImage?, for userID: String) async throws {
        if shouldFail {
            throw ProfileImageError.saveFailed
        }
        if let image = image {
            savedImages[userID] = image
        }
    }
    
    func loadProfileImage(for userID: String) async -> UIImage? {
        savedImages[userID]
    }
    
    func deleteProfileImage(for userID: String) async throws {
        if shouldFail {
            throw ProfileImageError.deleteFailed
        }
        savedImages.removeValue(forKey: userID)
    }
}