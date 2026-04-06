import SwiftUI

struct SyncStatusView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            previewView(state: .syncing)
            previewView(state: .synced)
            previewView(state: .offline)
            previewView(state: .error)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }

    private static func previewView(state: SyncState) -> some View {
        let viewModel = BackupViewModel()
        viewModel.syncState = state
        viewModel.lastSyncDate = Calendar.current.date(byAdding: .minute, value: -45, to: Date())

        return SyncStatusView(viewModel: viewModel)
            .previewDisplayName(state.rawValue.capitalized)
    }
}