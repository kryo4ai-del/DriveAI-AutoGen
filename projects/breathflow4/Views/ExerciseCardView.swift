import SwiftUI
// Before ❌
Text(exercise.name)
    .font(.headline)

// After ✅
Text(exercise.name)
    .font(.headline)
    .dynamicTypeSize(...) // iOS 16+, or remove for auto-scaling
    .lineLimit(nil)       // Allow wrapping
    .fixedSize(horizontal: false, vertical: true)

// OR use @ScaledMetric for custom sizing:
struct ExerciseCardView: View {
    @ScaledMetric(relativeTo: .headline) private var nameSize: CGFloat = 17
    @ScaledMetric(relativeTo: .caption) private var captionSize: CGFloat = 12
    
    var body: some View {
        Text(exercise.name)
            .font(.system(size: nameSize, weight: .semibold))
        
        Text(exercise.microcopy)
            .font(.system(size: captionSize))
    }
}