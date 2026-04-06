import SwiftUI
struct ComplianceBannerCard: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Legal document links
            HStack(spacing: 12) {
                Link("Datenschutz", destination: URL(string: "https://driveai.app/privacy")!)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Divider().frame(height: 12)
                
                Link("Nutzungsbedingungen", destination: URL(string: "https://driveai.app/terms")!)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(12)
        .background(accentColor.opacity(0.1))
        .cornerRadius(10)
    }
}