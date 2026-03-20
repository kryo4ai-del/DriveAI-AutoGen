package com.driveai.askfin.data.models

// Room will compute incrementally, cache results
@DatabaseView(
    """
    SELECT 
        category,
        COUNT(*) as totalAnswers,
        SUM(CASE WHEN isCorrect = 1 THEN 1 ELSE 0 END) as correctAnswers,
        CAST(SUM(CASE WHEN isCorrect = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) as accuracy
    FROM user_answers
    GROUP BY category
    """
)
data class CategoryStatsView(
    val category: String,
    val totalAnswers: Int,
    val correctAnswers: Int,
    val accuracy: Float
)

interface QuestionDao {
    @Query("SELECT * FROM category_stats_view WHERE userId = :userId")
    fun getCategoryStats(userId: String): Flow<List<CategoryStatsView>>
}

// ViewModel observes Flow → StateFlow
viewModelScope.launch {
    categoryStatsDao.getCategoryStats(userId).collect { stats ->
        _performanceStats.value = stats
    }
}