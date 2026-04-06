import Foundation

struct MockProduct: Identifiable, Codable, Equatable {
    let id: String
    let displayName: String
    let price: Decimal
    let localizedPrice: String?
    let iconName: String?

    init(
        id: String,
        displayName: String,
        price: Decimal,
        localizedPrice: String? = nil,
        iconName: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.price = price
        self.localizedPrice = localizedPrice
        self.iconName = iconName
    }

    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case price
        case localizedPrice
        case iconName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        displayName = try container.decode(String.self, forKey: .displayName)
        let priceString = try container.decode(String.self, forKey: .price)
        price = Decimal(string: priceString) ?? Decimal.zero
        localizedPrice = try container.decodeIfPresent(String.self, forKey: .localizedPrice)
        iconName = try container.decodeIfPresent(String.self, forKey: .iconName)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(displayName, forKey: .displayName)
        try container.encode("\(price)", forKey: .price)
        try container.encodeIfPresent(localizedPrice, forKey: .localizedPrice)
        try container.encodeIfPresent(iconName, forKey: .iconName)
    }
}