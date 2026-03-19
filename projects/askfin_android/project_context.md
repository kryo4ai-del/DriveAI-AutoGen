# AskFin Android — Project Context

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
- com.driveai.askfin.data.models — Data classes, enums, entities
- com.driveai.askfin.data.repository — Repository interfaces and implementations
- com.driveai.askfin.data.local — Room database, DAOs
- com.driveai.askfin.domain — Business logic, use cases, services
- com.driveai.askfin.ui.screens — @Composable screen functions
- com.driveai.askfin.ui.components — Reusable @Composable components
- com.driveai.askfin.ui.viewmodels — @HiltViewModel classes
- com.driveai.askfin.ui.theme — Material3 theme, colors, typography
- com.driveai.askfin.ui.navigation — NavHost, routes
- com.driveai.askfin.di — Hilt modules

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
