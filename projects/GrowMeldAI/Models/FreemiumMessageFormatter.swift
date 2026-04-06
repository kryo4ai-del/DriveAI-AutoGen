// Domain/Freemium/Utilities/FreemiumMessageFormatter.swift
public enum FreemiumMessageFormatter {
    public static func trialStatus(_ state: TrialState) -> String {
        state.statusMessage
    }
    
    public static func dailyProgress(_ progress: DailyProgress) -> String {
        progress.questionsMotivationalMessage
    }
    
    public static func limitApproaching(remaining: Int) -> String? {
        switch remaining {
        case 1:
            return "Last attempt remaining today"
        case 2...3:
            return "\(remaining) attempts left"
        default:
            return nil
        }
    }
}