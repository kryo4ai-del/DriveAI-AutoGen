package com.driveai.askfin.ui.screens
import androidx.compose.runtime.Composable
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.runtime.remember
import android.view.HapticFeedbackConstants

@Composable
fun ExamSimulationScreen(
    viewModel: ExamSimulationViewModel = hiltViewModel()
) {
    val hapticFeedback: HapticFeedback = remember {
        // Manual injection via LocalContext
        val context = LocalContext.current
        HapticFeedback(context)
    }
    // ...
}