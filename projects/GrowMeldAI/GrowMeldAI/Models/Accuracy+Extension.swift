// ⚠️ If Accuracy conforms to Hashable, == must match hash()
extension Accuracy: Hashable {
    func hash(into hasher: inout Hasher) {
        // Hash the rounded value, not raw percentage
        hasher.combine(Int(percentage * 100))  // 66.67 → 6667
    }
}