// MARK: - Services/Accessibility/SelectableItemAccessibility.swift

extension View {
    /// Apply consistent accessibility for selectable UI items (buttons, radio groups)
    func selectableItemAccessibility(
        label: String,
        isSelected: Bool,
        itemType: String = "option"
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint("Tap to select this \(itemType)")
            .accessibilityValue(isSelected ? "Selected" : "Not selected")
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Usage in Buttons

struct CountryButton: View {
    let country: Country
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(country.flag)
                    .font(.system(size: 28))
                    .accessibilityHidden(true)
                
                Text(country.displayName)
                    .font(.system(.caption, design: .default))
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(12)
        }
        .minimumTouchTarget(size: 80)
        .selectableItemAccessibility(
            label: country.displayName,
            isSelected: isSelected,
            itemType: "country"
        )
    }
}

struct RegionButton: View {
    let region: Region
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(region.name)
                        .font(.system(.body, design: .default))
                        .fontWeight(.medium)
                    
                    Text(region.subtitle)
                        .font(.system(.caption, design: .default))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(.body, design: .default))
                        .foregroundColor(.blue)
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(isSelected ? Color(.systemBlue).opacity(0.1) : Color(.systemGray6))
            .cornerRadius(8)
        }
        .minimumTouchTarget(size: 44)
        .selectableItemAccessibility(
            label: region.name,
            isSelected: isSelected,
            itemType: "region"
        )
    }
}