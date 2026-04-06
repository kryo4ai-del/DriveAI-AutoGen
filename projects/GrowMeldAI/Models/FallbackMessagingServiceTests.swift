// Tests/Services/FallbackMessagingServiceTests.swift
import XCTest
@testable import DriveAI

class FallbackMessagingServiceTests: XCTestCase {
    
    let service = FallbackMessagingService()
    
    // ✅ HAPPY PATH: Message varies by stage
    func test_early_prep_message() {
        let msg = service.message(for: .earlyPrep, isInitialFallback: false)
        
        XCTAssertEqual(msg.primary, "Offline-Modus: Perfekt für fokussiertes Lernen")
        XCTAssertEqual(msg.tone, .reassuring)
    }
    
    func test_mid_study_message() {
        let msg = service.message(for: .midStudy, isInitialFallback: false)
        
        XCTAssertEqual(msg.primary, "Klassische Fragen + deine Statistik")
        XCTAssertEqual(msg.tone, .motivational)
    }
    
    func test_final_cramming_message() {
        let msg = service.message(for: .finalCramming, isInitialFallback: false)
        
        XCTAssertEqual(msg.primary, "Prüfungs-ähnliche Fragen sofort verfügbar")
        XCTAssertEqual(msg.tone, .reassuring)
    }
    
    // ✅ BEHAVIOR: Initial fallback adds motivational secondary
    func test_initial_fallback_adds_secondary_message() {
        let msg = service.message(for: .finalCramming, isInitialFallback: true)
        
        XCTAssertEqual(msg.secondary, "Du bist bereit")
    }
    
    func test_non_initial_fallback_no_secondary() {
        let msg = service.message(for: .finalCramming, isInitialFallback: false)
        
        XCTAssertNil(msg.secondary)
    }
    
    // ✅ TOAST: Same for all stages
    func test_toast_message_consistent() {
        let earlyToast = service.toastMessage(for: .earlyPrep)
        let midToast = service.toastMessage(for: .midStudy)
        let finalToast = service.toastMessage(for: .finalCramming)
        
        XCTAssertEqual(earlyToast, midToast)
        XCTAssertEqual(midToast, finalToast)
        XCTAssertEqual(earlyToast, "Offline-Modus aktiviert — Fragen funktionieren normal")
    }
}