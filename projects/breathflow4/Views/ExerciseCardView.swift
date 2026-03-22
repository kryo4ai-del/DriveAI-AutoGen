import SwiftUI

struct ExerciseCardView: View {
    let exercise: BreathingExercise
    @ScaledMetric(relativeTo: .headline) private var nameSize: CGFloat = 17
    @ScaledMetric(relativeTo: .caption) private var captionSize: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
                .font(.system(size: nameSize, weight: .semibold))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
    }
}
