enum ViewState {
    case loading
    case content
    case error(String)
}

@Published var viewState: ViewState = .loading