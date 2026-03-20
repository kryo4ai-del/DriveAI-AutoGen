package com.driveai.askfin.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController

sealed class Route(val route: String) {
    data object Home : Route("home")
    data object Training : Route("training")
    data object Exam : Route("exam")
    data object SkillMap : Route("skill_map")
    data object Readiness : Route("readiness")
}

@Composable
fun AskFinNavHost() {
    val navController = rememberNavController()
    NavHost(navController = navController, startDestination = Route.Home.route) {
        composable(Route.Home.route) { /* TODO: HomeScreen */ }
        composable(Route.Training.route) { /* TODO: TrainingScreen */ }
        composable(Route.Exam.route) { /* TODO: ExamScreen */ }
        composable(Route.SkillMap.route) { /* TODO: SkillMapScreen */ }
        composable(Route.Readiness.route) { /* TODO: ReadinessScreen */ }
    }
}