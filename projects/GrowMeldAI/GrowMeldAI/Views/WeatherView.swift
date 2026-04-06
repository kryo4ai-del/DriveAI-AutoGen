import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showErrorAlert = false

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            } else if let conditions = viewModel.weatherConditions {
                WeatherDisplay(conditions: conditions)
            } else {
                ContentUnavailableView("Wetterdaten laden", systemImage: "cloud")
            }
        }
        .navigationTitle("Wetter-Szenarien")
        .task {
            await viewModel.fetchWeather()
        }
        .alert("Wetterfehler", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.error?.errorDescription ?? "Unbekannter Fehler")
        }
        .onChange(of: viewModel.error) { newValue in
            showErrorAlert = newValue != nil
        }
    }
}

private struct WeatherDisplay: View {
    let conditions: WeatherConditions

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: weatherIcon(for: conditions.conditions))
                .font(.system(size: 60))
                .foregroundColor(weatherColor(for: conditions.conditions))

            Text("Aktuelle Bedingungen")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Temperatur:")
                    Spacer()
                    Text("\(conditions.temperature, specifier: "%.1f")°C")
                }

                HStack {
                    Text("Niederschlag:")
                    Spacer()
                    Text(conditions.precipitation ? "Ja" : "Nein")
                }

                HStack {
                    Text("Sichtweite:")
                    Spacer()
                    Text("\(conditions.visibility, specifier: "%.1f") km")
                }

                HStack {
                    Text("Windgeschwindigkeit:")
                    Spacer()
                    Text("\(conditions.windSpeed, specifier: "%.1f") m/s")
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
        }
        .padding()
    }

    private func weatherIcon(for condition: String) -> String {
        switch condition.lowercased() {
        case "clear": return "sun.max.fill"
        case "rain": return "cloud.rain.fill"
        case "snow": return "snowflake"
        case "clouds": return "cloud.fill"
        default: return "cloud"
        }
    }

    private func weatherColor(for condition: String) -> Color {
        switch condition.lowercased() {
        case "clear": return .yellow
        case "rain": return .blue
        case "snow": return .white
        case "clouds": return .gray
        default: return .primary
        }
    }
}