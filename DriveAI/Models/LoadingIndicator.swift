import SwiftUI

/// DriveAI Design System - Centralized styling tokens and components
enum DriveAI {
    
    // MARK: - Color Palette
    
    enum Colors {
        // Status colors
        static let passGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
        static let failRed = Color(red: 0.8, green: 0.2, blue: 0.2)
        static let warningOrange = Color(red: 1.0, green: 0.6, blue: 0.1)
        static let infoBlue = Color.blue
        
        // Semantic
        static let success = passGreen
        static let danger = failRed
        static let warning = warningOrange
        static let info = infoBlue
        
        // Background & Surface
        static let background = Color(.systemGray6)
        static let cardBackground = Color(.systemBackground)
        static let surfaceOverlay = Color.black.opacity(0.5)
        
        /// Returns color based on percentage threshold
        static func performanceColor(for percentage: Double) -> Color {
            if percentage >= 0.90 { return success }
            if percentage >= 0.75 { return infoBlue }
            if percentage >= 0.60 { return warningOrange }
            return danger
        }
    }
    
    // MARK: - Spacing Scale
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let huge: CGFloat = 48
    }
    
    // MARK: - Typography
    
    enum Fonts {
        static let largeTitle = Font.system(.largeTitle, design: .default).weight(.bold)
        static let title = Font.system(.title, design: .default).weight(.bold)
        static let title2 = Font.system(.title2, design: .default).weight(.bold)
        static let headline = Font.headline
        static let headlineBold = Font.headline.weight(.bold)
        static let subheadline = Font.subheadline
        static let subheadlineBold = Font.subheadline.weight(.bold)
        static let body = Font.body
        static let caption = Font.caption
        static let caption2 = Font.caption2
    }
    
    // MARK: - Border Radius
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
    }
    
    // MARK: - Shadow & Elevation
    
    enum Shadows {
        static let light = Shadow(
            color: Color.black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
        
        static let medium = Shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let heavy = Shadow(
            color: Color.black.opacity(0.2),
            radius: 12,
            x: 0,
            y: 8
        )
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Reusable View Modifiers

extension View {
    /// Applies DriveAI card styling (background + corner radius + padding)
    func driveAICard(padding: CGFloat = DriveAI.Spacing.lg) -> some View {
        self
            .padding(padding)
            .background(DriveAI.Colors.background)
            .cornerRadius(DriveAI.CornerRadius.medium)
    }
    
    /// Primary button styling (blue background, white text)
    func driveAIPrimaryButton() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(DriveAI.Spacing.lg)
            .background(DriveAI.Colors.infoBlue)
            .foregroundStyle(.white)
            .cornerRadius(DriveAI.CornerRadius.medium)
            .font(DriveAI.Fonts.subheadlineBold)
    }
    
    /// Secondary button styling (gray background, dark text)
    func driveAISecondaryButton() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(DriveAI.Spacing.lg)
            .background(DriveAI.Colors.background)
            .foregroundStyle(.primary)
            .cornerRadius(DriveAI.CornerRadius.medium)
            .font(DriveAI.Fonts.subheadlineBold)
    }
    
    /// Tertiary button styling (minimal, text-only)
    func driveAITertiaryButton() -> some View {
        self
            .padding(.vertical, DriveAI.Spacing.md)
            .padding(.horizontal, DriveAI.Spacing.lg)
            .font(DriveAI.Fonts.subheadlineBold)
            .foregroundStyle(DriveAI.Colors.infoBlue)
    }
    
    /// Applies DriveAI accessibility container pattern
    func driveAIAccessibilityContainer(
        label: String,
        value: String
    ) -> some View {
        self
            .accessibilityElement(children: .contain)
            .accessibilityLabel(label)
            .accessibilityValue(value)
    }
    
    /// Applies DriveAI accessibility button pattern
    func driveAIAccessibilityButton(
        label: String,
        hint: String = ""
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAddTraits(.isButton)
    }
    
    /// Performance color badge
    func performanceColor(for percentage: Double) -> Color {
        DriveAI.Colors.performanceColor(for: percentage)
    }
}

// MARK: - Common Components

struct LoadingIndicator: View {
    var body: some View {
        VStack(spacing: DriveAI.Spacing.md) {
            ProgressView()
                .tint(DriveAI.Colors.infoBlue)
            
            Text("Wird geladen...")
                .font(DriveAI.Fonts.caption)
                .foregroundStyle(.secondary)
        }
        .padding(DriveAI.Spacing.xl)
        .driveAICard()
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let action: (() -> Void)?
    let actionLabel: String?
    
    init(
        icon: String,
        title: String,
        message: String,
        action: (() -> Void)? = nil,
        actionLabel: String? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = action
        self.actionLabel = actionLabel
    }
    
    var body: some View {
        VStack(spacing: DriveAI.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(DriveAI.Colors.infoBlue)
            
            VStack(spacing: DriveAI.Spacing.sm) {
                Text(title)
                    .font(DriveAI.Fonts.headline)
                    .foregroundStyle(.primary)
                
                Text(message)
                    .font(DriveAI.Fonts.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let action = action, let actionLabel = actionLabel {
                Button(action: action) {
                    Text(actionLabel)
                        .driveAIPrimaryButton()
                }
            }
        }
        .padding(DriveAI.Spacing.xl)
        .multilineTextAlignment(.center)
    }
}

struct PerformanceBadge: View {
    let percentage: Double
    let size: BadgeSize
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: Font {
            switch self {
            case .small: return DriveAI.Fonts.caption2
            case .medium: return DriveAI.Fonts.subheadline
            case .large: return DriveAI.Fonts.headline
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return DriveAI.Spacing.sm
            case .medium: return DriveAI.Spacing.md
            case .large: return DriveAI.Spacing.lg
            }
        }
    }
    
    var body: some View {
        Text("\(Int(percentage * 100))%")
            .font(size.fontSize.monospacedDigit())
            .foregroundStyle(.white)
            .padding(size.padding)
            .background(DriveAI.Colors.performanceColor(for: percentage))
            .cornerRadius(DriveAI.CornerRadius.small)
    }
}

#Preview {
    VStack(spacing: DriveAI.Spacing.xl) {
        // Card Example
        VStack(spacing: DriveAI.Spacing.md) {
            Text("Card Example")
                .font(DriveAI.Fonts.headline)
            
            Text("This is a DriveAI card component")
                .font(DriveAI.Fonts.caption)
                .foregroundStyle(.secondary)
        }
        .driveAICard()
        
        // Buttons Example
        VStack(spacing: DriveAI.Spacing.md) {
            Button("Primary Button") {}
                .driveAIPrimaryButton()
            
            Button("Secondary Button") {}
                .driveAISecondaryButton()
            
            Button("Tertiary Button") {}
                .driveAITertiaryButton()
        }
        .padding(DriveAI.Spacing.lg)
        
        // Performance Badge Example
        HStack(spacing: DriveAI.Spacing.lg) {
            PerformanceBadge(percentage: 0.95, size: .medium)
            PerformanceBadge(percentage: 0.75, size: .medium)
            PerformanceBadge(percentage: 0.60, size: .medium)
        }
        .padding(DriveAI.Spacing.lg)
        
        // Empty State Example
        EmptyStateView(
            icon: "questionmark.circle",
            title: "Keine Ergebnisse",
            message: "Starten Sie eine Simulation, um Ihre Ergebnisse hier zu sehen.",
            action: {},
            actionLabel: "Simulation starten"
        )
        
        Spacer()
    }
    .padding(DriveAI.Spacing.lg)
}