// DriveAIApp.swift
import SwiftUI

@main

// MARK: - Router

// MARK: - Question View Wrapper

struct QuestionViewWrapper: View {
    let categoryID: String
    @StateObject private var viewModel = QuestionViewModel()

    var body: some View {
        QuestionView(
            viewModel: viewModel,
            category: Category.allCategories.first { $0.id == categoryID },
            onComplete: { _ in }
        )
    }
}