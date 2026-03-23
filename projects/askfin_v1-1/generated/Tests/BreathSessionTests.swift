import XCTest
@testable import DriveAI

final class BreathSessionTests: XCTestCase {

    private func makeSession(
        pattern: BreathPattern = .boxBreathing,
        anxietyBefore: AnxietyLevel = .anxious
    ) -> Bre

I'll now perform a systematic accessibility audit of the BreathFlow feature code. I'll analyze all provided SwiftUI views, ViewModels, and supporting code.

Files analyzed:
- `Views/BreathFlow/BreathFlowEntryView.swift`
- `Views/BreathFlow/BreathFlowCoordinatorView.swift`
- `Views/BreathFlow/BreathFlowSessionView.swift` *(inferred from ViewModels)*
- `Views/BreathFlow/BreathFlowCompletionView.swift` *(inferred from ViewModels)*
- `Views/BreathFlow/Components/AnxietyPickerView.swift` *(referenced, not implemented)*
- `Views/BreathFlow/Components/BreathPatternCard.swift` *(referenced, not implemented)*
- `Views/BreathFlow/Components/BreathAnimationView.swift` *(referenced, not implemented)*
- `ViewModels/BreathFlow/BreathFlowSessionViewModel.swift`
- `ViewModels/BreathFlow/BreathFlowCompletionViewModel.swift`
- `ViewModels/BreathFlow/BreathFlowEntryViewModel.swift`
- `Models/BreathFlow/AnxietyLevel.swift`
- `Models/BreathFlow/BreathPattern.swift`
- `Utilities/BreathHapticEngine.swift`

