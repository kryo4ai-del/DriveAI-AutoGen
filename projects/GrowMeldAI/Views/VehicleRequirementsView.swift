// VehicleRequirementsView.swift
import SwiftUI
import CoreLocation
import Combine

// MARK: - Models

struct VehicleRequirements: Codable, Equatable {
    let minWidth: Double
    let minHeight: Double
    let minLength: Double
    let maxWidth: Double
    let maxHeight: Double
    let maxLength: Double

    static let standardCar = VehicleRequirements(
        minWidth: 1.6,
        minHeight: 1.4,
        minLength: 3.5,
        maxWidth: 2.1,
        maxHeight: 2.0,
        maxLength: 5.0
    )
}

struct VehicleCheckResult: Equatable {
    let isWithinLimits: Bool
    let exceededDimensions: [String: Double]
    let recommendation: String
}

// MARK: - ViewModel

@MainActor
final class VehicleRequirementsViewModel: ObservableObject {
    @Published var vehicleWidth: String = ""
    @Published var vehicleHeight: String = ""
    @Published var vehicleLength: String = ""
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var isCheckingRequirements = false
    @Published var checkResult: VehicleCheckResult?
    @Published var showLocationAlert = false
    @Published var showInvalidInputAlert = false

    private let locationManager = CLLocationManager()
    private let requirements: VehicleRequirements

    init(requirements: VehicleRequirements = .standardCar) {
        self.requirements = requirements
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func checkRequirements() async {
        guard validateInputs() else {
            showInvalidInputAlert = true
            return
        }

        isCheckingRequirements = true
        defer { isCheckingRequirements = false }

        // Simulate network/processing delay
        try? await Task.sleep(nanoseconds: 500_000_000)

        let result = await performVehicleCheck()
        checkResult = result
    }

    private func validateInputs() -> Bool {
        guard let width = Double(vehicleWidth),
              let height = Double(vehicleHeight),
              let length = Double(vehicleLength) else {
            return false
        }

        return width > 0 && height > 0 && length > 0
    }

    private func performVehicleCheck() async -> VehicleCheckResult {
        guard locationPermissionStatus == .authorizedWhenInUse || locationPermissionStatus == .authorizedAlways else {
            showLocationAlert = true
            return VehicleCheckResult(
                isWithinLimits: false,
                exceededDimensions: [:],
                recommendation: "Bitte erlaube den Standortzugriff für genauere Fahrzeugprüfung"
            )
        }

        let width = Double(vehicleWidth) ?? 0
        let height = Double(vehicleHeight) ?? 0
        let length = Double(vehicleLength) ?? 0

        var exceeded: [String: Double] = [:]

        if width > requirements.maxWidth {
            exceeded["Breite"] = width
        } else if width < requirements.minWidth {
            exceeded["Breite"] = width
        }

        if height > requirements.maxHeight {
            exceeded["Höhe"] = height
        } else if height < requirements.minHeight {
            exceeded["Höhe"] = height
        }

        if length > requirements.maxLength {
            exceeded["Länge"] = length
        } else if length < requirements.minLength {
            exceeded["Länge"] = length
        }

        let recommendation: String
        if exceeded.isEmpty {
            recommendation = "Alles im grünen Bereich! Dein Fahrzeug passt für die Fahrschule."
        } else {
            recommendation = "Achtung: Dein Fahrzeug überschreitet die empfohlenen Maße. Bitte prüfe die genauen Anforderungen deiner Fahrschule."
        }

        return VehicleCheckResult(
            isWithinLimits: exceeded.isEmpty,
            exceededDimensions: exceeded,
            recommendation: recommendation
        )
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - Location Manager Delegate

extension VehicleRequirementsViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationPermissionStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}

// MARK: - Views

struct VehicleRequirementsView: View {
    @StateObject private var viewModel = VehicleRequirementsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                inputForm
                checkButton
                if viewModel.isCheckingRequirements {
                    progressView
                }
                if let result = viewModel.checkResult {
                    resultView(result: result)
                }
            }
            .padding()
        }
        .navigationTitle("Fahrzeug-Check")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Standortzugriff benötigt", isPresented: $viewModel.showLocationAlert) {
            Button("Einstellungen") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Für eine genaue Fahrzeugprüfung benötigen wir deinen Standort.")
        }
        .alert("Ungültige Eingabe", isPresented: $viewModel.showInvalidInputAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Bitte gib gültige Werte für alle Fahrzeugmaße ein.")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prüfe, ob dein Fahrzeug passt")
                .font(.title2)
                .fontWeight(.bold)

            Text("Dein Fahrschul-Fahrzeug muss bestimmte Maße einhalten. Wir checken, ob dein Auto/Transporter passt – damit du sicher und rechtzeitig zum Prüfungstermin startklar bist.")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    private var inputForm: some View {
        VStack(spacing: 16) {
            measurementInputView(
                title: "Breite (m)",
                placeholder: "z.B. 1.8",
                value: $viewModel.vehicleWidth
            )

            measurementInputView(
                title: "Höhe (m)",
                placeholder: "z.B. 1.6",
                value: $viewModel.vehicleHeight
            )

            measurementInputView(
                title: "Länge (m)",
                placeholder: "z.B. 4.2",
                value: $viewModel.vehicleLength
            )
        }
        .textFieldStyle(.roundedBorder)
    }

    private func measurementInputView(title: String, placeholder: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            TextField(placeholder, text: value)
                .keyboardType(.decimalPad)
                .textContentType(.none)
                .autocorrectionDisabled()
        }
    }

    private var checkButton: some View {
        Button(action: {
            Task { await viewModel.checkRequirements() }
        }) {
            if viewModel.isCheckingRequirements {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Text("Fahrzeug prüfen")
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isCheckingRequirements)
    }

    private func progressView() -> some View {
        VStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(.circular)

            Text("Prüfe Fahrzeugmaße...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private func resultView(result: VehicleCheckResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if result.isWithinLimits {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(result.recommendation)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Achtung: Fahrzeugmaße außerhalb der empfohlenen Werte")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                if !result.exceededDimensions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Überschreitungen:")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        ForEach(result.exceededDimensions.sorted(by: { $0.key < $1.key }), id: \.key) { dimension, value in
                            HStack {
                                Text("\(dimension):")
                                Spacer()
                                Text(String(format: "%.2f m", value))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange, lineWidth: 1)
                    )
                }

                Text(result.recommendation)
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VehicleRequirementsView()
    }
}