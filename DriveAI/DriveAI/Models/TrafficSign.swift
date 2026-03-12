// Models/TrafficSign.swift
import Foundation

struct TrafficSign: Identifiable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var imageName: String
    var category: String // Categorized attribute for better context
}