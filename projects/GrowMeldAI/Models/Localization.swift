// Utilities/Extensions/String+Localized.swift
import Foundation

enum Localization {
    static let bundle = Bundle.main
    
    static func string(for key: String, in table: String = "Localizable") -> String {
        NSLocalizedString(key, tableName: table, bundle: bundle, value: "??", comment: "")
    }
}

// Use in enums

// Localizable.strings (de)
"category_trafficSigns" = "Verkehrszeichen";
"category_rightOfWay" = "Vorfahrt";