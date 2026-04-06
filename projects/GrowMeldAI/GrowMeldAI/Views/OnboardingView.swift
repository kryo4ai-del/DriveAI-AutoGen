// OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @StateObject private var consentManager = PrivacyConsentManager()
    @State private var showConsent = false
    @State private var examDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)

                    Text("Dein Weg zur Fahrerlaubnis — wir begleiten dich")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)

                    Text("Jede Frage, die du löst, bringt dich einen Schritt näher zu deinem Ziel.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                VStack(spacing: 16) {
                    DatePicker(
                        "Wann ist dein Prüfungstermin?",
                        selection: $examDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    Text("Noch \(daysUntilExam) Tage bis zu deiner Prüfung")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                Spacer()

                NavigationLink {
                    ContentView()
                        .environmentObject(consentManager)
                } label: {
                    Text("Los geht's")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("DriveAI")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if consentManager.shouldShowConsent() {
                    showConsent = true
                }
            }
            .sheet(isPresented: $showConsent) {
                NavigationView {
                    PrivacyConsentView {
                        // Consent given
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Skip") {
                                showConsent = false
                            }
                        }
                    }
                }
            }
        }
    }

    private var daysUntilExam: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: examDate).day ?? 0
    }
}