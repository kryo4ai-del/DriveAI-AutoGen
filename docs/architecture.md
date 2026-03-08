# DriveAI Architecture

Last Updated: Current Session

---

# System Overview

DriveAI consists of two major systems:

1. AI Development System (AutoGen Agents)
2. iOS Application (SwiftUI MVVM)

The AI system builds and maintains the application automatically.

---

# High-Level Architecture

User
↓
DriveAI App (SwiftUI)
↓
Image Analysis Pipeline
↓
AI Solver
↓
Result + Explanation

---

# App Entry Flow

DriveAIApp
↓
OnboardingView
↓
HomeDashboardView
↓
Scanner / Image Import
↓
ImageAnalysisView
↓
ResultView
↓
FeedbackView

---

# UI Layer

Views:

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

These represent the visual interface.

---

# ViewModel Layer

ViewModels connect UI to logic.

Example:

QuestionView
↓
QuestionViewModel
↓
QuestionAnalysisService

Responsibilities:

- UI state
- user interaction
- service calls

---

# Service Layer

Core business logic.

Services:

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

# Analysis Pipeline

Image
↓
OCRRecognitionService
↓
Extract Text
↓
QuestionParsingEngine
↓
ParsedQuestion
↓
MultipleChoiceDetection
↓
AnswerCandidates
↓
QuestionAnalysisService
↓
SolverInput
↓
LLMQuestionSolverService
↓
AnswerPrediction
↓
ResultView

---

# Debug Layer

AnalysisDebugPanel exposes internal pipeline data.

Image
↓
OCR Text
↓
Parsed Question
↓
Detected Answers
↓
Solver Decision

Purpose:

- debugging
- pipeline transparency
- solver tuning

---

# Design System

Centralized UI system.

Components:

PrimaryButton  
SecondaryButton  
CustomTextField  
ProgressBar  
CardStyle  

Theme System:

AppTheme  
ThemeService  
ColorExtensions  
FontExtensions  

Goal:

Maintain consistent UI across all screens.

---

# Data Models

Core models:

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

---

# Code Generation System

Swift code is generated via AI agents.

Extractor detects:

struct  
class  
enum  
protocol  
extension  

Routing rules:

Views → Views/  
ViewModels → ViewModels/  
Services → Services/  
Models → Models/  

Fallback file:

GeneratedHelpers.swift

---

# Blocklist System

Prevents placeholder SwiftUI names from generating files.

Blocked:

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

Redirected to:

GeneratedHelpers.swift

---

# Current Architecture Status

UI Layer: Implemented
Service Layer: Implemented
Analysis Pipeline: Implemented
Answer + Explanation System: Implemented
Learning Mode: Implemented
Question History + Image Storage: Implemented
Debug Layer: Implemented
Design System: Implemented

The architecture is stable and ready for feature expansion.