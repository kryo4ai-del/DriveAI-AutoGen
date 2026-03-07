# DriveAI – Project Roadbook

## Project Overview
DriveAI is an iOS app designed to help users in German-speaking countries (DACH) prepare for their driver's license exam. The app provides interactive multiple-choice quizzes, progress tracking, and learning tools based on the official question catalog.

## Target Platform
- iPhone (primary) and iPad (adaptive layout)
- iOS 17+
- SwiftUI-first, no UIKit unless unavoidable
- German language interface

## Core Features
- Multiple-choice question screen with instant feedback
- Category-based question browsing (e.g. traffic signs, right-of-way, fines)
- Progress tracking and statistics per category
- Exam simulation mode (30 questions, timed, pass/fail result)
- Onboarding flow for new users
- User profile screen (exam date countdown, overall score, streak)
- Offline-capable (local question database)

## UI/UX Goals
- Clean, minimal iOS design following Apple HIG
- Dark mode support
- Accessibility-friendly (Dynamic Type, VoiceOver)
- Smooth navigation transitions
- Visual feedback on correct/incorrect answers
- Progress bars and streak indicators for motivation

## Architecture Notes
- MVVM pattern throughout
- Separate ViewModels per screen
- LocalDataService for question database (SQLite or JSON)
- No backend required for MVP — fully offline
- Modular folder structure: Models/, ViewModels/, Views/, Services/, Resources/
- NavigationStack for routing (iOS 16+)

## MVP Scope
1. Onboarding screen (welcome + exam date picker)
2. Home/Dashboard screen (progress summary, quick start)
3. Question screen (multiple-choice with feedback)
4. Category overview screen
5. Exam simulation screen (30 questions, timer, result)
6. Result screen (pass/fail, score breakdown)
7. Profile screen (stats, streak, exam countdown)
