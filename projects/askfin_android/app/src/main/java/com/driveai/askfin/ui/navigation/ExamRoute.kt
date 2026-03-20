package com.driveai.askfin.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavController
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable

sealed class ExamRoute {
    object Start : ExamRoute()
    object Question : ExamRoute()
    object Result : ExamRoute()
}

@Composable
fun ExamNavHost(navController: NavHostController) {
    NavHost(navController, startDestination = ExamRoute.Start::class.simpleName ?: "Start") {
        composable("Start") {
            ExamStartScreen(onStartExam = {
                navController.navigate("Question")
            })
        }
        composable("Question") {
            ExamQuestionScreen(onExamComplete = {
                navController.navigate("Result")
            })
        }
        composable("Result") {
            ExamResultScreen(onContinue = {
                navController.popBackStack()
            })
        }
    }
}

@Composable
fun ExamStartScreen(onStartExam: () -> Unit) {
    // Start screen: back exits app
}

@Composable
fun ExamQuestionScreen(onExamComplete: () -> Unit) {
    // Question screen: back not allowed (exit button only)
}

@Composable
fun ExamResultScreen(onContinue: () -> Unit) {
    // Result screen: back resets exam
}