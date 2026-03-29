import Foundation

/// Describes the context in which BreathFlow was launched.
/// Drives copy and CTA behavior on the completion screen.
enum BreathFlowContext: Equatable {
    /// Launched from the exam simulation screen before an exam starts.
    case preExam
    /// Launched standalone from the profile or home screen.
    case standalone
}