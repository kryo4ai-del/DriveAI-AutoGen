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
        fun `TC-AN-001: Create answer with all fields`() {
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
        fun `TC-AN-002: Create answer without explanation (default null)`() {
            val answer = Answer(
                id = "ans-002",
                text = "No explanation",
                isCorrect = false
            )
            assertEquals("ans-002", answer.id)
            assertNull(answer.explanation)
        }
        
        @Test
        fun `TC-AN-003: Create incorrect answer`() {
            val answer = Answer(
                id = "ans-003",
                text = "Wrong answer",
                isCorrect = false
            )
            assertEquals(false, answer.isCorrect)
        }
        
        @Test
        fun `TC-AN-004: Create correct answer with explanation`() {
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
        fun `TC-AN-005: Multiple answers can have same text (different IDs)`() {
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
        fun `TC-AN-006: Blank ID throws exception`() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                Answer(id = "  ", text = "Valid", isCorrect = true)
            }
        }
        
        @Test
        fun `TC-AN-007: Empty string ID throws exception`() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                Answer(id = "", text = "Valid", isCorrect = true)
            }
        }
        
        @Test
        fun `TC-AN-008: Blank text throws exception`() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                Answer(id = "valid-id", text = "  ", isCorrect = true)
            }
        }
        
        @Test
        fun `TC-AN-009: Empty string text throws exception`() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                Answer(id = "valid-id", text = "", isCorrect = false)
            }
        }
        
        @Test
        fun `TC-AN-010: Tab and newline in ID are treated as blank`() {
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                Answer(id = "\t\n", text = "Valid", isCorrect = true)
            }
        }
    }
    
    @Nested
    @DisplayName("Equality and Copying")
    inner class EqualityAndCopying {
        @Test
        fun `TC-AN-011: Two answers with same data are equal`() {
            val ans1 = Answer("id-1", "Text", true, "Explain")
            val ans2 = Answer("id-1", "Text", true, "Explain")
            assertEquals(ans1, ans2)
        }
        
        @Test
        fun `TC-AN-012: Answers with different IDs are not equal`() {
            val ans1 = Answer("id-1", "Text", true)
            val ans2 = Answer("id-2", "Text", true)
            kotlin.test.assertNotEquals(ans1, ans2)
        }
        
        @Test
        fun `TC-AN-013: Copy answer with modified fields`() {
            val original = Answer("id-1", "Original", true, "Explain")
            val modified = original.copy(text = "Modified")
            assertEquals("id-1", modified.id)
            assertEquals("Modified", modified.text)
            assertEquals(true, modified.isCorrect)
        }
        
        @Test
        fun `TC-AN-014: Copy with null explanation`() {
            val original = Answer("id-1", "Text", true, "Explain")
            val modified = original.copy(explanation = null)
            assertNull(modified.explanation)
        }
        
        @Test
        fun `TC-AN-015: Copied answer validation is enforced`() {
            val original = Answer("id-1", "Text", true)
            kotlin.test.assertFailsWith<IllegalArgumentException> {
                original.copy(id = "")
            }
        }
    }
}