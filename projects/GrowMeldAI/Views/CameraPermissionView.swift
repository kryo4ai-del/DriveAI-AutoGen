import SwiftUI

struct CameraPermissionView: View {
    @ObservedObject var viewModel: CameraAccessViewModel
    var body: some View { Text("Camera Permission") }
}
