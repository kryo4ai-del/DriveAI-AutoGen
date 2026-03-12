import SwiftUI

struct FeatureAnnouncementView: View {
    @StateObject private var viewModel = FeatureAnnouncementViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(viewModel.introduction)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .multilineTextAlignment(.leading)

                Text("Hauptmerkmale:")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(viewModel.featureSummary, id: \.self) { feature in
                    HStack {
                        Image(systemName: featureIcon(for: feature)) // Dynamic icon retrieval
                            .foregroundColor(.orange)
                        Text(feature)
                            .font(.body)
                            .padding(.vertical, 5)
                    }
                    .padding(.horizontal)
                }

                Text(viewModel.callToAction)
                    .font(.headline)
                    .padding()
                    .foregroundColor(.blue)
            }
            .background(Color(UIColor.systemBackground))
            .padding()
        }
    }
    
    func featureIcon(for feature: String) -> String {
        switch feature {
        case "Interaktive Fragen":
            return "questionmark.circle"
        case "Statistik-Tracking":
            return "chart.bar"
        case "Prüfungssimulation":
            return "clock"
        case "Offline verfügbar":
            return "wifi.slash"
        case "Benutzerfreundliches Design":
            return "pencil.and.outline"
        default:
            return "star.fill"
        }
    }
}