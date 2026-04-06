// Views/Shared/AccessibleButtonStyle.swift
import SwiftUI

// Views/Landing/LandingHeroSection.swift (Updated)
struct LandingHeroSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: LandingMetrics.paddingXLarge) {
            // Hero Image
            ZStack {
                RoundedRectangle(cornerRadius: LandingMetrics.cornerRadiusSmall)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                LandingColors.heroGradientStart,
                                LandingColors.heroGradientEnd
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(spacing: LandingMetrics.paddingSmall) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                    Text("🚗")
                        .font(.system(size: 36))
                }
            }
            .frame(height: LandingMetrics.heroHeight)
            .padding(.horizontal, LandingMetrics.paddingLarge)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("landing.hero.image.label".localized)
            
            // Headline
            VStack(alignment: .leading, spacing: LandingMetrics.paddingSmall) {
                Text("landing.hero.title".localized)
                    .font(LandingTypography.heroTitle)
                    .lineLimit(3)
                    .foregroundColor(.primary)
                
                Text("landing.hero.subtitle".localized)
                    .font(LandingTypography.body)
                    .lineLimit(4)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, LandingMetrics.paddingLarge)
            
            // Trust Badges
            HStack(spacing: LandingMetrics.paddingSmall) {
                TrustBadge(
                    icon: "star.fill",
                    label: "landing.hero.rating".localized,
                    accessibilityLabel: "landing.hero.rating.a11y".localized
                )
                
                TrustBadge(
                    icon: "checkmark.circle.fill",
                    label: "landing.hero.passed".localized,
                    accessibilityLabel: "landing.hero.passed.a11y".localized
                )
                
                Spacer()
            }
            .padding(.horizontal, LandingMetrics.paddingLarge)
            
            Spacer()
        }
        .padding(.top, LandingMetrics.paddingXLarge)
        .padding(.bottom, LandingMetrics.sectionSpacing)
    }
}

struct TrustBadge: View {
    let icon: String
    let label: String
    let accessibilityLabel: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(icon.contains("star") ? .yellow : .green)
            
            Text(label)
                .font(LandingTypography.caption)
                .fontWeight(.semibold)
        }
        .padding(.vertical, LandingMetrics.paddingSmall)
        .padding(.horizontal, LandingMetrics.paddingSmall)
        .background(Color(.systemGray6))
        .cornerRadius(LandingMetrics.cornerRadiusSmall)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
}