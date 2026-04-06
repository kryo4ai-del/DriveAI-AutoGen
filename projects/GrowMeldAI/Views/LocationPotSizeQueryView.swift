// LocationPotSizeQueryView.swift
import SwiftUI
import CoreLocation
import MapKit

struct LocationPotSizeQueryView: View {
    @StateObject private var viewModel = LocationPotSizeQueryViewModel()
    @State private var selectedPotSize: PotSize = .medium

    var body: some View {
        Form {
            Section(header: Text("Standortbestimmung")) {
                locationStatusView
                locationButton
            }

            Section(header: Text("Topfgrößen-Empfehlung")) {
                potSizeSelector
                recommendationView
            }

            Section {
                saveButton
            }
        }
        .navigationTitle("Standort & Topfgröße")
        .alert("Standortzugriff erforderlich", isPresented: $viewModel.showLocationAlert) {
            Button("Einstellungen", role: .cancel) {
                viewModel.openSettings()
            }
        } message: {
            Text("Bitte aktivieren Sie den Standortzugriff in den Einstellungen, um die Topfgrößen-Empfehlung zu erhalten.")
        }
    }

    private var locationStatusView: some View {
        HStack {
            Image(systemName: viewModel.locationStatus.iconName)
                .foregroundColor(viewModel.locationStatus.color)
            Text(viewModel.locationStatus.description)
        }
    }

    private var locationButton: some View {
        Button(action: viewModel.requestLocation) {
            Label("Standort aktualisieren", systemImage: "location.fill")
        }
        .disabled(viewModel.isLoading)
    }

    private var potSizeSelector: some View {
        Picker("Empfohlene Topfgröße", selection: $selectedPotSize) {
            ForEach(PotSize.allCases) { size in
                Text(size.rawValue).tag(size)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var recommendationView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Empfohlene Topfgröße:")
                .font(.headline)

            Text(selectedPotSize.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let recommendation = viewModel.currentRecommendation {
                Text(recommendation)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical)
    }

    private var saveButton: some View {
        Button(action: {}) {
            Text("Speichern")
                .frame(maxWidth: .infinity)
        }
        .disabled(!viewModel.hasValidLocation)
    }
}

private enum LocationStatus {
    case unknown
    case denied
    case restricted
    case authorized
    case loading

    var iconName: String {
        switch self {
        case .unknown: return "questionmark"
        case .denied: return "xmark.circle.fill"
        case .restricted: return "exclamationmark.triangle.fill"
        case .authorized: return "checkmark.circle.fill"
        case .loading: return "arrow.triangle.2.circlepath"
        }
    }

    var color: Color {
        switch self {
        case .unknown: return .gray
        case .denied: return .red
        case .restricted: return .orange
        case .authorized: return .green
        case .loading: return .blue
        }
    }

    var description: String {
        switch self {
        case .unknown: return "Standort unbekannt"
        case .denied: return "Standortzugriff verweigert"
        case .restricted: return "Standortzugriff eingeschränkt"
        case .authorized: return "Standort verfügbar"
        case .loading: return "Standort wird bestimmt..."
        }
    }
}

private enum PotSize: String, CaseIterable, Identifiable {
    case small = "Klein (10-15 cm)"
    case medium = "Mittel (20-25 cm)"
    case large = "Groß (30+ cm)"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .small: return "Kleine Töpfe eignen sich für Kräuter und kleine Pflanzen."
        case .medium: return "Mittlere Töpfe sind ideal für die meisten Zimmerpflanzen."
        case .large: return "Große Töpfe passen zu großen Pflanzen oder Bäumchen."
        }
    }
}

@MainActor
private final class LocationPotSizeQueryViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var locationStatus: LocationStatus = .unknown
    @Published var showLocationAlert = false
    @Published var isLoading = false
    @Published var currentRecommendation: String?

    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        checkLocationAuthorization()
    }

    var hasValidLocation: Bool {
        locationStatus == .authorized && lastLocation != nil
    }

    func requestLocation() {
        isLoading = true
        locationManager.requestLocation()
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationStatus = .unknown
        case .restricted, .denied:
            locationStatus = .denied
        case .authorizedAlways, .authorizedWhenInUse:
            locationStatus = .authorized
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        @unknown default:
            locationStatus = .unknown
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        isLoading = false
        updateRecommendation(for: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        print("Location error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    private func updateRecommendation(for location: CLLocation) {
        // Simple recommendation logic based on location
        let coordinate = location.coordinate
        let recommendation: String

        if coordinate.latitude > 50.0 {
            recommendation = "In nördlichen Regionen benötigen Pflanzen oft größere Töpfe für bessere Isolierung."
        } else if coordinate.latitude < 45.0 {
            recommendation = "In wärmeren Regionen reichen oft kleinere Töpfe mit guter Drainage."
        } else {
            recommendation = "Gemäßigtes Klima - mittlere Topfgröße ist meist ideal."
        }

        currentRecommendation = recommendation
    }
}