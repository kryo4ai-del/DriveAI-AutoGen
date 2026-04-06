import SwiftUI

struct CategorySelectionScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    private let columns = [
        GridItem(.flexible(minimum: 140), spacing: 12),
        GridItem(.flexible(minimum: 140), spacing: 12),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("onboarding.categories.title")
                    .font(.system(size: 24, weight: .bold))
                    .lineLimit(nil)
                
                Text("onboarding.categories.select_one")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 24)
            .accessibilityElement(children: .combine)
            
            // Category Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Category.allCategories, id: \.id) { category in
                        CategoryCard(
                            category: category,
                            isSelected: viewModel.isCategorySelected(category.id),
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.toggleCategory(category.id)
                                }
                            }
                        )
                        .accessibilityLabel(category.name)
                        .accessibilityHint(
                            viewModel.isCategorySelected(category.id)
                                ? String(localized: "a11y.selected")
                                : String(localized: "a11y.not_selected")
                        )
                        .accessibilityAddTraits(.isButton)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Error Message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .accessibilityLabel("Fehler")
                    .accessibilityValue(error)
            }
            
            Spacer()
            
            // Navigation Buttons
            HStack(spacing: 12) {
                Button(action: { viewModel.previousStep() }) {
                    Text("button.back")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(UIColor.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                .accessibilityLabel(String(localized: "button.back"))
                
                Button(action: { viewModel.nextStep() }) {
                    Text("button.next")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.validateCategorySelection())
                .opacity(viewModel.validateCategorySelection() ? 1 : 0.5)
                .accessibilityLabel(String(localized: "button.next"))
                .accessibilityHint(
                    viewModel.validateCategorySelection()
                        ? nil
                        : String(localized: "error.category_required")
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - CategoryCard Component

#Preview {
    CategorySelectionScreen(viewModel: OnboardingViewModel())
}