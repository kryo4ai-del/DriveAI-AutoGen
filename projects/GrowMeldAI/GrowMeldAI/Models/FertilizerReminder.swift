// Models.swift
import Foundation

struct FertilizerReminder: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var dueDate: Date
    var fertilizerType: FertilizerType
    var isCompleted: Bool
    var cropType: CropType

    init(id: UUID = UUID(),
         title: String,
         description: String,
         dueDate: Date,
         fertilizerType: FertilizerType,
         isCompleted: Bool = false,
         cropType: CropType) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.fertilizerType = fertilizerType
        self.isCompleted = isCompleted
        self.cropType = cropType
    }
}

enum FertilizerType: String, Codable, CaseIterable {
    case nitrogen = "Stickstoff"
    case phosphorus = "Phosphor"
    case potassium = "Kalium"
    case organic = "Organisch"
    case micronutrients = "Mikronährstoffe"

    var color: String {
        switch self {
        case .nitrogen: return "systemOrange"
        case .phosphorus: return "systemYellow"
        case .potassium: return "systemPurple"
        case .organic: return "systemGreen"
        case .micronutrients: return "systemBlue"
        }
    }
}

enum CropType: String, Codable, CaseIterable {
    case wheat = "Weizen"
    case corn = "Mais"
    case soybeans = "Soja"
    case potatoes = "Kartoffeln"
    case vegetables = "Gemüse"
}

struct FarmerSkills: Codable {
    var nitrogenMastery: Int = 0
    var phosphorusMastery: Int = 0
    var potassiumMastery: Int = 0
    var organicMastery: Int = 0
    var micronutrientsMastery: Int = 0
    var lastHarvestDate: Date?

    var overallMastery: Int {
        (nitrogenMastery + phosphorusMastery + potassiumMastery +
         organicMastery + micronutrientsMastery) / 5
    }

    var nextSkillToImprove: FertilizerType {
        let skills = [
            FertilizerType.nitrogen: nitrogenMastery,
            FertilizerType.phosphorus: phosphorusMastery,
            FertilizerType.potassium: potassiumMastery,
            FertilizerType.organic: organicMastery,
            FertilizerType.micronutrients: micronutrientsMastery
        ]

        return skills.min(by: { $0.value < $1.value })?.key ?? .nitrogen
    }
}