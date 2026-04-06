import Foundation

@MainActor
class AgeGateViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedDate: Date
    @Published var consentState: AgeGateState = .pending
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var showConfirmation = false
    
    // MARK: - Dependencies
    private let consentService: ConsentStorageServiceProtocol
    private let regionManager: RegionManagerProtocol
    
    // MARK: - Private State
    private var saveTask: Task<Void, Never>?
    
    init(
        consentService: ConsentStorageServiceProtocol = ConsentStorageService(),
        regionManager: RegionManagerProtocol = RegionManager()
    ) {
        self.consentService = consentService
        self.regionManager = regionManager
        
        // Initialize date to minimum age threshold
        self.selectedDate = Self.defaultBirthDate(for: regionManager.minimumAgeThreshold)
    }
    
    // MARK: - Public Methods
    
    func checkExistingConsent() {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            
            let isValid = self.consentService.isConsentValid()
            
            await MainActor.run {
                if isValid {
                    self.consentState = .approved
                }
            }
        }
    }
    
    func submitAge() {
        saveTask?.cancel()  // Cancel any in-flight save
        isLoading = true
        errorMessage = nil
        
        let age = calculateAge(from: selectedDate)
        
        if age >= regionManager.minimumAgeThreshold {
            saveConsent()
        } else {
            rejectAge()
        }
    }
    
    func retryAgeEntry() {
        saveTask?.cancel()
        resetForm()
    }
    
    // MARK: - Computed Properties
    
    var maximumBirthDate: Date {
        Calendar.current.date(
            byAdding: .year,
            value: -regionManager.minimumAgeThreshold,
            to: Date()
        ) ?? Date()
    }
    
    // MARK: - Private Methods
    
    private func saveConsent() {
        saveTask = Task {
            defer { isLoading = false }
            
            let record = ConsentRecord(
                birthDate: selectedDate,
                recordedDate: Date(),
                deviceHash: getDeviceHash()
            )
            
            do {
                try consentService.saveConsentRecord(record)
                
                // Check cancellation
                try Task.checkCancellation()
                
                // Show confirmation
                showConfirmation = true
                
                // Wait 1.5 seconds (with cancellation support)
                try await Task.sleep(nanoseconds: 1_500_000_000)
                try Task.checkCancellation()
                
                // Transition to approved
                consentState = .approved
            } catch is CancellationError {
                // User cancelled, reset UI
                showConfirmation = false
            } catch {
                errorMessage = NSLocalizedString(
                    "age_gate_error_save_failed",
                    comment: "Error when saving consent record"
                )
            }
        }
    }
    
    private func rejectAge() {
        consentState = .rejected
        isLoading = false
        
        let threshold = regionManager.minimumAgeThreshold
        errorMessage = String(
            format: NSLocalizedString(
                "age_gate_error_minimum_age",
                comment: "Error message for underage user"
            ),
            threshold
        )
    }
    
    private func resetForm() {
        consentState = .pending
        errorMessage = nil
        showConfirmation = false
        selectedDate = Self.defaultBirthDate(for: regionManager.minimumAgeThreshold)
    }
    
    private func calculateAge(from birthDate: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year], from: birthDate, to: now)
        return components.year ?? 0
    }
    
    private func getDeviceHash() -> String {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }
    
    private static func defaultBirthDate(for minimumAge: Int) -> Date {
        guard let date = Calendar.current.date(
            byAdding: .year,
            value: -minimumAge,
            to: Date()
        ) else {
            return Date()
        }
        return date
    }
    
    deinit {
        saveTask?.cancel()
    }
}

// MARK: - State Machine
enum AgeGateState: Equatable {
    case pending      // Awaiting user input
    case approved     // Consent saved and valid
    case rejected     // Age verification failed
}