@State private var showSettings = false

// In toolbar or sheet trigger:
Button(action: { showSettings = true }) {
    Image(systemName: "gear")
}
.sheet(isPresented: $showSettings) {
    SettingsView()
}