import SwiftUI

struct ExerciseFilterBar: View {
    @Binding var selectedCategory: ExerciseCategory?
    let categories: [ExerciseCategory]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterButton(
                    label: "All",
                    isSelected: selectedCategory == nil,
                    icon: "square.grid.2x2",
                    color: .blue
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = nil
                    }
                }
                
                ForEach(categories, id: \.self) { category in
                    FilterButton(
                        label: category.rawValue,
                        isSelected: selectedCategory == category,
                        icon: category.icon,
                        color: category.color
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    ExerciseFilterBar(
        selectedCategory: .constant(nil),
        categories: ExerciseCategory.allCases
    )
}