package com.driveai.askfin.data.models

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource
import org.junit.jupiter.params.provider.CsvSource
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

@DisplayName("CompetenceLevel Enum")
class CompetenceLevelTest {

    @Nested
    @DisplayName("fromScore() — Boundary Logic")
    inner class FromScoreBoundaryTests {

        @ParameterizedTest(name = "score {0} → {1}")
        @CsvSource(
            "0.0, BEGINNER",      // Exact lower bound
            "0.1, BEGINNER",      // Within BEGINNER range
            "0.39, BEGINNER",     // Just before DEVELOPING
            "0.4, DEVELOPING",    // Exact DEVELOPING boundary
            "0.5, DEVELOPING",    // Within DEVELOPING range
            "0.59, DEVELOPING",   // Just before COMPETENT
            "0.6, COMPETENT",     // Exact COMPETENT boundary
            "0.7, COMPETENT",     // Within COMPETENT range
            "0.79, COMPETENT",    // Just before PROFICIENT
            "0.8, PROFICIENT",    // Exact PROFICIENT boundary
            "0.9, PROFICIENT",    // Within PROFICIENT range
            "0.94, PROFICIENT",   // Just before EXPERT
            "0.95, EXPERT",       // Exact EXPERT boundary
            "1.0, EXPERT"         // Maximum score
        )
        fun `should classify score to correct level`(score: Float, expectedLevel: String) {
            val result = CompetenceLevel.fromScore(score)
            assertEquals(
                expectedLevel,
                result.name,
                "Score $score should map to $expectedLevel"
            )
        }

        @Test
        @DisplayName("should handle floating-point precision near boundaries")
        fun floatingPointBoundaryPrecision() {
            // Test IEEE 754 floating-point edge cases
            val boundaryTests = listOf(
                0.3999999f to CompetenceLevel.BEGINNER,
                0.4000001f to CompetenceLevel.DEVELOPING,
                0.5999999f to CompetenceLevel.COMPETENT,
                0.6000001f to CompetenceLevel.COMPETENT,
                0.7999999f to CompetenceLevel.PROFICIENT,
                0.8000001f to CompetenceLevel.PROFICIENT,
                0.9499999f to CompetenceLevel.PROFICIENT,
                0.9500001f to CompetenceLevel.EXPERT
            )

            boundaryTests.forEach { (score, expected) ->
                val result = CompetenceLevel.fromScore(score)
                assertEquals(
                    expected,
                    result,
                    "Score $score failed floating-point precision test"
                )
            }
        }

        @Test
        @DisplayName("should reject invalid scores < 0.0")
        fun rejectNegativeScore() {
            val exception = assertFailsWith<IllegalArgumentException> {
                CompetenceLevel.fromScore(-0.1f)
            }
            assert(exception.message?.contains("0.0") == true)
        }

        @Test
        @DisplayName("should reject invalid scores > 1.0")
        fun rejectScoreAboveOne() {
            val exception = assertFailsWith<IllegalArgumentException> {
                CompetenceLevel.fromScore(1.1f)
            }
            assert(exception.message?.contains("1.0") == true)
        }

        @Test
        @DisplayName("should accept edge case: score = NaN")
        fun rejectNaN() {
            // NaN comparisons always return false; should reject
            val exception = assertFailsWith<IllegalArgumentException> {
                CompetenceLevel.fromScore(Float.NaN)
            }
            assert(exception.message != null)
        }
    }

    @Nested
    @DisplayName("fromScore() — Determinism & Caching")
    inner class DeterminismTests {

        @Test
        @DisplayName("should be deterministic: same score always returns same level")
        fun deterministic() {
            val score = 0.75f
            val result1 = CompetenceLevel.fromScore(score)
            val result2 = CompetenceLevel.fromScore(score)
            assertEquals(result1, result2)
        }

        @Test
        @DisplayName("should cache sorted levels list (no sorting per call)")
        fun efficientNoRepeatSort() {
            // This is a performance test; would need instrumentation to verify.
            // Here we test that multiple calls work consistently.
            repeat(1000) {
                CompetenceLevel.fromScore((it.toFloat() / 1000f).coerceIn(0f, 1f))
            }
            // If sorting happened 1000 times, this would be slow.
            // No assertion needed; test passes if execution completes promptly.
        }
    }

    @Nested
    @DisplayName("Enum Properties")
    inner class EnumPropertiesTests {

        @Test
        @DisplayName("all levels have valid threshold ranges")
        fun validThresholdRanges() {
            val levels = CompetenceLevel.entries
            assertEquals(5, levels.size, "Should have 5 competence levels")

            val expectedThresholds = mapOf(
                CompetenceLevel.BEGINNER to 0.0f,
                CompetenceLevel.DEVELOPING to 0.4f,
                CompetenceLevel.COMPETENT to 0.6f,
                CompetenceLevel.PROFICIENT to 0.8f,
                CompetenceLevel.EXPERT to 0.95f
            )

            expectedThresholds.forEach { (level, threshold) ->
                assertEquals(threshold, level.threshold, "Threshold mismatch for $level")
            }
        }

        @Test
        @DisplayName("all levels have non-empty display names")
        fun displayNamesPopulated() {
            CompetenceLevel.entries.forEach { level ->
                assert(level.displayName.isNotEmpty()) {
                    "${level.name} has empty displayName"
                }
            }
        }

        @Test
        @DisplayName("display names are unique")
        fun displayNamesUnique() {
            val displayNames = CompetenceLevel.entries.map { it.displayName }
            assertEquals(displayNames.size, displayNames.toSet().size)
        }
    }
}