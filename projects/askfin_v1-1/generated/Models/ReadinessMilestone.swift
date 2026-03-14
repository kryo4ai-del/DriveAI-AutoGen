// ReadinessMilestone.swift
// Ordered milestones representing exam readiness progression.
//
// Ranges are contiguous and cover 0–100 with no gaps or overlaps.
// The milestone(for:) function asserts this invariant in debug builds —
// if a developer adds a case with an invalid range, it fires immediately
// in tests rather than producing a silent wrong milestone.
//
// Copy principle: each milestone addresses the specific psychology of that
// stage. fastBereit copy names the plateau-dropout pattern explicitly because
// that is the highest-risk retention point in AskFin Premium.

enum ReadinessMilestone: String, Codable, CaseIterable {

    case amAnfang           // 0–20
    case grundlagenGelegt   // 21–40
    case aufDemWeg          // 41–65
    case fastBereit         // 66–85
    case pruefungsbereit    // 86–100

    // MARK: - Score Mapping

    var scoreRange: ClosedRange<Int> {
        switch self {
        case .amAnfang:         0...20
        case .grundlagenGelegt: 21...40
        case .aufDemWeg:        41...65
        case .fastBereit:       66...85
        case .pruefungsbereit:  86...100
        }
    }

    static func milestone(for score: Int) -> ReadinessMilestone {
        assertRangesAreContiguous()
        let clamped = max(0, min(100, score))
        assert(score == clamped, "ReadinessMilestone: score \(score) is outside 0–100. Clamping.")
        return allCases.first { $0.scoreRange.contains(clamped) } ?? .amAnfang
    }

    // MARK: - Display

    var displayName: String {
        switch self {
        case .amAnfang:         "Am Anfang"
        case .grundlagenGelegt: "Grundlagen gelegt"
        case .aufDemWeg:        "Auf dem Weg"
        case .fastBereit:       "Fast bereit"
        case .pruefungsbereit:  "Prüfungsbereit"
        }
    }

    /// Full motivational subtitle — result screens and Dashboard.
    var motivationalSubtitle: String {
        switch self {
        case .amAnfang:
            "Leg los – jede Generalprobe zeigt dir, wo du stehst, nicht wo du scheiterst."
        case .grundlagenGelegt:
            "Du baust eine solide Basis. Die nächsten Themen machen den Unterschied."
        case .aufDemWeg:
            "Guter Fortschritt. Gezieltes Üben bringt dich jetzt am schnellsten weiter."
        case .fastBereit:
            // Names the plateau-dropout pattern. Most learners stop here.
            "Die meisten Prüflinge scheitern hier – nicht weil sie zu wenig wissen, " +
            "sondern weil sie aufhören. Mach noch eine Generalprobe."
        case .pruefungsbereit:
            "Du bist bereit. Halte das Niveau mit einer letzten Generalprobe."
        }
    }

    // MARK: - Private

    /// Fires in debug builds if ranges are not contiguous over 0–100.
    /// Protects against a new case being added with an invalid range.
    private static func assertRangesAreContiguous() {
        assert(
            {
                let sorted = allCases.sorted { $0.scoreRange.lowerBound < $1.scoreRange.lowerBound }
                guard sorted.first?.scoreRange.lowerBound == 0,
                      sorted.last?.scoreRange.upperBound == 100 else { return false }
                for i in 1..<sorted.count {
                    guard sorted[i].scoreRange.lowerBound == sorted[i - 1].scoreRange.upperBound + 1
                    else { return false }
                }
                return true
            }(),
            "ReadinessMilestone: score ranges are not contiguous over 0–100. Check all scoreRange cases."
        )
    }
}