// KIIdentificationFlowCoordinator.swift
struct KIIdentificationFlowCoordinator: View {
    @StateObject var viewModel: CameraIdentificationViewModel
    @State var navigationPath: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            CameraIdentificationView(viewModel: viewModel)
                .navigationDestination(for: RecognitionResult.self) { result in
                    SignRecognitionResultView(result: result)
                        .navigationDestination(for: Question.self) { question in
                            // Reuse existing QuestionScreenView with filtered set
                            QuestionScreenView(
                                questions: viewModel.linkedQuestions,
                                source: .kiIdentifikation(sign: result.sign)
                            )
                        }
                }
        }
    }
}