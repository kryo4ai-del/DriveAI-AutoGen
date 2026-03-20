package com.driveai.askfin.ui.components
import androidx.compose.runtime.Composable
import androidx.compose.animation.core.tween
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.runtime.remember
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import android.content.res.Configuration

// Placeholder types
data class QuestionData(val text: String = "", val options: List<String> = emptyList())
@Composable
fun QuestionCard(question: QuestionData) {}

@OptIn(ExperimentalAnimationApi::class)
@Composable
fun TransitionToNextQuestion() {
    val allQuestions = remember { listOf(QuestionData()) }
    var currentIndex by remember { mutableStateOf(0) }

    val shouldReduceMotion = LocalContext.current.resources.configuration.uiMode
        .and(Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_NO
    
    val animationDuration = if (shouldReduceMotion) 0 else 300
    
    AnimatedContent(targetState = currentIndex, transitionSpec = { tween<Float>(animationDuration).let { androidx.compose.animation.fadeIn(it) with androidx.compose.animation.fadeOut(it) } }) { index ->
        QuestionCard(allQuestions[index])
    }
}