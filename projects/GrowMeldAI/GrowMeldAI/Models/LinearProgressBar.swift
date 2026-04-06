// ProgressIndicators.swift (COMPLETE)
import SwiftUI

struct LinearProgressBar: View {
    let progress: Double  // 0.0 to 1.0
    let height: CGFloat
    
    @Environment(\.colorPalette) private var palette
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background track
            Rectangle()
                .fill(palette.surfaceVariant)
                .frame(height: height)
                .cornerRadius(height / 2)
            
            // Filled progress (animated)
            GeometryReader { geometry in
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                palette.primary,
                                palette.primaryLight
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * min(max(progress, 0), 1),
                        height: height
                    )
                    .cornerRadius(height / 2)
                    .animation(.easeInOut(duration: DesignTokens.Animation.normal), value: progress)
            }
        }
        .frame(height: height)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress bar")
        .accessibilityValue("\(Int(progress * 100))% complete")
    }
}

struct CircularProgressBar: View {
    let progress: Double  // 0.0 to 1.0
    let lineWidth: CGFloat = 8
    
    @Environment(\.colorPalette) private var palette
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(palette.surfaceVariant, lineWidth: lineWidth)
            
            // Progress circle (animated)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            palette.primary,
                            palette.primaryLight
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: DesignTokens.Animation.normal), value: progress)
            
            // Center text
            VStack {
                Text("\(Int(progress * 100))")
                    .font(DesignTokens.Typography.h2)
                    .foregroundColor(palette.text)
                
                Text("Complete")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(palette.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100))% complete")
    }
}

// MARK: - Preview
#Preview("Linear Progress") {
    @State var progress: Double = 0.65
    
    VStack(spacing: DesignTokens.Spacing.lg) {
        LinearProgressBar(progress: progress, height: 8)
        
        Slider(value: $progress, in: 0...1)
            .padding()
    }
    .padding(DesignTokens.Spacing.lg)
    .background(ColorPalette.light.background)
}

#Preview("Circular Progress") {
    @State var progress: Double = 0.65
    
    VStack(spacing: DesignTokens.Spacing.lg) {
        CircularProgressBar(progress: progress)
            .frame(width: 120, height: 120)
        
        Slider(value: $progress, in: 0...1)
            .padding()
    }
    .padding(DesignTokens.Spacing.lg)
    .background(ColorPalette.light.background)
}