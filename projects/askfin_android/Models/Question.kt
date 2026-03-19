@Entity(tableName = "questions")
data class Question(
    @PrimaryKey val id: String,
    val text: String,
    @ColumnInfo(name = "category") val category: QuestionCategory,
    // Store JSON array as string
    @ColumnInfo(name = "answers_json") val answersJson: String,
    val correctAnswerIndex: Int,
    val explanation: String
)

@Entity(
    tableName = "user_answers",
    foreignKeys = [
        ForeignKey(
            entity = Question::class,
            parentColumns = ["id"],
            childColumns = ["question_id"]
        )
    ],
    indices = [
        Index("user_id"),
        Index("question_id"),
        Index("user_id", "question_id")
    ]
)
    @ColumnInfo(name = "user_id") val userId: String,
    @ColumnInfo(name = "question_id") val questionId: String,
    @ColumnInfo(name = "selected_answer_index") val selectedAnswerIndex: Int,
    val isCorrect: Boolean,
    val timestamp: Long
)