var body: some View {
    VStack {
        Image("onboardingImage") // Ensure to include an onboarding image in Assets
            .resizable()
            .scaledToFit()
            .frame(height: 200)

        Text("Welcome to DriveAI!")
            .font(.largeTitle)
            .padding()
        
        Button("Start") {
            viewModel.completeOnboarding()
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    .navigationBarBackButtonHidden(true)
}

// ---

var body: some View {
    VStack {
        Text("Your Progress")
            .font(.title)
        
        // Example of a progress indicator; you would need to implement the logic
        ProgressView(value: viewModel.quizProgress, total: 100) // Assuming the ViewModel has this logic
            .progressViewStyle(LinearProgressViewStyle())
            .padding()

        NavigationLink("Start Quiz", destination: QuestionView(viewModel: QuestionViewModel()))
        NavigationLink("Categories", destination: CategoryOverviewView(viewModel: CategoryOverviewViewModel()))
        NavigationLink("Profile", destination: ProfileView(viewModel: ProfileViewModel()))
    }
    .padding()
}

// ---

Button(answer) {
    viewModel.submitAnswer(answer)
    // Haptic feedback
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}
.buttonStyle(.bordered)

// ---

Button("Start") {
    viewModel.completeOnboarding()
}
.accessibilityLabel("Start Onboarding Process")
.accessibilityHint("Tap to begin the onboarding process.")

// ---

var body: some View {
    VStack {
        Image("onboardingImage") // Add your onboarding image in assets
            .resizable()
            .scaledToFit()
            .frame(height: 200)
        Text("Welcome to DriveAI!")
            .font(.largeTitle)
            .padding()
        Button("Start") {
            viewModel.completeOnboarding()
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    .navigationBarBackButtonHidden(true)
}

// ---

var body: some View {
    VStack {
        Text("Your Progress")
            .font(.title)
        ProgressView(value: viewModel.quizProgress, total: 100) // Mock progress logic
            .progressViewStyle(LinearProgressViewStyle())
            .padding()
        NavigationLink("Start Quiz", destination: QuestionView(viewModel: QuestionViewModel()))
        NavigationLink("Categories", destination: CategoryOverviewView(viewModel: CategoryOverviewViewModel()))
        NavigationLink("Profile", destination: ProfileView(viewModel: ProfileViewModel()))
    }
    .padding()
}

// ---

Button(answer) {
    viewModel.submitAnswer(answer)
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}
.buttonStyle(.bordered)

// ---

Button("Start") {
    viewModel.completeOnboarding()
}
.accessibilityLabel("Start Onboarding Process")
.accessibilityHint("Tap to begin the onboarding process.")

// ---

var body: some View {
    VStack {
        Image("onboardingImage") // Include an onboarding image in Assets
            .resizable()
            .scaledToFit()
            .frame(height: 200)
        Text("Welcome to DriveAI!")
            .font(.largeTitle)
            .padding()
        Button("Start") {
            viewModel.completeOnboarding()
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    .navigationBarBackButtonHidden(true)
}

// ---

var body: some View {
    VStack {
        Text("Your Progress")
            .font(.title)
        ProgressView(value: viewModel.quizProgress, total: 100) // Assuming quizProgress is calculated in ViewModel
            .progressViewStyle(LinearProgressViewStyle())
            .padding()
        NavigationLink("Start Quiz", destination: QuestionView(viewModel: QuestionViewModel()))
        NavigationLink("Categories", destination: CategoryOverviewView(viewModel: CategoryOverviewViewModel()))
        NavigationLink("Profile", destination: ProfileView(viewModel: ProfileViewModel()))
    }
    .padding()
}

// ---

Button(answer) {
    viewModel.submitAnswer(answer)
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
}
.buttonStyle(.bordered)

// ---

Button("Start") {
    viewModel.completeOnboarding()
}
.accessibilityLabel("Start Onboarding Process")
.accessibilityHint("Tap to begin the onboarding process.")

// ---

var body: some View {
      VStack {
          Image("onboardingImage") // Ensure to include an onboarding image in Assets
              .resizable()
              .scaledToFit()
              .frame(height: 200)
          Text("Welcome to DriveAI!")
              .font(.largeTitle)
              .padding()
          Button("Start") {
              viewModel.completeOnboarding()
          }
          .buttonStyle(.borderedProminent)
          .padding()
      }
      .navigationBarBackButtonHidden(true)
  }

// ---

var body: some View {
      VStack {
          Text("Your Progress")
              .font(.title)
          ProgressView(value: viewModel.quizProgress, total: 100) // Assuming quizProgress is calculated in the ViewModel
              .progressViewStyle(LinearProgressViewStyle())
              .padding()
          NavigationLink("Start Quiz", destination: QuestionView(viewModel: QuestionViewModel()))
          NavigationLink("Categories", destination: CategoryOverviewView(viewModel: CategoryOverviewViewModel()))
          NavigationLink("Profile", destination: ProfileView(viewModel: ProfileViewModel()))
      }
      .padding()
  }

// ---

Button(answer) {
      viewModel.submitAnswer(answer)
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()
  }
  .buttonStyle(.bordered)

// ---

Button("Start") {
      viewModel.completeOnboarding()
  }
  .accessibilityLabel("Start Onboarding Process")
  .accessibilityHint("Tap to begin the onboarding process.")

// ---

var body: some View {
      VStack {
          Image("onboardingImage") // Ensure to include an onboarding image in Assets
              .resizable()
              .scaledToFit()
              .frame(height: 200)
          Text("Welcome to DriveAI!")
              .font(.largeTitle)
              .padding()
          Button("Start") {
              viewModel.completeOnboarding()
          }
          .buttonStyle(.borderedProminent)
          .padding()
      }
      .navigationBarBackButtonHidden(true)
  }

// ---

var body: some View {
      VStack {
          Text("Your Progress")
              .font(.title)
          ProgressView(value: viewModel.quizProgress, total: 100) // Assuming quizProgress is calculated in the ViewModel
              .progressViewStyle(LinearProgressViewStyle())
              .padding()
          NavigationLink("Start Quiz", destination: QuestionView(viewModel: QuestionViewModel()))
          NavigationLink("Categories", destination: CategoryOverviewView(viewModel: CategoryOverviewViewModel()))
          NavigationLink("Profile", destination: ProfileView(viewModel: ProfileViewModel()))
      }
      .padding()
  }

// ---

Button(answer) {
      viewModel.submitAnswer(answer)
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()
  }
  .buttonStyle(.bordered)

// ---

Button("Start") {
      viewModel.completeOnboarding()
  }
  .accessibilityLabel("Start Onboarding Process")
  .accessibilityHint("Tap to begin the onboarding process.")

// ---

var body: some View {
      VStack {
          Image("onboardingImage") // Incorporate a relevant onboarding image
              .resizable()
              .scaledToFit()
              .frame(height: 200)
          Text("Welcome to DriveAI!")
              .font(.largeTitle)
              .padding()
          Button("Start") {
              viewModel.completeOnboarding()
          }
          .buttonStyle(.borderedProminent)
          .padding()
      }
      .navigationBarBackButtonHidden(true)
  }

// ---

var body: some View {
      VStack {
          Text("Your Progress")
              .font(.title)
          ProgressView(value: viewModel.quizProgress, total: 100) // Calculated quizProgress in the ViewModel
              .progressViewStyle(LinearProgressViewStyle())
              .padding()
          NavigationLink("Start Quiz", destination: QuestionView(viewModel: QuestionViewModel()))
          NavigationLink("Categories", destination: CategoryOverviewView(viewModel: CategoryOverviewViewModel()))
          NavigationLink("Profile", destination: ProfileView(viewModel: ProfileViewModel()))
      }
      .padding()
  }

// ---

Button(answer) {
      viewModel.submitAnswer(answer)
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()
  }
  .buttonStyle(.bordered)

// ---

Button("Start") {
      viewModel.completeOnboarding()
  }
  .accessibilityLabel("Start Onboarding Process")
  .accessibilityHint("Tap to begin the onboarding process.")