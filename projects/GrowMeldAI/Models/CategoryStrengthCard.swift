import SwiftUI

struct CategoryStrengthCard: View {
    let strength: CategoryStrength
    var body: some View {
        VStack {
            Text(strength.categoryName)
            Text("\(Int(strength.accuracy * 100))%")
        }
    }
}
