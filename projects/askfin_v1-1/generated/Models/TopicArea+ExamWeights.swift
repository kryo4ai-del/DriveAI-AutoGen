// TopicArea+ExamWeights.swift
// Official topic distribution for the German class B driving exam.
//
// TODO: Replace placeholder weights with verified values from the current
// Fahrschüler-Ausbildungsordnung (FahrschAusbO) / TÜV-DEKRA question catalogue.
// The values below are structurally correct (sum to 1.0, all topics present)
// but the per-topic proportions must be verified against the official spec
// before shipping. Incorrect weights produce wrong question distributions.

extension TopicArea {

    static let officialExamWeights: [String: Double] = {
        let weights: [TopicArea: Double] = [
            .gefahrenlehre:              0.10,
            .vorfahrtUndVerkehrszeichen: 0.12,
            .verkehrszeichen:            0.08,
            .umwelt:                     0.04,
            .technik:                    0.06,
            .verkehrsverhalten:          0.10,
            .abbiegen:                   0.06,
            .ueberholen:                 0.06,
            .geschwindigkeit:            0.08,
            .abstand:                    0.06,
            .beleuchtung:                0.04,
            .sonstigeVerkehrsregeln:     0.06,
            .autobahn:                   0.04,
            .bahnen:                     0.04,
            .grundstoffteil:             0.12,
            .sozialeDaten:               0.04,
        ]

        let sum = weights.values.reduce(0.0, +)
        assert(
            abs(sum - 1.0) < 0.001,
            "TopicArea.officialExamWeights do not sum to 1.0 (sum: \(sum)). Fix before shipping."
        )
        assert(
            weights.count == TopicArea.allCases.count,
            "TopicArea.officialExamWeights is missing \(TopicArea.allCases.count - weights.count) topic(s)."
        )

        return Dictionary(
            uniqueKeysWithValues: weights.map { ($0.key.rawValue, $0.value) }
        )
    }()
}