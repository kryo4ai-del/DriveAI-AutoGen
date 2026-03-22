// ExerciseCard semantic structure
VStack(alignment: .leading, spacing: 8) {
    Text(exercise.name)
        .accessibilityAddTraits(.isHeader)
    
    Text(exercise.description)
        .font(.caption)
        .foregroundColor(.secondary)
    
    HStack {
        DifficultyBadge(difficulty: exercise.difficulty)
        Spacer()
        if let stats = stats {
            Text("\(stats.completedCount) completed")
                .accessibilityLabel("Sessions completed: \(stats.completedCount)")
        }
    }
}
.accessibilityElement(children: .combine)

// ---

NavigationLink(value: exercise) {
    // ...
}
// ❌ Missing: .navigationDestination(for: Exercise) { exercise in

// ---

NavigationLink(value: exercise) {
    ExerciseCard(...)
}
.navigationDestination(for: Exercise.self) { exercise in
    ExerciseDetailView(exercise: exercise) // Assuming this exists
}

// ---

actor SessionHistoryService: SessionHistoryServiceProtocol {
    private let container: NSPersistentContainer
    
    init(container: NSPersistentContainer) { ... }
}

// ---

// AppDelegate or SceneDelegate
let persistenceController = PersistenceController.shared
let statsService = SessionHistoryService(container: persistenceController.container)

// In ExerciseSelectionView
init(statsService: SessionHistoryService = AppDependencies.shared.statsService) {
    self._viewModel = StateObject(
        wrappedValue: ExerciseSelectionViewModel(statsService: statsService)
    )
}

// ---

actor ExerciseRepository: ExerciseRepositoryProtocol {
    private var cachedExercises: [Exercise]?
    
    nonisolated private func loadJSON() throws -> Data { ... }
}

// ---

nonisolated private let cache = NSCache<NSUUID, NSArray>() // Thread-safe cache

func loadExercises() async throws -> [Exercise] {
    if let cached = cache.object(forKey: NSUUID()) as? [Exercise] {
        return cached
    }
    // ... load and cache
}

// ---

func loadExercises() async {
    // ...
    for exercise in loaded {
        await loadStats(for: exercise.id) // 🔴 SEQUENTIAL
    }
}

// ---

func loadExercises() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
        let loaded = try await repository.loadExercises()
        self.exercises = loaded
        
        // Load stats concurrently
        await withTaskGroup(of: (UUID, UserSessionStats?).self) { group in
            for exercise in loaded {
                group.addTask {
                    let stats = try? await self.statsService.getStats(for: exercise.id)
                    return (exercise.id, stats)
                }
            }
            
            for await (id, stats) in group {
                if let stats = stats {
                    self.exerciseStats[id] = stats
                }
            }
        }
        
        self.error = nil
    } catch {
        self.error = error as? AppError ?? .unknown
    }
}

// ---

if let error = viewModel.error {
    ErrorView(error: error) {
        Task { await viewModel.loadExercises() }
    }
}

// ---

// In ExerciseRepository
func validateJSON() throws {
    let data = try loadJSON()
    let decoder = JSONDecoder()
    let _ = try decoder.decode([Exercise].self, from: data)
    print("✅ ExerciseData.json is valid")
}

// ---

Task {
    try? await ExerciseRepository().validateJSON()
}

// ---

.accessibilityElement(children: .combine)
.accessibilityLabel("Exercise: \(exercise.name)")

// ---

.accessibilityElement(children: .ignore)
.accessibilityLabel("Exercise: \(exercise.name)")
.accessibilityValue("\(exercise.estimatedDuration) minutes, \(exercise.difficulty.displayName)")
.accessibilityHint(stats.map { "Completed \($0.completedCount) times, best score \(Int($0.bestScore))%" } ?? "Not started")

// ---

NavigationLink(value: exercise) {
    ExerciseCard(...)
}
.buttonStyle(.plain) // ❌ Loses standard button feedback

// ---

ExerciseCard(...)
    .opacity(isSelected ? 1.0 : 0.8)
    .scaleEffect(isSelected ? 1.02 : 1.0)

// ---

Text(categoryDisplayName(category))

// ---

private func categoryDisplayName(_ category: ExerciseCategory) -> String {
    switch category {
    case .roadSigns: return "Road Signs"
    case .trafficRules: return "Traffic Rules"
    case .safetyProcedures: return "Safety Procedures"
    case .hazardPerception: return "Hazard Perception"
    case .speedManagement: return "Speed Management"
    }
}

// ---

NavigationLink(value: exercise) {
    ExerciseCard(...)
}
// ❌ Missing: .navigationDestination(for: Exercise) { ... }

// ---

NavigationLink(value: exercise) {
    ExerciseCard(
        exercise: exercise,
        stats: viewModel.exerciseStats[exercise.id],
        isSelected: viewModel.selectedExercise?.id == exercise.id,
        action: { viewModel.selectExercise(exercise) }
    )
}
.navigationDestination(for: Exercise.self) { selectedExercise in
    // Next screen (ExerciseDetailView or SessionStartView)
    // TODO: Define this view or pass as parameter
    Text("Exercise: \(selectedExercise.name)")
}

// ---

if let error = viewModel.error {
    ErrorView(error: error) { // ❌ Not defined anywhere
        Task { await viewModel.loadExercises() }
    }
}

// ---

Text(categoryDisplayName(category)) // ❌ Function not defined

// ---

private func categoryDisplayName(_ category: ExerciseCategory) -> String {
    switch category {
    case .roadSigns: return "Road Signs"
    case .trafficRules: return "Traffic Rules"
    case .safetyProcedures: return "Safety Procedures"
    case .hazardPerception: return "Hazard Perception"
    case .speedManagement: return "Speed Management"
    }
}

// ---

for exercise in loaded {
    await loadStats(for: exercise.id) // 🔴 Blocks UI
}

// ---

func loadExercises() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
        let loaded = try await repository.loadExercises()
        self.exercises = loaded
        
        // Load all stats concurrently
        await withTaskGroup(of: (UUID, UserSessionStats?).self) { group in
            for exercise in loaded {
                group.addTask {
                    do {
                        let stats = try await self.statsService.getStats(for: exercise.id)
                        return (exercise.id, stats)
                    } catch {
                        return (exercise.id, nil)
                    }
                }
            }
            
            for await (id, stats) in group {
                if let stats = stats {
                    self.exerciseStats[id] = stats
                }
            }
        }
        
        self.error = nil
    } catch {
        self.error = error as? AppError ?? .unknown
    }
}

// ---

init(statsService: SessionHistoryService) {
    _viewModel = StateObject(
        wrappedValue: ExerciseSelectionViewModel(statsService: statsService)
    )
}

// ---

// In ContentView or parent:
ExerciseSelectionView(statsService: ???) // ❌ Undefined

// ---

private func loadStats(for exerciseId: UUID) async {
    do {
        let stats = try await statsService.getStats(for: exerciseId)
        self.exerciseStats[exerciseId] = stats
    } catch {
        print("Failed to load stats for exercise \(exerciseId): \(error)") // 🔴 Silently eaten
    }
}

// ---

private func loadStats(for exerciseId: UUID) async {
    do {
        let stats = try await statsService.getStats(for: exerciseId)
        self.exerciseStats[exerciseId] = stats
    } catch {
        // Log to analytics
        Analytics.log(event: "stats_load_failed", 
                     parameters: ["exerciseId": exerciseId.uuidString, "error": "\(error)"])
        // Optionally show non-blocking error banner
    }
}

// ---

actor ExerciseRepository: ExerciseRepositoryProtocol {
    private var cachedExercises: [Exercise]?
    
    func loadExercises() async throws -> [Exercise] {
        if let cached = cachedExercises {
            return cached
        }
        
        let data = try loadJSON()
        let decoder = JSONDecoder()
        let exercises = try decoder.decode([Exercise].self, from: data)
        self.cachedExercises = exercises // ❌ Race on concurrent calls
        return exercises
    }
}

// ---

actor ExerciseRepository: ExerciseRepositoryProtocol {
    private var cachedExercises: [Exercise]?
    private var isLoading = false
    
    func loadExercises() async throws -> [Exercise] {
        if let cached = cachedExercises {
            return cached
        }
        
        // Prevent concurrent loads
        if isLoading {
            while cachedExercises == nil {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            return cachedExercises!
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let data = try loadJSON()
        let decoder = JSONDecoder()
        let exercises = try decoder.decode([Exercise].self, from: data)
        self.cachedExercises = exercises
        return exercises
    }
}

// ---

private var loadTask: Task<[Exercise], Error>?

func loadExercises() async throws -> [Exercise] {
    if let cached = cachedExercises {
        return cached
    }
    
    if let task = loadTask {
        return try await task.value
    }
    
    let task = Task {
        let data = try loadJSON()
        let decoder = JSONDecoder()
        let exercises = try decoder.decode([Exercise].self, from: data)
        self.cachedExercises = exercises
        return exercises
    }
    
    self.loadTask = task
    return try await task.value
}

// ---

.accessibilityElement(children: .combine) // ❌ Combines all labels, unclear
.accessibilityLabel("Exercise: \(exercise.name)")

// ---

.accessibilityElement(children: .ignore)
.accessibilityLabel("Exercise: \(exercise.name)")
.accessibilityValue("\(exercise.estimatedDuration) minutes, \(exercise.difficulty.displayName)")
.accessibilityHint(
    stats.map { "Completed \($0.completedCount) times, best score \(Int($0.bestScore))%" } 
        ?? "Not started"
)
.accessibilityAddTraits(.isButton)

// ---

// In decoder setup:
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
decoder.dateEncodingStrategy = .iso8601