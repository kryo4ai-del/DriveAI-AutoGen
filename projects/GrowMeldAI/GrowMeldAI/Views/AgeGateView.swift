// Features/COPPA/Views/AgeGateView.swift
import SwiftUI

struct AgeGateView: View {
    @ObservedObject var viewModel: AgeGateViewModel
    @Environment(\.locale) var locale
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    Spacer()
                    
                    // Date Picker
                    datePickerSection
                    
                    Spacer()
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        errorBanner(error)
                    }
                    
                    // Submit Button
                    submitButton
                }
                .padding(24)
            }
            .navigationTitle(NSLocalizedString("age_gate_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.checkExistingConsent()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .cyan]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(NSLocalizedString("age_gate_title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            
            Text(NSLocalizedString("age_gate_subtitle", comment: ""))
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(.top, 20)
    }
    
    private var datePickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("age_gate_birthdate_label", comment: ""))
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.horizontal, 4)
            
            DatePicker(
                "",
                selection: $viewModel.selectedDate,
                in: ...Date().addingTimeInterval(Double(-viewModel.minimumAgeThreshold * 365) * 86400),
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .environment(\.locale, Locale(identifier: "de_DE"))
            .labelsHidden()
            .frame(height: 160)
            .clipped()
            .padding(.horizontal, -8)
            .accessibilityLabel(NSLocalizedString("age_gate_accessibility_date_picker", comment: ""))
        }
        .padding(.horizontal)
    }
    
    private func errorBanner(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 16))
                
                Text(message)
                    .font(.callout)
                    .foregroundColor(.red)
                    .lineLimit(nil)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08))
        .cornerRadius(8)
        .animation(.easeInOut(duration: 0.3), value: viewModel.errorMessage)
        .accessibilityLiveRegion(.polite)
    }
    
    private var submitButton: some View {
        Button(action: viewModel.submitAge) {
            if viewModel.isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(.white)
                    Text(NSLocalizedString("age_gate_button_loading", comment: ""))
                }
            } else {
                Text(NSLocalizedString("age_gate_button_confirm", comment: ""))
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(viewModel.isLoading ? Color.accentColor.opacity(0.6) : Color.accentColor)
        .foregroundColor(.white)
        .cornerRadius(10)
        .disabled(viewModel.isLoading)
        .padding(.horizontal)
        .padding(.bottom, 20)
        .accessibilityLabel(NSLocalizedString("age_gate_button_confirm", comment: ""))
    }
}

// MARK: - ViewModel Extension for View Convenience
extension AgeGateViewModel {
    var minimumAgeThreshold: Int {
        (regionManager as? RegionManager)?.minimumAgeThreshold ?? 16
    }
}

#Preview {
    AgeGateView(viewModel: AgeGateViewModel())
}