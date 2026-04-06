// Services/Location/LocationModule.swift
struct LocationModule {
    let viewModel: LocationViewModel
    let service: LocationService
    let plzService: PLZMappingService
    
    static func create() -> Self {
        let plzService = PLZMappingService() // Loads embedded JSON once
        let service = LocationService()
        let viewModel = LocationViewModel(
            locationService: service,
            plzService: plzService
        )
        return Self(
            viewModel: viewModel,
            service: service,
            plzService: plzService
        )
    }
}