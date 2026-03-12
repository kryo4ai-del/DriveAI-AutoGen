import Foundation

enum TrafficSignLearningMode {
    case assist    // immediately show recognized sign + explanation
    case learning  // show options first, user submits, then reveal
}
