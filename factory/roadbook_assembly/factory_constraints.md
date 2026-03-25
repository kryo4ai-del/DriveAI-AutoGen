# DriveAI Factory — Production Capabilities & Constraints

## Available Production Lines
- **iOS Line**: Swift + SwiftUI + MVVM (proven: 234 files, App Store ready)
- **Android Line**: Kotlin + Jetpack Compose + Hilt (proven: 537 files generated)
- **Web Line**: TypeScript + React + Next.js (proven: 197 files generated)
- **Unity Line**: C# + Unity Engine + URP (extractor + assembly ready, no shipped product yet)

## Build System
- iOS: xcodegen → Xcode → .ipa (via Mac Bridge)
- Android: Gradle → .aab
- Web: npm → Next.js build
- Pipeline: Hybrid (SelectorGroupChat + Single-Call Reviews), $0.08/run

## What the Factory CAN Do
- Generate code feature-by-feature via layered pipeline (Foundation → Domain → Application → Presentation → Polish)
- Auto-repair: deterministic fixes + LLM repair (3-tier coordinator)
- Compile hygiene: type stubs, import hygiene, shape repair, stale artifact guard
- Assembly with wiring (NavHost, Hilt modules, Theme, Navigation)
- Store submission pipeline (metadata, compliance, packaging)
- Autonomous Mac builds via Git-queue

## What the Factory CANNOT Do
- Custom game engines or physics systems (no custom Unity gameplay beyond basic templates)
- Custom ML/AI backends (no training, no model deployment, no Cloud Run)
- Real-time multiplayer server infrastructure
- Custom backend APIs (no Firebase Cloud Functions, no custom REST APIs)
- Native hardware integrations beyond standard APIs (no ARKit, no custom camera pipelines)
- Stable Diffusion or any local AI image generation

## Hard Limits for Factory Mode Roadbooks
- **Max 20 features** in Phase A (MVP)
- **Max 12 screens** total
- **Tech stack**: SwiftUI (iOS), Kotlin/Compose (Android), React/Next.js (Web) — pick appropriate for the product
- **No custom backend**: only local storage (UserDefaults, Room, localStorage) or standard BaaS (Firebase Auth, Firestore) if absolutely needed
- **No AI/ML features** that require custom model training or deployment
- **Budget realistic for solo dev + factory**: Phase A should be achievable in 4-8 weeks factory time
- **Monetization**: AdMob rewarded ads + IAP only (no subscription backend, no custom payment flows)
- **Testing**: XCUITest Golden Gates (iOS), JUnit (Android), Jest (Web) — the factory generates these

## Tone for Factory Mode
The roadbook should feel like a confident build plan, not a dream document. Every feature listed must be buildable by the factory within the stated constraints. If a feature from the research is exciting but not buildable, mention it in a "Future Vision" appendix — not in the main feature list.
