// Services/CameraDataManager.swift
import Foundation
   @MainActor
   final class CameraDataManager {
       func deleteCameraDataForUser(_ userID: String) async throws {
           // Delete all stored images
           // try FileManager.default.removeItem(atPath: imageDirectory)
           
           // Delete processing logs
           // try CoreData.deleteAll(predicate: NSPredicate(format: "userId == %@", userID))
           
           // Delete from third-party services
           // try await cloudProvider.deleteCameraData(userID: userID)
       }
   }