// Features/LocationPicker/Reducers/LocationPickerReducer.swift
@Reducer
struct LocationPickerFeature {
    @ObservableState
    struct State: Equatable {
        var searchQuery = ""
        var suggestedRegions: [Region] = []
        var selectedLocation: Region?
    }
    
    enum Action {
        case searchQueryChanged(String)
        case locationSelected(Region)
        case suggestionsLoaded([Region])
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .searchQueryChanged(let query):
                state.searchQuery = query
                return .send(.suggestionsLoaded(filterRegions(by: query)))
            case .locationSelected(let region):
                state.selectedLocation = region
                return .none
            case .suggestionsLoaded(let regions):
                state.suggestedRegions = regions
                return .none
            }
        }
    }
}