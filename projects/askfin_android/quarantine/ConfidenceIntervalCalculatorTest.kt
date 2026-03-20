package com.driveai.askfin.data.models

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.BeforeEach
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import kotlin.test.assertFailsWith

@DisplayName("ConfidenceIntervalCalculator")
class ConfidenceIntervalCalculatorTest {

    private val calculator = ConfidenceIntervalCalculator()

    // ===== Happy Path =====

    @Test
    @DisplayName("Calculates 95% CI for perfect score (100/100)")
    fun testPerfectScore() {
        val ci = calculator.calculate(correctCount = 100, totalCount = 100)
        
        assertEquals(100f, ci.lowerBound, 0.1f)
        assertEquals(100f, ci.upperBound, 0.1f)
        assertEquals(0f, ci.margin, 0.1f)
    }

    @Test
    @DisplayName("Calculates 95% CI for zero correct (0/100)")
    fun testZeroScore() {
        val ci = calculator.calculate(correctCount = 0, totalCount = 100)
        
        assertEquals(0f, ci.lowerBound, 0.1f)
        assertEquals(0f, ci.upperBound, 0.1f)
        assertEquals(0f, ci.margin, 0.1f)
    }

    @Test
    @DisplayName("Calculates CI for 80% score (80/100)")
    fun testTypicalScore() {
        val ci = calculator.calculate(correctCount = 80, totalCount = 100)
        
        // Wilson interval for 80/100: [71.5%, 87.2%] approx
        assertTrue(ci.lowerBound in 70f..75f, "Lower bound should be ~71-74%")
        assertTrue(ci.upperBound in 85f..90f, "Upper bound should be ~85-88%")
        assertTrue(ci.margin in 7f..10f, "Margin should be ~7-9%")
    }

    @Test
    @DisplayName("Small samples have wider confidence intervals")
    fun testSmallSampleWideness() {
        val smallSample = calculator.calculate(4, 5)      // 80%, n=5
        val largeSample = calculator.calculate(80, 100)   // 80%, n=100
        
        assertTrue(smallSample.margin > largeSample.margin,
            "Small sample margin (${smallSample.margin}%) should exceed large sample (${largeSample.margin}%)"
        )
    }

    @Test
    @DisplayName("CI bounds respect [0, 100] range")
    fun testBoundsNormalized() {
        repeat(10) {
            val correct = kotlin.random.Random.nextInt(0, 101)
            val total = kotlin.random.Random.nextInt(1, 101)
            val ci = calculator.calculate(correct, total.coerceAtLeast(1))
            
            assertTrue(ci.lowerBound in 0f..100f, "Lower bound out of range")
            assertTrue(ci.upperBound in 0f..100f, "Upper bound out of range")
            assertTrue(ci.lowerBound <= ci.upperBound, "Inverted bounds")
        }
    }

    @Test
    @DisplayName("Margin increases with lower sample sizes")
    fun testMarginVsSampleSize() {
        val margins = listOf(5, 10, 20, 50, 100).map { n ->
            calculator.calculate(n / 2, n).margin
        }
        
        // Should be monotonically decreasing
        for (i in 0 until margins.size - 1) {
            assertTrue(margins[i] >= margins[i + 1],
                "Margin at index $i (${margins[i]}) should be >= index ${i+1} (${margins[i+1]})"
            )
        }
    }

    @Test
    @DisplayName("Supports custom confidence levels (90%, 99%)")
    fun testCustomConfidenceLevel() {
        val ci95 = calculator.calculate(50, 100, confidenceLevel = 1.96f)  // 95%
        val ci99 = calculator.calculate(50, 100, confidenceLevel = 2.576f) // 99%
        
        assertTrue(ci99.margin > ci95.margin, "99% CI should be wider than 95%")
    }

    // ===== Edge Cases =====

    @Test
    @DisplayName("Handles single answer (n=1, correct)")
    fun testSingleCorrectAnswer() {
        val ci = calculator.calculate(1, 1)
        
        assertEquals(100f, ci.lowerBound, 5f)
        assertEquals(100f, ci.upperBound, 5f)
    }

    @Test
    @DisplayName("Handles single answer (n=1, incorrect)")
    fun testSingleWrongAnswer() {
        val ci = calculator.calculate(0, 1)
        
        assertEquals(0f, ci.lowerBound, 5f)
        assertEquals(0f, ci.upperBound, 5f)
    }

    @Test
    @DisplayName("Handles 50% score (maximum uncertainty)")
    fun testFiftyfiftyScore() {
        val ci = calculator.calculate(50, 100)
        
        // 50/100 should have symmetric, wide interval
        assertTrue(ci.lowerBound in 35f..45f)
        assertTrue(ci.upperBound in 55f..65f)
        assertTrue(ci.margin > 8f, "50% has maximum uncertainty")
    }

    // ===== Validation & Error Cases =====

    @Test
    @DisplayName("Rejects negative correct count")
    fun testNegativeCorrectCount() {
        assertFailsWith<IllegalArgumentException> {
            calculator.calculate(-1, 10)
        }
    }

    @Test
    @DisplayName("Rejects correct > total")
    fun testCorrectExceedsTotal() {
        assertFailsWith<IllegalArgumentException> {
            calculator.calculate(11, 10)
        }
    }

    @Test
    @DisplayName("Rejects zero total count")
    fun testZeroTotal() {
        assertFailsWith<IllegalArgumentException> {
            calculator.calculate(0, 0)
        }
    }

    @Test
    @DisplayName("Rejects invalid confidence level (z < 0)")
    fun testNegativeConfidenceLevel() {
        assertFailsWith<IllegalArgumentException> {
            calculator.calculate(5, 10, confidenceLevel = -1.96f)
        }
    }

    @Test
    @DisplayName("ConfidenceInterval data class validates bounds")
    fun testConfidenceIntervalValidation() {
        // Lower > upper should fail
        assertFailsWith<IllegalArgumentException> {
            ConfidenceInterval(lowerBound = 80f, upperBound = 20f, margin = 30f)
        }
        
        // Out of range should fail
        assertFailsWith<IllegalArgumentException> {
            ConfidenceInterval(lowerBound = -10f, upperBound = 50f, margin = 30f)
        }
    }

    @Test
    @DisplayName("Cumulative results make sense (n=1000, 70% score)")
    fun testLargeScaleAccuracy() {
        val ci = calculator.calculate(700, 1000)
        
        // Large sample should have tight CI
        assertTrue(ci.margin < 3f, "Large sample (n=1000) should have margin < 3%")
        assertTrue(ci.lowerBound in 67f..69f)
        assertTrue(ci.upperBound in 71f..73f)
    }
}

data class ConfidenceInterval(
    val lowerBound: Float,
    val upperBound: Float,
    val margin: Float
) {
    init {
        require(lowerBound >= 0f && lowerBound <= 100f) { "Lower bound must be in [0, 100]" }
        require(upperBound >= 0f && upperBound <= 100f) { "Upper bound must be in [0, 100]" }
        require(lowerBound <= upperBound) { "Lower bound must be <= upper bound" }
    }
}

class ConfidenceIntervalCalculator {
    fun calculate(
        correctCount: Int,
        totalCount: Int,
        confidenceLevel: Float = 1.96f
    ): ConfidenceInterval {
        require(correctCount >= 0) { "Correct count cannot be negative" }
        require(totalCount > 0) { "Total count must be positive" }
        require(correctCount <= totalCount) { "Correct count cannot exceed total count" }
        require(confidenceLevel >= 0f) { "Confidence level cannot be negative" }
        
        val p = correctCount.toFloat() / totalCount.toFloat()
        val z = confidenceLevel
        val n = totalCount.toFloat()
        
        val denominator = 1f + (z * z) / n
        val center = (p + (z * z) / (2f * n)) / denominator
        val margin = (z * kotlin.math.sqrt(p * (1f - p) / n + (z * z) / (4f * n * n))) / denominator
        
        val lowerBound = ((center - margin) * 100f).coerceIn(0f, 100f)
        val upperBound = ((center + margin) * 100f).coerceIn(0f, 100f)
        val marginPercent = (margin * 100f).coerceIn(0f, 100f)
        
        return ConfidenceInterval(lowerBound, upperBound, marginPercent)
    }
}