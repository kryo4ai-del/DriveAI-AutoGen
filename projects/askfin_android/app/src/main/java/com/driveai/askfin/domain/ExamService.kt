package com.driveai.askfin.domain

@Singleton
class ExamService @Inject constructor(
    private val questionRepository: QuestionRepository,
    private val examDao: ExamSessionDao // Add DAO for Room persistence
) { ... }