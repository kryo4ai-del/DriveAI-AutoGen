// Views/EpisodicalMemories/EpisodicalMemoriesView.swift

struct EpisodicalMemoriesView: View {
    @StateObject private var memoryService = EpisodicalMemoryService()
    @StateObject private var viewModel: EpisodicalMemoriesViewModel
    @State private var showFilters = false
    @AccessibilityFocusState private var focusedMemoryId: UUID?
    
    init() {
        let service = EpisodicalMemoryService()
        _memoryService = StateObject(wrappedValue: service)
        _viewModel = StateObject(wrappedValue: EpisodicalMemoriesViewModel(memoryService: service))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                // ✅ Error state takes precedence
                if let error = memoryService.error {
                    errorView(error)
                } else if memoryService.isLoading {
                    ProgressView()
                        .accessibilityLabel("Lernmomente werden geladen")
                } else if viewModel.filteredMemories.isEmpty {
                    emptyStateView
                } else {
                    memoryListView
                }
            }
            .navigationTitle("Lernmomente")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    filterButton
                }
            }
            .onAppear {
                Task {
                    await memoryService.loadMemories()
                }
            }
        }
    }
    
    // ✅ COMPLETE filter button implementation
    private var filterButton: some View {
        Menu {
            Section("Nach Gefühl filtern") {
                ForEach(EpisodicalMemory.EmotionalTag.allCases, id: \.self) { tag in
                    Button {
                        viewModel.setFilterTag(viewModel.filterTag == tag ? nil : tag)
                    } label: {
                        HStack {
                            Text(tag.rawValue)
                            if viewModel.filterTag == tag {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                Button("Alle anzeigen") {
                    viewModel.setFilterTag(nil)
                }
            }
            
            Divider()
            
            Section("Sortieren") {
                Picker("Sortierung", selection: $viewModel.sortOption) {
                    ForEach(EpisodicalMemoriesViewModel.SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            }
        } label: {
            Image(systemName: "funnel")
                .accessibilityLabel("Filter und Sortierung")
                .accessibilityHint("Doppeltippen zum Öffnen von Optionen")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(.blue)
                .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                Text("Noch keine Lernmomente erfasst")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Deine Fehler und Erkenntnisse aus Quizzen werden hier gespeichert, um dir zu helfen, besser zu lernen.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: 300)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .accessibilityElement(children: .combine)
    }
    
    private var memoryListView: some View {
        List {
            ForEach(viewModel.filteredMemories, id: \.id) { memory in
                NavigationLink(destination: MemoryDetailView(memory: memory)) {
                    MemoryCardView(memory: memory)
                }
                .focusable(true) { isFocused in
                    if isFocused { focusedMemoryId = memory.id }
                }
            }
            .onDelete { indexSet in
                Task {
                    for index in indexSet.sorted(by: >) {
                        await viewModel.deleteMemory(
                            viewModel.filteredMemories[index].id
                        )
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    // ✅ Error display with retry
    private func errorView(_ error: EpisodicalMemoryService.ServiceError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
                .accessibilityHidden(true)
            
            VStack(spacing: 4) {
                Text("Fehler beim Laden")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                Text(error.errorDescription ?? "Unbekannter Fehler")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                Task {
                    await memoryService.loadMemories()
                }
            }) {
                Label("Erneut versuchen", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Erneut versuchen, Erinnerungen zu laden")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}