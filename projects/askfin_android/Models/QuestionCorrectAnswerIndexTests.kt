class QuestionCorrectAnswerIndexTests {
    
    @Test
    fun `Question with correctAnswerIndex at boundary (0) succeeds`() {
        val question = Question(
            id = "q1",
            text = "Test",
            category = QuestionCategory.VORFAHRT,
            answers = listOf(
                Answer("a1", "Correct"),
                Answer("a2", "Wrong")
            ),
            correctAnswerIndex = 0,  // First answer
            explanation = "Explanation",
            createdAt = Instant.now()
        )
        
        assertThat(question.correctAnswerIndex).isEqualTo(0)
    }
    
    @Test
    fun `Question with correctAnswerIndex at upper boundary succeeds`() {
        val answers = listOf(
            Answer("a1", "1"),
            Answer("a2", "2"),
            Answer("a3", "3"),
            Answer("a4", "4")
        )
        val question = Question(
            id = "q2",
            text = "Test",
            category = QuestionCategory.VERKEHRSZEICHEN,
            answers = answers,
            correctAnswerIndex = 3,  // Last answer (index 3 of 4 items)
            explanation = "Explanation",
            createdAt = Instant.now()
        )
        
        assertThat(question.correctAnswerIndex).isEqualTo(3)
    }
    
    @Test
    fun `Question rejects negative correctAnswerIndex`() {
        val exception = assertThrows<IllegalArgumentException> {
            Question(
                id = "q3",
                text = "Test",
                category = QuestionCategory.TECHNIK,
                answers = listOf(Answer("a1", "Option")),
                correctAnswerIndex = -1,
                explanation = "Explanation",
                createdAt = Instant.now()
            )
        }
        assertThat(exception.message).contains("Correct answer index out of bounds")
    }
    
    @Test
    fun `Question rejects correctAnswerIndex beyond answer list size`() {
        val exception = assertThrows<IllegalArgumentException> {
            Question(
                id = "q4",
                text = "Test",
                category = QuestionCategory.VERHALTEN,
                answers = listOf(Answer("a1", "Option")),
                correctAnswerIndex = 5,  // Only 1 answer (index 0)
                explanation = "Explanation",
                createdAt = Instant.now()
            )
        }
        assertThat(exception.message).contains("Correct answer index out of bounds")
    }
}