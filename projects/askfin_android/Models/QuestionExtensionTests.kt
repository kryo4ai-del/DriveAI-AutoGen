class QuestionExtensionTests {
    
    @Test
    fun `toAnswerChoices returns all answer texts in order`() {
        val question = Question(
            id = "q1",
            text = "Test",
            category = QuestionCategory.VORFAHRT,
            answers = listOf(
                Answer("a1", "First choice"),
                Answer("a2", "Second choice"),
                Answer("a3", "Third choice")
            ),
            correctAnswerIndex = 0,
            explanation = "Explanation",
            createdAt = Instant.now()
        )
        
        val choices = question.toAnswerChoices()
        assertThat(choices).containsExactly("First choice", "Second choice", "Third choice")
    }
    
    @Test
    fun `getCorrectAnswerText returns text of correct answer`() {
        val question = Question(
            id = "q1",
            text = "Test",
            category = QuestionCategory.VERKEHRSZEICHEN,
            answers = listOf(
                Answer("a1", "Wrong"),
                Answer("a2", "Correct"),
                Answer("a3", "Also wrong")
            ),
            correctAnswerIndex = 1,
            explanation = "Explanation",
            createdAt = Instant.now()
        )
        
        assertThat(question.getCorrectAnswerText()).isEqualTo("Correct")
    }
    
    @Test
    fun `isAnswerCorrect returns true for correct index`() {
        val question = Question(
            id = "q1",
            text = "Test",
            category = QuestionCategory.TECHNIK,
            answers = listOf(Answer("a1", "Option"), Answer("a2", "Correct")),
            correctAnswerIndex = 1,
            explanation = "Explanation",
            createdAt = Instant.now()
        )
        
        assertThat(question.isAnswerCorrect(1)).isTrue()
    }
    
    @Test
    fun `isAnswerCorrect returns false for incorrect index`() {
        val question = Question(
            id = "q1",
            text = "Test",
            category = QuestionCategory.VERHALTEN,
            answers = listOf(Answer("a1", "Correct"), Answer("a2", "Wrong")),
            correctAnswerIndex = 0,
            explanation = "Explanation",
            createdAt = Instant.now()
        )
        
        assertThat(question.isAnswerCorrect(1)).isFalse()
    }
    
    @Test
    fun `isAnswerCorrect returns false for out-of-bounds index`() {
        val question = Question(
            id = "q1",
            text = "Test",
            category = QuestionCategory.UMWELT_ENERGIE,
            answers = listOf(Answer("a1", "Option")),
            correctAnswerIndex = 0,
            explanation = "Explanation",
            createdAt = Instant.now()
        )
        
        assertThat(question.isAnswerCorrect(10)).isFalse()
    }
}