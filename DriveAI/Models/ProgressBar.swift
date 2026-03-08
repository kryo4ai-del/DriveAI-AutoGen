import SwiftUI

struct ProgressBar: View {
    var progress: Double // Should be between 0 and 1

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: DesignSystemModel().cornerRadius)
                .fill(Color.blue)
                .frame(height: 20)
                .overlay(
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: DesignSystemModel().cornerRadius)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: CGFloat(progress) * geometry.size.width)
                    }
                )
                .animation(.easeInOut, value: progress)
                .frame(maxHeight: shouldBeDynamic() ? 30 : 20)
            Text("\(Int(progress * 100))%")
                .font(ThemeService().getFont(size: 12))
                .padding(.top, 2)
        }
    }

    private func shouldBeDynamic() -> Bool {
        return true // Logic to determine dynamic height
    }
}