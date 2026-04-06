// Models/PlantIdentification.swift
  struct PlantInfo: Codable {
    let plantId: String
    let manufacturer: String
    let emissionStandard: String
    let region: String // DE, AT, CH
  }