import Foundation
import UIKit

struct ImageData {
    let id: UUID = UUID()
    let image: UIImage
    let date: Date
    let fileSize: Int? // Optional to store size if available
}