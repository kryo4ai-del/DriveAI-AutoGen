# DriveAI Project Memory
Last Updated: Current Chat Session

---

# Project Overview

DriveAI is an iOS learning assistant app for driver's license theory questions.

The app analyzes screenshots or photos of theory questions and returns:

- the most likely correct answer
- an explanation
- optional feedback for learning

The project is built using an **AI Development System with autonomous coding agents**.

Architecture is **SwiftUI + MVVM**.

---

# AI Development System

The project uses an automated AI development pipeline.

Agents:

- LeadAgent
- iOSArchitectAgent
- SwiftDeveloperAgent
- ReviewerAgent
- BugHunterAgent
- RefactorAgent
- TestGeneratorAgent

Development Pipeline:

Task  
→ Implementation  
→ Bug Review  
→ Refactor  
→ Test Generation  
→ Fix Execution  
→ Code Extraction  
→ Xcode Integration  
→ Git Commit  
→ Git Push

New features are generated using CLI commands like:

python main.py --template feature --name FeatureName --profile dev --approval auto

---

# App Architecture

SwiftUI MVVM architecture.

Structure:

DriveAI  
Views  
ViewModels  
Models  
Services  
Components  
Theme  
Helpers

---

# Main UI Screens

OnboardingView
HomeDashboardView
ScannerView
ImageImportView
QuestionView
LearningResultView
MultipleChoiceView
ResultView
AnswerExplanationView
QuizQuestionView
QuizResultView
DemoQuizView
QuestionHistoryView
QuestionHistoryDetailView
AnalysisDebugPanel

---

# UI Design System

Central design components:

PrimaryButton  
SecondaryButton  
CustomTextField  
CustomAlert  
ProgressBar  
CardStyle  

Theme Layer:

AppTheme  
ThemeService  
ColorExtensions  
FontExtensions  
StyleService

---

# Analysis Pipeline

The core analysis pipeline of the app:

Image  
→ OCRRecognitionService  
→ QuestionParsingEngine  
→ MultipleChoiceDetection  
→ QuestionAnalysisService  
→ LLMQuestionSolverService  
→ ResultView

---

# Image Analysis Flow

User Flow:

Dashboard  
→ Import Image / Screenshot  
→ ImageAnalysisService  
→ OCR  
→ Parsing  
→ Solver  
→ Result Screen

---

# Core Services

OCRRecognitionService
ImageAnalysisService
QuestionParsingEngine
MultipleChoiceDetection
QuestionAnalysisService
LLMQuestionSolverService
QuestionHistoryService
LocalDataService
ThemeService
DebugDataService

---

# Core Models

OCRResult
ParsedQuestion
ParsedAnswerOption
Question
Answer
AnswerResult
AnswerConfidence
LearningMode
QuizResult
AnalysisResult
QuestionHistoryEntry
TrafficSign
UserProfile
Category

---

# Debug System

The app includes a debug inspection layer.

Debug Pipeline:

Image  
→ OCR Text  
→ Parsed Question  
→ Detected Answers  
→ Solver Decision

Component:

AnalysisDebugPanel

Purpose:

- understand OCR results
- inspect parsing
- verify solver reasoning

---

# Demo Flow

Demo quiz system for UI preview and testing.

DemoQuizView  
→ QuizQuestionView  
→ QuizResultView  
→ FeedbackView

---

# Code Extraction Rules

Swift types detected:

struct  
class  
enum  
protocol  
extension

Routing:

Views → Views/  
ViewModels → ViewModels/  
Services → Services/  
Models → Models/

Fallback file:

GeneratedHelpers.swift

---

# Placeholder Blocklist

Prevent placeholder types from generating files.

Blocked names:

SomeView  
ContentView  
ExampleView  
DemoView  
SampleView  
TestView  
PlaceholderView  
MockView  
MyView  
MainView  
RootView  
BasicView  

These are redirected to:

GeneratedHelpers.swift

---

# Navigation Flow

DriveAIApp  
→ OnboardingView  
→ HomeDashboardView  
→ Scanner / Import  
→ Analysis Pipeline  
→ ResultView  
→ Feedback

---

# Current System Status

Implemented:

Navigation
Design System
OCR Pipeline
Parsing Engine
Multiple Choice Detection
LLM Solver
Image Import Flow
Result Screen
Answer Explanation (AnswerExplanationFlow)
Confidence Scoring (AnswerConfidenceSystem)
Learning Mode (Assist + Learning)
Question History (with image thumbnails)
Debug Panel

---

# Planned Features (Next)

WeaknessDetection
LearningStatistics
TrafficSignRecognition
TrafficSceneAnalyzer
QuestionCategoryDetection
OfflineRuleEngine

---

# Long-Term Vision

DriveAI is the first application built with a larger system:

AI App Factory

The system will eventually be capable of generating:

Mobile Apps  
Games  
Web Apps  
Education Tools  
AI Utilities

---

# Current Project Status

Architecture: Stable
Analysis Pipeline: Implemented
Design System: Implemented
Navigation: Implemented
Answer + Explanation System: Implemented
Learning Mode: Implemented
Question History + Image Support: Implemented
Debug Tools: Implemented

The project is now a functional learning assistant prototype.

Next focus: Learning intelligence (WeaknessDetection, LearningStatistics) and visual analysis (TrafficSignRecognition).