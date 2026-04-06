import Foundation

enum CheckoutStep: Int, CaseIterable {
    case review = 0
    case payment = 1
    case confirmation = 2
}
