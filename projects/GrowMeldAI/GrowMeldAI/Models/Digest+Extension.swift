// Extensions.swift
import Foundation
import CryptoKit

extension Digest {
    var hexString: String {
        self.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension SymmetricKey {
    init(data: Data) {
        self.init(data: data)
    }
}