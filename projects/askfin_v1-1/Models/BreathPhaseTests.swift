import XCTest
@testable import DriveAI

final class BreathPhaseTests: XCTestCase {

    // MARK: - Identity

    func test_id_derivedFromLabelAndDuration() {
        let phase = BreathPhase(label: "Einatmen", duration: 4, instruction: "Einatmen")
        XCTAssertEqual(phase.id, "Einatmen-4")
    }

    func test_id_isStableAcrossInstances() {
        let a = BreathPhase(label: "Halten", duration: 7, instruction: "Halten")
        let b = BreathPhase(label: "Halten", duration: 7, instruction: "Halten")
        XCTAssertEqual(a.id, b.id)
    }

    func test_id_differentDuration_producesDifferentID() {
        let a = BreathPhase(label: "Halten", duration: 4, instruction: "Halten")
        let b = BreathPhase(label: "Halten", duration: 7, instruction: "Halten")
        XCTAssertNotEqual(a.id, b.id)
    }

    func test_id_differentLabel_producesDifferentID() {
        let a = BreathPhase(label: "Einatmen", duration: 4, instruction: "x")
        let b = BreathPhase(label: "Ausatmen", duration: 4, instruction: "x")
        XCTAssertNotEqual(a.id, b.id)
    }

    // MARK: - Equality

    func test_equality_sameContent_isEqual() {
        let a = BreathPhase(label: "Ausatmen", duration: 8, instruction: "Langsam ausatmen")
        let b = BreathPhase(label: "Ausatmen", duration: 8, instruction: "Langsam ausatmen")
        XCTAssertEqual(a, b)
    }

    func test_equality_differentInstruction_isNotEqual() {
        let a = BreathPhase(label: "Ausatmen", duration: 8, instruction: "Langsam ausatmen")
        let b = BreathPhase(label: "Ausatmen", duration: 8, instruction: "Schnell ausatmen")
        XCTAssertNotEqual(a, b)
    }

    // MARK: - Codable

    func test_codable_roundTrip_preservesAllFields() throws {
        let phase = BreathPhase(label: "Einatmen", duration: 4, instruction: "Tief einatmen")
        let data = try JSONEncoder().encode(phase)
        let decoded = try JSONDecoder().decode(BreathPhase.self, from: data)
        XCTAssertEqual(decoded, phase)
    }

    func test_codable_roundTrip_idIsStable() throws {
        let phase = BreathPhase(label: "Halten", duration: 7, instruction: "Halten")
        let data = try JSONEncoder().encode(phase)
        let decoded = try JSONDecoder().decode(BreathPhase.self, from: data)
        XCTAssertEqual(phase.id, decoded.id)
    }

    // MARK: - Edge Cases

    func test_zeroDuration_isEncodable() throws {
        let phase = BreathPhase(label: "Pause", duration: 0, instruction: "")
        XCTAssertNoThrow(try JSONEncoder().encode(phase))
    }

    func test_veryLongDuration_doesNotOverflow() {
        let phase = BreathPhase(label: "X", duration: 3600, instruction: "")
        XCTAssertEqual(phase.id, "X-3600")
    }
}