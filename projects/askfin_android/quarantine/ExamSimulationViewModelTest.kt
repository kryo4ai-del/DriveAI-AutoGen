// com.driveai.askfin.ui.viewmodels.test.ExamSimulationViewModelTest.kt
package com.driveai.askfin.data.models

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import com.driveai.askfin.data.models.Question
import com.driveai.askfin.data.repository.ExamRepository
import com.driveai.askfin.ui.viewmodels.ExamSimulationViewModel
import io.mockk.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class ExamSimulationViewModelTest {
    
    private val testDispatcher = StandardTestDispatcher()
    
    @JvmField
    val instantTaskExecutorRule = InstantTaskExecutorRule()
    
    private lateinit var mockExamRepository: ExamRepository
    private lateinit var viewModel: ExamSimulationViewModel
    
    @BeforeEach
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
        mockExamRepository = mockk(relaxed = true)
        viewModel = ExamSimulationViewModel(mockExamRepository)
    }
    
    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }
}