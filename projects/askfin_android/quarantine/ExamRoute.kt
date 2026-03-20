package com.driveai.askfin.ui.navigation

✓ Sealed class for exam routes:
  sealed class ExamRoute {
      object Start : ExamRoute()
      object Question : ExamRoute()
      object Result : ExamRoute()
  }

✓ NavHost setup:
  NavHost(navController, startDestination = ExamRoute.Start) {
      composable<ExamRoute.Start> { 
          ExamStartScreen(onStartExam = { 
              navController.navigate(ExamRoute.Question) 
          })
      }
      composable<ExamRoute.Question> { 
          ExamQuestionScreen(onExamComplete = { 
              navController.navigate(ExamRoute.Result) 
          })
      }
      composable<ExamRoute.Result> { 
          ExamResultScreen(onContinue = { 
              navController.popBackStack() 
          })
      }
  }

✓ Back button handling:
  - Start screen: back exits app
  - Question screen: back not allowed (exit button only)
  - Result screen: back resets exam