import Foundation

struct QueryFilter: Equatable {
    var locations: [Location]
    var sizeClasses: [SizeClass]
    var minDifficulty: Int?
    var maxDifficulty: Int?

    init(
        locations: [Location] = Location.allCases,
        sizeClasses: [SizeClass] = SizeClass.allCases,
        minDifficulty: Int? = nil,
        maxDifficulty: Int? = nil
    ) {
        self.locations = locations
        self.sizeClasses = sizeClasses
        self.minDifficulty = minDifficulty
        self.maxDifficulty = maxDifficulty
    }

    var isEmpty: Bool {
        locations.isEmpty && sizeClasses.isEmpty && minDifficulty == nil && maxDifficulty == nil
    }
}