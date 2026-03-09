enum ButtonState {
    case idle, loading, ready
}

@State private var buttonState: ButtonState = .idle

if buttonState == .loading {
    ProgressView()
} else {
    // Present buttons for options here
}