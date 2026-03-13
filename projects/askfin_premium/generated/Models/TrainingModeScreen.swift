import SwiftUI

struct TrainingModeScreen: View {
    @StateObject private var viewModel: TrainingModeViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    init(
        sessionService: TrainingSessionServiceProtocol = TrainingSessionService.shared,
        dataService: LocalDataServiceProtocol = LocalDataService.shared
    ) {
        _viewModel = StateObject(wrappedValue: TrainingModeViewModel(
            sessionService: sessionService,
            dataService: dataService
        ))
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            contentView
                .safeAreaInset(edge: .bottom) {
                    if viewModel.state.isAnswering {
                        TrainingSessionFooterView(
                            canPrevious: viewModel.sessionViewModel?.canMoveToPrevious() ?? false,
                            canNext: viewModel.sessionViewModel?.canMoveToNext() ?? false,
                            onPrevious: { viewModel.previousQuestion() },
                            onNext: { viewModel.nextQuestion() },
                            onSkip: { viewModel.skipQuestion() }
                        )
                        .background(Color(.systemBackground))
                    }
                }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(!canGoBack)
        .toolbar {
            if viewModel.state.isAnswering {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showExitConfirmation = true }) {
                        Image(


**Status**: ✅ **ARCHITECTURE-SOUND** with **CRITICAL IMPLEMENTATION GAPS**

The structure is solid and follows MVVM principles well, but the provided code is **incomplete** and has several structural issues that must be addressed before implementation.

---


**Severity**: HIGH  
**Location**: Views layer (truncated at `NavigationTitle`)