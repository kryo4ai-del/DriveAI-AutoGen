// File: src/test/kotlin/com/driveai/askfin/data/models/TrainingModeTest.kt
package com.driveai.askfin.data.models

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Nested
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

@DisplayName("TrainingMode Enum Tests")
class TrainingModeTest {
    
    @Nested
    @DisplayName("Enum Values")
    inner class EnumValues {
        @Test
        fun testAllFourModesDefined() {
            val modes = TrainingMode.values()
            assertEquals(4, modes.size)
            assertEquals(setOf("LEARNER", "PRACTICE", "EXAM", "REVIEW"), 
                modes.map { it.name }.toSet())
        }
        
        @Test
        fun testLearnerModeExists() {
            assertNotNull(TrainingMode.LEARNER)
        }
        
        @Test
        fun testPracticeModeExists() {
            assertNotNull(TrainingMode.PRACTICE)
        }
        
        @Test
        fun testExamModeExists() {
            assertNotNull(TrainingMode.EXAM)
        }
        
        @Test
        fun testReviewModeExists() {
            assertNotNull(TrainingMode.REVIEW)
        }
    }
    
    @Nested
    @DisplayName("Enum Conversion")
    inner class EnumConversion {
        @Test
        fun testValueOfReturnsCorrectModeForLearner() {
            val mode = TrainingMode.valueOf("LEARNER")
            assertEquals(TrainingMode.LEARNER, mode)
        }
        
        @Test
        fun testValueOfReturnsCorrectModeForPractice() {
            val mode = TrainingMode.valueOf("PRACTICE")
            assertEquals(TrainingMode.PRACTICE, mode)
        }
        
        @Test
        fun testValueOfReturnsCorrectModeForExam() {
            val mode = TrainingMode.valueOf("EXAM")
            assertEquals(TrainingMode.EXAM, mode)
        }
        
        @Test
        fun testValueOfReturnsCorrectModeForReview() {
            val mode = TrainingMode.valueOf("REVIEW")
            assertEquals(TrainingMode.REVIEW, mode)
        }
        
        @Test
        fun testValueOfThrowsExceptionForInvalidMode() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                TrainingMode.valueOf("INVALID_MODE")
            }
        }
    }
}