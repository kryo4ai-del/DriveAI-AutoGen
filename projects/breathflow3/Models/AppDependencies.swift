// Models/AppDependencies.swift
import Foundation

class AppDependencies {
    static let shared = AppDependencies()

    lazy var exerciseRepository = ExerciseRepository()
}
