struct ComplianceSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // SECTION 1: Essential Controls
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(...)
                    
                    ConsentToggleComponent(...)
                    ConsentToggleComponent(...)
                }
                .accessibilityElement(children: .contain)  // ✅ Group as section
                .accessibilityLabel("Deine Kontrolle")  // ✅ Heading
                .accessibilityAddTraits(.isHeader)  // ✅ Semantic signal
                
                // SECTION 2: Data Management
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(...)
                    DataActionButton(...)
                    DataActionButton(...)
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Deine Daten")
                .accessibilityAddTraits(.isHeader)
                
                // SECTION 3: Advanced Settings
                DisclosureGroup(
                    isExpanded: $expandAdvanced,
                    content: {
                        VStack(alignment: .leading, spacing: 12) {
                            ConsentToggleComponent(...)
                            ConsentToggleComponent(...)
                        }
                        .accessibilityElement(children: .contain)
                    },
                    label: {
                        HStack(spacing: 10) {
                            Image(systemName: "slider.horizontal.3")
                            Text("Erweiterte Einstellungen")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    }
                )
                .accessibilityElement(children: .combine)  // ✅ Group disclosure control
                .accessibilityAddTraits(.isButton)
            }
        }
        .navigationTitle("Deine Privatsphäre")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .accessibilityAddTraits(.isHeader)  // ✅ Semantic header
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}