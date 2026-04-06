// File: TheoryCategoriesView.swift
import SwiftUI

struct TheoryCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
}

struct TheoryCategoriesView: View {
    let categories: [TheoryCategory] = [
        TheoryCategory(name: "Traffic Signs", icon: "signpost.right"),
        TheoryCategory(name: "Rules of the Road", icon: "road.lanes"),
        TheoryCategory(name: "Safety", icon: "shield.checkerboard")
    ]

    var body: some View {
        List(categories) { category in
            NavigationLink {
                QuestionsView(category: category)
            } label: {
                Label(category.name, systemImage: category.icon)
            }
        }
        .navigationTitle("Categories")
    }
}