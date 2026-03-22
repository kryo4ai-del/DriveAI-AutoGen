# BreathFlow Android — Project Context

## Architecture
- Language: Kotlin
- UI Framework: Jetpack Compose with Material 3
- Architecture: MVVM with Hilt dependency injection
- Async: Kotlin Coroutines + StateFlow
- Navigation: Navigation Compose
- Persistence: Room Database + DataStore
- Build: Gradle (Kotlin DSL)
- Min SDK: 26 (Android 8.0)

## Package Structure
- com.driveai.breathflow.data.models — Data classes, enums, entities
- com.driveai.breathflow.data.repository — Repository interfaces and implementations
- com.driveai.breathflow.data.local — Room database, DAOs
- com.driveai.breathflow.domain — Business logic, use cases, services
- com.driveai.breathflow.ui.screens — @Composable screen functions
- com.driveai.breathflow.ui.components — Reusable @Composable components
- com.driveai.breathflow.ui.viewmodels — @HiltViewModel classes
- com.driveai.breathflow.ui.theme — Material3 theme, colors, typography
- com.driveai.breathflow.ui.navigation — NavHost, routes
- com.driveai.breathflow.di — Hilt modules

## Conventions
- Data models: Kotlin data classes with val properties
- State: StateFlow in ViewModels, collectAsState() in Composables
- DI: @Inject constructor, @HiltViewModel, @Module/@InstallIn
- Navigation: Sealed class for routes, NavHost with composable() destinations
- Error handling: Result<T> or sealed class for UI state (Loading/Success/Error)
- Testing: JUnit 5 + Mockk + Compose Testing

## DO NOT
- Do NOT use Swift, SwiftUI, or any Apple framework
- Do NOT use XML layouts — Compose only
- Do NOT use LiveData — use StateFlow
- Do NOT use Dagger without Hilt — use Hilt
- Do NOT use Java — Kotlin only
