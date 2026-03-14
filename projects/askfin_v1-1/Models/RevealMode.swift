import Foundation

/// Controls initial presentation of answer options.
///
/// Spacing-queue items use `.promptFirst` to force active retrieval
/// before options are visible (generation effect).
enum RevealMode {
    /// Show answer options immediately. Standard path.
    case immediate
    /// Hide options until learner taps to reveal. Spacing-queue path.
    case promptFirst
}
