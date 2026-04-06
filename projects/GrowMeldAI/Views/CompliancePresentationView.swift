struct CompliancePresentationView: View {
    @StateObject var viewModel: CompliancePresentationViewModel
    @EnvironmentObject var consentManager: AppConsentManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content
            TabView(selection: $viewModel.currentSection.id) {
                ForEach(viewModel.sections) { section in
                    switch section.screenType {
                    case .intro:
                        ComplianceIntroScreen()
                    case .dataCollection:
                        DataCollectionScreen(viewModel: viewModel)
                    case .userRights:
                        UserRightsScreen(consentManager: consentManager)
                    case .consentManagement:
                        ConsentManagementScreen()
                            .environmentObject(consentManager)
                    case .dataExport:
                        DataExportScreen(viewModel: viewModel)
                    case .summary:
                        ComplianceSummaryScreen()
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(.container, edges: .horizontal)
            
            // Progress indicator
            HStack {
                ProgressView(
                    value: Double(viewModel.sections.firstIndex { $0.id == viewModel.currentSection.id } ?? 0),
                    total: Double(viewModel.sections.count)
                )
                .accessibilityLabel("Progress: \(currentSectionNumber) of \(viewModel.sections.count)")
            }
            .padding()
            
            // Navigation buttons
            HStack {
                Button("Zurück") { viewModel.previousSection() }
                    .disabled(viewModel.isFirstSection)
                
                Spacer()
                
                Button(viewModel.isLastSection ? "Abschließen" : "Weiter") {
                    viewModel.nextSection()
                }
            }
            .padding()
        }
    }
}