class QuestionValidationTests {
    
    @Test
    fun `Question rejects blank ID`() {
        val exception = assertThrows<IllegalArgumentException> {
            Question(
                id = "   ",
                text = "Valid text",
                category = QuestionCategory.VORFAHRT,
                answers = listOf(Answer("a1", "Option")),
                correctAnswerIndex = 0,
                explanation = "Valid explanation",
                createdAt = Instant.now()
            )
        }
        assertThat(exception.message).contains("Question ID cannot be blank")
    }
    
    @Test
    fun `Question rejects empty ID string`() {
        val exception = assertThrows<IllegalArgumentException> {
            Question(
                id = "",
                text = "Valid text",
                category = QuestionCategory.VERKEHRSZEICHEN,
                answers = listOf(Answer("a1", "Option")),
                correctAnswerIndex = 0,
                explanation = "Valid explanation",
                createdAt = Instant.now()
            )
        }
        assertThat(exception.message).contains("Question ID cannot be blank")
    }
    
    @Test
    fun `Question rejects blank question text`() {
        val exception = assertThrows<IllegalArgumentException> {
            Question(
                id = "q1",
                text = "   ",
                category = QuestionCategory.TECHNIK,
                answers = listOf(Answer("a1", "Option")),
                correctAnswerIndex = 0,
                explanation = "Valid explanation",
                createdAt = Instant.now()
            )
        }
        assertThat(exception.message).contains("Question text cannot be blank")
    }
    
    @Test
    fun `Question rejects empty answers list`() {
        val exception = assertThrows<IllegalArgumentException> {
            Question(
                id = "q2",
                text = "Valid question",
                category = QuestionCategory.VERHALTEN,
                answers = emptyList(),
                correctAnswerIndex = 0,
                explanation = "Valid explanation",
                createdAt = Instant.now()
            )
        }
        assertThat(exception.message).contains("Question must have at least one answer")
    }
    
    @Test
    fun `Question rejects blank explanation`() {
        val exception = assertThrows<IllegalArgumentException> {
            Question(
                id = "q3",
                text = "Valid question",
                category = QuestionCategory.UMWELT_ENERGIE,
                answers = listOf(Answer("a1", "Option")),
                correctAnswerIndex = 0,
                explanation = "  ",
                createdAt = Instant.now()
            )
        }
        assertThat(exception.message).contains("Explanation cannot be blank")
    }
}