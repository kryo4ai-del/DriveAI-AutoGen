@Composable
fun ExerciseSelectionScreen(
    onTechniqueSelected: () -> Unit,
    viewModel: BreathingViewModel = hiltViewModel()
) {
    val weeklyMinutes by viewModel.weeklyMinutes.collectAsState()
    val sessionCount by viewModel.sessionCount.collectAsState()
    
    // Memoize callback
    val handleTechniqueSelect = remember { { technique: BreathingTechnique ->
        viewModel.selectTechnique(technique)
        onTechniqueSelected()
    }}
    
    Scaffold { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp)
        ) {
            // Header (recomposes independently)
            TechniquesHeader()
            
            // Stats (in separate composable to isolate recomposition)
            StatsSection(weeklyMinutes, sessionCount)
            
            // List (wrapped in remember to prevent re-creation)
            val techniques = remember { BreathingTechnique.values().toList() }
            
            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.weight(1f)
            ) {
                items(
                    items = techniques,
                    key = { it.ordinal }  // Stable key prevents reordering
                ) { technique ->
                    TechniqueCard(
                        technique = technique,
                        onSelect = { handleTechniqueSelect(technique) }
                    )
                }
            }
        }
    }
}

@Composable
private fun StatsSection(
    weeklyMinutes: Int,
    sessionCount: Int,
    modifier: Modifier = Modifier
) {
    // Isolated recomposition — doesn't affect LazyColumn
    Column(modifier = modifier.padding(vertical = 8.dp)) {
        Text("This Week")
        Text("$weeklyMinutes minutes • $sessionCount sessions")
    }
}