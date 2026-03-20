// File: com.driveai.askfin/data/repository/QuestionRepository.kt
package com.driveai.askfin.data.repository

import com.driveai.askfin.data.models.Question
import com.driveai.askfin.data.models.QuestionCategory
import com.driveai.askfin.data.models.Difficulty
import com.driveai.askfin.data.models.TrainingMode
import com.driveai.askfin.data.models.Pagination
import kotlinx.coroutines.flow.Flow

interface QuestionRepository {
    
    suspend fun getQuestionById(id: String): Result<Question>
    
    suspend fun getQuestionsByCategory(
        category: QuestionCategory,
        pagination: Pagination = Pagination(page = 0, pageSize = 20)
    ): Result<List<Question>>
    
    suspend fun getQuestionsByDifficulty(
        difficulty: Difficulty,
        pagination: Pagination = Pagination(page = 0, pageSize = 20)
    ): Result<List<Question>>
    
    suspend fun getQuestionsByTrainingMode(
        mode: TrainingMode,
        pagination: Pagination = Pagination(page = 0, pageSize = 20)
    ): Result<List<Question>>
    
    suspend fun getFilteredQuestions(
        categories: Set<QuestionCategory>? = null,
        difficulties: Set<Difficulty>? = null,
        modes: Set<TrainingMode>? = null,
        pagination: Pagination = Pagination(page = 0, pageSize = 20)
    ): Result<List<Question>>
    
    suspend fun getAllQuestions(
        pagination: Pagination = Pagination(page = 0, pageSize = 20)
    ): Result<List<Question>>
    
    fun getQuestionsByCategoryFlow(
        category: QuestionCategory,
        pagination: Pagination = Pagination(page = 0, pageSize = 20)
    ): Flow<Result<List<Question>>>
    
    suspend fun refreshQuestions(): Result<Unit>
}