package com.driveai.askfin.domain
import javax.inject.Singleton
import javax.inject.Inject

@Singleton
class ExamService @Inject constructor(
    private val questionRepository: QuestionRepository,
    private val examDao: ExamSessionDao // Add DAO for Room persistence
) { ... }