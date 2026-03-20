// File: src/test/kotlin/com/driveai/askfin/data/models/AnswerTest.kt
package com.driveai.askfin.data.models

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Nested
import kotlin.test.assertEquals
import kotlin.test.assertNull

@DisplayName("Answer Data Model Tests")
class AnswerTest {
    
    private val validAnswer = Answer(
        id = "ans-001",
        text = "This is correct",
        isCorrect = true,
        explanation = "Because it is"
    )
    
    @Nested
    @DisplayName("Happy Path — Valid Answers")
    inner class ValidAnswers {
        @Test
        fun testTC_AN_001_CreateAnswerWithAllFields() {
            val answer = Answer(
                id = "ans-001",
                text = "Valid answer",
                isCorrect = true,
                explanation = "This is why"
            )
            assertEquals("ans-001", answer.id)
            assertEquals("Valid answer", answer.text)
            assertEquals(true, answer.isCorrect)
            assertEquals("This is why", answer.explanation)
        }
        
        @Test
        fun testTC_AN_002_CreateAnswerWithoutExplanation() {
            val answer = Answer(
                id = "ans-002",
                text = "No explanation",
                isCorrect = false
            )
            assertEquals("ans-002", answer.id)
            assertNull(answer.explanation)
        }
        
        @Test
        fun testTC_AN_003_CreateIncorrectAnswer() {
            val answer = Answer(
                id = "ans-003",
                text = "Wrong answer",
                isCorrect = false
            )
            assertEquals(false, answer.isCorrect)
        }
        
        @Test
        fun testTC_AN_004_CreateCorrectAnswerWithExplanation() {
            val answer = Answer(
                id = "ans-004",
                text = "Correct choice",
                isCorrect = true,
                explanation = "Detailed reasoning"
            )
            assertEquals(true, answer.isCorrect)
            assertEquals("Detailed reasoning", answer.explanation)
        }
        
        @Test
        fun testTC_AN_005_MultipleAnswersCanHaveSameText() {
            val ans1 = Answer(id = "ans-1", text = "Same text", isCorrect = true)
            val ans2 = Answer(id = "ans-2", text = "Same text", isCorrect = false)
            assertEquals(ans1.text, ans2.text)
            assertEquals("ans-1", ans1.id)
            assertEquals("ans-2", ans2.id)
        }
    }
    
    @Nested
    @DisplayName("Validation — Invalid Inputs")
    inner class InvalidInputs {
        @Test
        fun testTC_AN_006_BlankIdThrowsException() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                Answer(id = "  ", text = "Valid", isCorrect = true)
            }
        }
        
        @Test
        fun testTC_AN_007_EmptyStringIdThrowsException() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                Answer(id = "", text = "Valid", isCorrect = true)
            }
        }
        
        @Test
        fun testTC_AN_008_BlankTextThrowsException() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                Answer(id = "valid-id", text = "  ", isCorrect = true)
            }
        }
        
        @Test
        fun testTC_AN_009_EmptyStringTextThrowsException() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                Answer(id = "valid-id", text = "", isCorrect = false)
            }
        }
        
        @Test
        fun testTC_AN_010_TabAndNewlineInIdAreTreatedAsBlank() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                Answer(id = "\t\n", text = "Valid", isCorrect = true)
            }
        }
    }
    
    @Nested
    @DisplayName("Equality and Copying")
    inner class EqualityAndCopying {
        @Test
        fun testTC_AN_011_TwoAnswersWithSameDataAreEqual() {
            val ans1 = Answer("id-1", "Text", true, "Explain")
            val ans2 = Answer("id-1", "Text", true, "Explain")
            assertEquals(ans1, ans2)
        }
        
        @Test
        fun testTC_AN_012_AnswersWithDifferentIdsAreNotEqual() {
            val ans1 = Answer("id-1", "Text", true)
            val ans2 = Answer("id-2", "Text", true)
            kotlin.test.assertNotEquals(ans1, ans2)
        }
        
        @Test
        fun testTC_AN_013_CopyAnswerWithModifiedFields() {
            val original = Answer("id-1", "Original", true, "Explain")
            val modified = original.copy(text = "Modified")
            assertEquals("id-1", modified.id)
            assertEquals("Modified", modified.text)
            assertEquals(true, modified.isCorrect)
        }
        
        @Test
        fun testTC_AN_014_CopyWithNullExplanation() {
            val original = Answer("id-1", "Text", true, "Explain")
            val modified = original.copy(explanation = null)
            assertNull(modified.explanation)
        }
        
        @Test
        fun testTC_AN_015_CopiedAnswerValidationIsEnforced() {
            val original = Answer("id-1", "Text", true)
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                original.copy(id = "")
            }
        }
    }
}