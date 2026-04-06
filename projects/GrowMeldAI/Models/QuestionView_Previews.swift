// In Xcode preview
struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        let sizes: [DynamicTypeSize] = [
            .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge
        ]
        
        ForEach(sizes, id: \.self) { size in
            QuestionView(viewModel: .preview)
                .environment(\.dynamicTypeSize, size)
                .previewDisplayName("Size: \(String(describing: size))")
        }
    }
}