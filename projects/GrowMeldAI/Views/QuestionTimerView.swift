// File: Views/QuestionTimerView.swift
import SwiftUI

struct QuestionTimerView: View {
    @EnvironmentObject private var viewModel: ExamPrepViewModel

    var body: some View {
        HStack {
            Image(systemName: "clock")
            Text(viewModel.timeString)
                .monospacedDigit()
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }
}