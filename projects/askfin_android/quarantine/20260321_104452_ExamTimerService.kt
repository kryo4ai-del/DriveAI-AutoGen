package com.driveai.askfin.domain
import javax.inject.Singleton
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job

@Singleton
class ExamTimerService @Inject constructor(
    private val examService: ExamService,
    @ApplicationScope private val scope: CoroutineScope
) {
    private var timerJob: Job? = null

    fun cleanup() {
        timerJob?.cancel()
        // scope lifecycle managed by Hilt
    }
}