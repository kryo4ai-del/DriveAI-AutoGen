# BreathFlow — Project Context

## Architecture
- Language: Swift
- UI: SwiftUI
- Architecture: MVVM
- Persistence: UserDefaults (session history, weekly stats)
- Target: iOS 17+

## Package Structure
- Models/ — Data types (BreathingTechnique, SessionRecord, WeeklyStats)
- ViewModels/ — BreathingViewModel, ProgressViewModel
- Views/ — ExerciseSelectionView, BreathingView, SessionCompleteView
- Services/ — TimerService, StatsService

## Conventions
- Offline-only, no network calls
- No account, no login
- Animations: Circle expand/contract with SwiftUI .animation()
- Timer: Countdown with phases (inhale, hold, exhale)
- Data: UserDefaults for weekly minutes tracking

## DO NOT
- No custom graphics — use SF Symbols and SwiftUI shapes
- No backend or API
- No analytics or tracking
- No account or login
