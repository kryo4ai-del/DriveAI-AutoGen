// com.driveai.askfin.ui.screens.test.ExamQuestionScreenTest.kt
package com.driveai.askfin.data.models

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import com.driveai.askfin.data.models.Question
import com.driveai.askfin.ui.screens.ExamQuestionScreen
import com.driveai.askfin.ui.viewmodels.ExamSimulationViewModel
import io.mockk.mockk
import org.junit.Rule
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test

class ExamQuestionScreenTest {
    
    @get:Rule
    val composeTestRule = createComposeRule()
    
    private lateinit var mockViewModel: ExamSimulationViewModel
    
    @BeforeEach
    fun setUp() {
        mockViewModel = mockk(relaxed = true)
    }
}