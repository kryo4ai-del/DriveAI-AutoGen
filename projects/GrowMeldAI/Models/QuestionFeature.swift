import SwiftUI

public struct QuestionFeature {
    public static func rootView(
        questions: [Question],
        onComplete: @escaping (ExamResult) -> Void
    ) -> some View {
        let coordinator = QuestionCoordinator()
        return QuestionScreenView()
            .environmentObject(coordinator)
    }
}