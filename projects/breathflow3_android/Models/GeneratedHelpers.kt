Plan: PLAN-001
Project: breathflow-android
Linked Specs: none (to be created)
Readiness: needs_spec
Recommended Phase: planning → bootstrap → spec_creation
Selected Agents: 
  - ProductStrategist (project intake, scope validation)
  - ProjectBootstrap (Android project structure, Gradle setup)
  - AndroidArchitect (MVVM + Hilt design review)
  - KotlinDeveloper (code generation for feature)
  - TestGenerator (test structure)

Execution Steps:
1. [ProductStrategist] Register BreathFlow Android in project_registry.json
   - Set platform: Android, language: Kotlin, status: planning
   - Define MVP scope: ExerciseSelection + BreathingScreen + StatsService
   - Establish min SDK 26, target SDK 35 (current stable)

2. [ProjectBootstrap] Initialize Android project structure
   - Create Gradle wrapper with Kotlin DSL (build.gradle.kts)
   - Set up Hilt dependency injection modules
   - Configure Room database + DataStore dependencies
   - Add Jetpack Compose + Material 3 dependencies
   - Create package hierarchy per architecture guidelines
   - Generate AndroidManifest.xml template

3. [AndroidArchitect] Design MVVM + Hilt schema for breathing feature
   - Document ViewModel lifecycle for breathing timer (coroutine cleanup)
   - Design StateFlow emission patterns (selectedTechnique, currentPhase, progress)
   - Plan error handling (Result<T> sealed classes for UI states)
   - Define DI module structure (@Module, @InstallIn, @Provides, @Binds)
   - Create sealed classes for navigation routes + screen destinations

4. [ProductStrategist] Create SPEC-001: ExerciseSelection & BreathingScreen Feature
   - Define BreathingTechnique enum (4-7-8, Box, Calm with exact durations)
   - Specify BreathingViewModel state machine (IDLE → INHALE → HOLD → EXHALE → COMPLETE)
   - Design UI: selection card layout, animated breathing circle (Canvas + animateFloatAsState)
   - Detail SessionRecord persistence (Room entity + stats aggregation)
   - Include test coverage matrix (ViewModel, Composables, Services)

5. [AndroidArchitect] Code review of SPEC-001
   - Validate ViewModel coroutine patterns (viewModelScope, Job cancellation)
   - Verify Hilt injection points match architecture conventions
   - Check Compose state management (collectAsState, remember)
   - Confirm Room query structure for weekly stats aggregation

6. [KotlinDeveloper] Generate core feature code
   - Implement BreathingTechnique.kt enum with all durations
   - Generate BreathingViewModel.kt with state machine + coroutine timer
   - Create Composables: ExerciseSelectionScreen, BreathingScreen, TechniqueCard
   - Implement StatsService (DataStore persistence)
   - Generate SessionRecord data class + Room entities/DAOs

7. [TestGenerator] Create test suite
   - BreathingViewModel unit tests (JUnit 5 + Mockk)
   - Composable snapshot/interaction tests (Compose Testing)
   - SessionRepository + StatsService integration tests
   - Test timer accuracy and cancellation on pause/stop

8. [ProductStrategist] Plan next phases
   - Define compliance review scope (breathing exercise safety, privacy if cloud-based)
   - Create content roadmap (onboarding, app store listing)
   - Schedule accessibility audit (Material 3 contrast, haptic feedback timing)

Blockers:
- ⚠️ BreathFlow Android not registered in factory yet (prevents scheduling)
- ⚠️ No Gradle project structure initialized (code generation needs working build)
- ⚠️ Compliance scope for breathing domain unknown (health/wellness claims?)

Risks:
- **Timer Accuracy:** Coroutine delay() is not guaranteed sub-second precision; may cause user-visible jitter in animation. Mitigation: measure elapsed time, not loop count; use SystemClock.uptimeMillis()
- **Memory Leak:** Breathing timer coroutine may hold ViewModel if Activity destroyed mid-session. Mitigation: use viewModelScope (automatically cancelled), test with Turbine
- **Compose State Recomposition:** Frequent progress updates (every 50ms) may cause excessive redraws. Mitigation: use animateFloatAsState() for smooth animation; emit progress updates at 20Hz, not per-frame
- **DataStore Persistence:** Initial write to DataStore may delay session save. Mitigation: queue in-memory, batch writes weekly

Suggested Run:

// ---

plugins {
    id("com.android.application") version "8.2.0" apply false
    id("com.android.library") version "8.2.0" apply false
    kotlin("android") version "1.9.21" apply false
    kotlin("jvm") version "1.9.21" apply false
    id("com.google.dagger.hilt.android") version "2.48" apply false
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}

// ---

plugins {
    id("com.android.application")
    kotlin("android")
    kotlin("kapt")
    id("com.google.dagger.hilt.android")
}

android {
    namespace = "com.driveai.breathflow"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.driveai.breathflow"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.8"
    }

    packagingOptions {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    // Core Android
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.6.2")
    implementation("androidx.activity:activity-compose:1.8.0")

    // Jetpack Compose
    implementation(platform("androidx.compose:compose-bom:2023.10.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3:1.1.2")
    implementation("androidx.compose.material:material-icons-extended:1.5.4")

    // Navigation
    implementation("androidx.navigation:navigation-compose:2.7.5")

    // Hilt Dependency Injection
    implementation("com.google.dagger:hilt-android:2.48")
    kapt("com.google.dagger:hilt-compiler:2.48")
    implementation("androidx.hilt:hilt-navigation-compose:1.1.0")

    // Room Database
    implementation("androidx.room:room-runtime:2.6.1")
    kapt("androidx.room:room-compiler:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")

    // DataStore
    implementation("androidx.datastore:datastore-preferences:1.0.0")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

    // Testing
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
    testImplementation("io.mockk:mockk:1.13.8")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")

    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    androidTestImplementation(platform("androidx.compose:compose-bom:2023.10.01"))
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}

// ---

while (_isActive.value) {
    val elapsedInPhaseMs = System.currentTimeMillis() - phaseStartTimeMs
    if (elapsedInPhaseMs >= durationMs) break
    
    _progress.value = (elapsedInPhaseMs.toFloat() / durationMs).coerceIn(0f, 1f)
    delay(UPDATE_INTERVAL_MS)  // ← JITTER SOURCE
}

// ---

private suspend fun runBreathingPhase(
    phase: BreathingPhase,
    durationMs: Int
) {
    _currentPhase.value = phase
    val phaseStartTimeMs = System.currentTimeMillis()
    
    // FIXED: Use fixed-rate emission, not loop + delay
    val emissionIntervalMs = 16L // ~60fps for smooth animation
    
    while (_isActive.value) {
        val now = System.currentTimeMillis()
        val elapsedInPhaseMs = now - phaseStartTimeMs
        
        if (elapsedInPhaseMs >= durationMs) {
            _progress.value = 1f
            _timeRemaining.value = 0
            break
        }
        
        // Monotonic progress — never goes backward
        _progress.value = (elapsedInPhaseMs.toFloat() / durationMs).coerceIn(0f, 1f)
        _timeRemaining.value = ((durationMs - elapsedInPhaseMs) / 1000).toInt()
        
        sessionElapsedTimeMs = elapsedInPhaseMs  // Update total, not += increment
        delay(emissionIntervalMs)
    }
}

// ---

fun pauseBreathing() {
    timerJob?.cancel()      // ← Cancels current job
    _isActive.value = false
}

fun resumeBreathing() {
    val technique = _selectedTechnique.value ?: return
    if (_isActive.value) return
    
    _isActive.value = true
    timerJob = viewModelScope.launch {  // ← Creates NEW job, overwrites old reference
        val totalDurationMs = 5 * 60 * 1000L  // ← HARDCODED! Loses original duration
        runBreathingSession(technique, totalDurationMs)
    }
}

// ---

val progress by viewModel.progress.collectAsState()  // Recomposes on every emission
val timeRemaining by viewModel.timeRemaining.collectAsState()  // Recomposes again

// Both states update at different times during phase transition
Canvas(modifier = Modifier.size(200.dp)) {
    val radius = 50f * (1f + progress * 0.5f)  // ← Uses progress from last emission
    drawCircle(Color.Blue, radius = radius)
}

// ---

timerJob = viewModelScope.launch {
    val totalDurationMs = durationMinutes * 60 * 1000L
    runBreathingSession(technique, totalDurationMs)
    // ↑ If SessionRepository.saveSession() throws, exception is SWALLOWED
}

// ---

timerJob = viewModelScope.launch {
    try {
        val totalDurationMs = durationMinutes * 60 * 1000L
        runBreathingSession(technique, totalDurationMs)
    } catch (e: CancellationException) {
        // Expected when session is paused/stopped
        throw e  // Re-throw to propagate cancellation
    } catch (e: Exception) {
        _isActive.value = false
        _currentPhase.value = BreathingPhase.IDLE
        _errorMessage.value = "Session error: ${e.localizedMessage}"
        Timber.e(e, "Breathing session failed")  // Add Timber for logging
    }
}

// ---

val weeklyMinutes by viewModel.weeklyMinutes.collectAsState()  // Recomposes ALL items
val sessionCount by viewModel.sessionCount.collectAsState()

LazyColumn(...) {
    items(BreathingTechnique.values()) { technique ->
        TechniqueCard(
            technique = technique,
            onSelect = {
                viewModel.selectTechnique(technique)
                onTechniqueSelected()  // ← Triggers navigation
            }
        )
    }
}