class QuestionFactoryTests {
    
    @Test
    fun `Question_create factory produces valid instance`() {
        val question = Question.create(
            id = "q1",
            text = "Factory test",
            category = QuestionCategory.VORFAHRT,
            answers = listOf(Answer("a1", "Option")),
            correctAnswerIndex = 0,
            explanation = "Explanation"
        )
        
        assertThat(question.id).isEqualTo("q1")
        assertThat(question.createdAt).isNotNull()
        assertThat(question.difficulty).isEqualTo(DifficultyLevel.MEDIUM)
        assertThat(question.imageUrl).isNull()
    }
    
    @Test
    fun `Question_create factory generates fresh timestamp per call`() {
        val q1 = Question.create(
            id = "q1",
            text = "First",
            category = QuestionCategory.VERKEHRSZEICHEN,
            answers = listOf(Answer("a1", "Option")),
            correctAnswerIndex = 0,
            explanation = "Explanation"
        )
        
        Thread.sleep(50)  // Ensure time difference
        
        val q2 = Question.create(
            id = "q2",
            text = "Second",
            category = QuestionCategory.VERKEHRSZEICHEN,
            answers = listOf(Answer("a1", "Option")),
            correctAnswerIndex = 0,
            explanation = "Explanation"
        )
        
        assertThat(q1.createdAt).isBefore(q2.createdAt)
    }
    
    @Test
    fun `Question_create factory respects custom difficulty`() {
        val question = Question.create(
            id = "q1",
            text = "Test",
            category = QuestionCategory.TECHNIK,
            answers = listOf(Answer("a1", "Option")),
            correctAnswerIndex = 0,
            explanation = "Explanation",
            difficulty = DifficultyLevel.HARD
        )
        
        assertThat(question.difficulty).isEqualTo(DifficultyLevel.HARD)
    }
    
    @Test
    fun `Question_create factory respects custom imageUrl`() {
        val url = "https://example.com/image.jpg"
        val question = Question.create(
            id = "q1",
            text = "Test",
            category = QuestionCategory.VORFAHRT,
            answers = listOf(Answer("a1", "Option")),
            correctAnswerIndex = 0,
            explanation = "Explanation",
            imageUrl = url
        )
        
        assertThat(question.imageUrl).isEqualTo(url)
    }
}