class QuestionTests {
    
    @Test
    fun `Question creation with valid data succeeds`() {
        val answers = listOf(
            Answer("a1", "Option 1"),
            Answer("a2", "Option 2"),
            Answer("a3", "Option 3")
        )
        val createdAt = Instant.parse("2026-03-18T10:00:00Z")
        
        val question = Question(
            id = "q1",
            text = "What is a valid answer?",
            category = QuestionCategory.VORFAHRT,
            answers = answers,
            correctAnswerIndex = 1,
            explanation = "Option 2 is correct because...",
            createdAt = createdAt,
            difficulty = DifficultyLevel.MEDIUM
        )
        
        assertThat(question.id).isEqualTo("q1")
        assertThat(question.text).isEqualTo("What is a valid answer?")
        assertThat(question.answers).hasSize(3)
        assertThat(question.correctAnswerIndex).isEqualTo(1)
        assertThat(question.difficulty).isEqualTo(DifficultyLevel.MEDIUM)
        assertThat(question.createdAt).isEqualTo(createdAt)
    }
    
    @Test
    fun `Question with optional imageUrl stores it correctly`() {
        val question = Question(
            id = "q2",
            text = "What sign is this?",
            category = QuestionCategory.VERKEHRSZEICHEN,
            answers = listOf(Answer("a1", "Stop"), Answer("a2", "Yield")),
            correctAnswerIndex = 0,
            explanation = "This is a stop sign",
            createdAt = Instant.now(),
            imageUrl = "https://example.com/stop_sign.jpg"
        )
        
        assertThat(question.imageUrl).isEqualTo("https://example.com/stop_sign.jpg")
    }
    
    @Test
    fun `Question with default difficulty assigns MEDIUM`() {
        val question = Question(
            id = "q3",
            text = "Test",
            category = QuestionCategory.VERHALTEN,
            answers = listOf(Answer("a1", "Yes"), Answer("a2", "No")),
            correctAnswerIndex = 0,
            explanation = "Explanation",
            createdAt = Instant.now()
            // difficulty not specified
        )
        
        assertThat(question.difficulty).isEqualTo(DifficultyLevel.MEDIUM)
    }
    
    @Test
    fun `Question with EASY difficulty is created correctly`() {
        val question = Question(
            id = "q4",
            text = "Easy question",
            category = QuestionCategory.TECHNIK,
            answers = listOf(Answer("a1", "A"), Answer("a2", "B")),
            correctAnswerIndex = 0,
            explanation = "Easy explanation",
            createdAt = Instant.now(),
            difficulty = DifficultyLevel.EASY
        )
        
        assertThat(question.difficulty).isEqualTo(DifficultyLevel.EASY)
    }
    
    @Test
    fun `Question with HARD difficulty is created correctly`() {
        val question = Question(
            id = "q5",
            text = "Hard question",
            category = QuestionCategory.FIRST_AID,
            answers = listOf(Answer("a1", "A"), Answer("a2", "B"), Answer("a3", "C")),
            correctAnswerIndex = 2,
            explanation = "Hard explanation",
            createdAt = Instant.now(),
            difficulty = DifficultyLevel.HARD
        )
        
        assertThat(question.difficulty).isEqualTo(DifficultyLevel.HARD)
    }
}