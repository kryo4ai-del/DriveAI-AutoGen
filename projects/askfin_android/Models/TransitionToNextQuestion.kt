@Composable
fun TransitionToNextQuestion() {
    val shouldReduceMotion = LocalContext.current.resources.configuration.uiMode
        .and(Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_NO
    
    val animationDuration = if (shouldReduceMotion) 0 else 300
    
    AnimatedContent(targetState = currentIndex, animationSpec = tween(animationDuration)) { index ->
        QuestionCard(allQuestions[index])
    }
}