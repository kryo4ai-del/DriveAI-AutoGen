// Services/FallbackMessagingService.swift
import Foundation

protocol MessagingStrategy {
    func message(for stage: ExamStage, isInitialFallback: Bool) -> FallbackMessage
    func toastMessage(for stage: ExamStage) -> String
}

// Localized variant (for future i18n support)
class LocalizedMessagingService: MessagingStrategy {
    let locale: Locale
    let baseService = FallbackMessagingService()
    
    init(locale: Locale = .current) {
        self.locale = locale
    }
    
    func message(for stage: ExamStage, isInitialFallback: Bool) -> FallbackMessage {
        // Delegate to base for now; override for locale-specific variants
        baseService.message(for: stage, isInitialFallback: isInitialFallback)
    }
    
    func toastMessage(for stage: ExamStage) -> String {
        baseService.toastMessage(for: stage)
    }
}