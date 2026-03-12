import SwiftUI

struct BlocklistItemView: View {
    let item: BlocklistItem

    var body: some View {
        Text(item.id.uuidString)
    }
}
