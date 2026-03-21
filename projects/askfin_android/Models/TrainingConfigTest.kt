package com.driveai.askfin.data.models

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.assertThrows
import com.google.common.truth.Truth.assertThat

@DisplayName("TrainingConfig Data Model")
class TrainingConfigTest {

    // =====================
    // ✅ Happy Path Tests
    // =====================

    @Test
    @DisplayName("should create config with default values")
    fun defaultConstructor() {
        val config = TrainingConfig()

        assertThat(config.sessionDuration).isEqualTo(300)
        assertThat(config.questionsPerSession).isEqualTo(10)
        assertThat(config.adaptiveMode).isTrue()
        assertThat(config.difficultyLevel).isEqualTo(DifficultyLevel.MEDIUM)
    }

    @Test
    @DisplayName("should create config with custom values")
    fun customConstructor() {
        val config = TrainingConfig(
            sessionDuration = 600,
            questionsPerSession = 20,
            adaptiveMode = false,
            difficultyLevel = DifficultyLevel.HARD
        )

        assertThat(config.sessionDuration).isEqualTo(600)
        assertThat(config.questionsPerSession).isEqualTo(20)
        assertThat(config.adaptiveMode).isFalse()
        assertThat(config.difficultyLevel).isEqualTo(DifficultyLevel.HARD)
    }

    @Test
    @DisplayName("should copy and preserve unmodified fields")
    fun copyPreservesFields() {
        val original = TrainingConfig(
            sessionDuration = 600,
            questionsPerSession = 15,
            adaptiveMode = false,
            difficultyLevel = DifficultyLevel.HARD
        )

        val updated = original.copy(questionsPerSession = 25)

        assertThat(updated.sessionDuration).isEqualTo(600)
        assertThat(updated.questionsPerSession).isEqualTo(25)
        assertThat(updated.adaptiveMode).isFalse()
        assertThat(updated.difficultyLevel).isEqualTo(DifficultyLevel.HARD)
    }

    @Test
    @DisplayName("should support copying all fields")
    fun copyAllFields() {
        val original = TrainingConfig()
        val copied = original.copy(
            sessionDuration = 500,
            questionsPerSession = 30,
            adaptiveMode = false,
            difficultyLevel = DifficultyLevel.EASY
        )

        assertThat(copied).isEqualTo(
            TrainingConfig(
                sessionDuration = 500,
                questionsPerSession = 30,
                adaptiveMode = false,
                difficultyLevel = DifficultyLevel.EASY
            )
        )
    }

    @Test
    @DisplayName("should support equality comparison")
    fun equality() {
        val config1 = TrainingConfig(sessionDuration = 400)
        val config2 = TrainingConfig(sessionDuration = 400)
        val config3 = TrainingConfig(sessionDuration = 500)

        assertThat(config1).isEqualTo(config2)
        assertThat(config1).isNotEqualTo(config3)
    }

    // =====================
    // ❌ Validation Tests
    // =====================

    @Test
    @DisplayName("should reject zero sessionDuration")
    fun rejectZeroSessionDuration() {
        val exception = assertThrows<IllegalArgumentException> {
            TrainingConfig(sessionDuration = 0)
        }
        assertThat(exception.message).contains("sessionDuration must be 30–3600 seconds")
    }

    @Test
    @DisplayName("should reject negative sessionDuration")
    fun rejectNegativeSessionDuration() {
        val exception = assertThrows<IllegalArgumentException> {
            TrainingConfig(sessionDuration = -100)
        }
        assertThat(exception.message).contains("sessionDuration must be 30–3600 seconds")
    }

    @Test
    @DisplayName("should reject sessionDuration below minimum (29 seconds)")
    fun rejectBelowMinimumSessionDuration() {
        val exception = assertThrows<IllegalArgumentException> {
            TrainingConfig(sessionDuration = 29)
        }
        assertThat(exception.message).contains("sessionDuration must be 30–3600 seconds")
    }

    @Test
    @DisplayName("should accept minimum valid sessionDuration (30 seconds)")
    fun acceptMinimumSessionDuration() {
        val config = TrainingConfig(sessionDuration = 30)
        assertThat(config.sessionDuration).isEqualTo(30)
    }

    @Test
    @DisplayName("should accept maximum valid sessionDuration (3600 seconds)")
    fun acceptMaximumSessionDuration() {
        val config = TrainingConfig(sessionDuration = 3600)
        assertThat(config.sessionDuration).isEqualTo(3600)
    }

    @Test
    @DisplayName("should reject sessionDuration above maximum (3601 seconds)")
    fun rejectAboveMaximumSessionDuration() {
        val exception = assertThrows<IllegalArgumentException> {
            TrainingConfig(sessionDuration = 3601)
        }
        assertThat(exception.message).contains("sessionDuration must be 30–3600 seconds")
    }

    @Test
    @DisplayName("should reject extremely large sessionDuration")
    fun rejectExtremeSessionDuration() {
        val exception = assertThrows<IllegalArgumentException> {
            TrainingConfig(sessionDuration = 999_999)
        }
        assertThat(exception.message).contains("sessionDuration must be 30–3600 seconds")
    }

    @Test
    @DisplayName("should reject zero questionsPerSession")
    fun rejectZeroQuestionsPerSession() {
        val exception = assertThrows<IllegalArgumentException> {
            TrainingConfig(questionsPerSession = 0)
        }
        assertThat(exception.message).contains("questionsPerSession must be 1–100")
    }

    @Test
    @DisplayName("should reject negative questionsPerSession")
    fun rejectNegativeQuestionsPerSession() {
        val exception = assertThrows<IllegalArgumentException> {
            TrainingConfig(questionsPerSession = -5)
        }
        assertThat(exception.message).contains("questionsPerSession must be 1–100")
    }

    @Test
    @DisplayName("should accept minimum valid questionsPerSession (1)")
    fun acceptMinimumQuestionsPerSession() {
        val config = TrainingConfig(questionsPerSession = 1)
        assertThat(config.questionsPerSession).isEqualTo(1)
    }

    @Test
    @DisplayName("should accept maximum valid questionsPerSession (100)")
    fun acceptMaximumQuestionsPerSession() {
        val config = TrainingConfig(questionsPerSession = 100)
        assertThat(config.questionsPerSession).isEqualTo(100)
    }

    @Test
    @DisplayName("should reject questionsPerSession above maximum (101)")
    fun rejectAboveMaximumQuestionsPerSession() {
        val exception = assertThrows<IllegalArgumentException> {
            TrainingConfig(questionsPerSession = 101)
        }
        assertThat(exception.message).contains("questionsPerSession must be 1–100")
    }

    @Test
    @DisplayName("should reject extremely large questionsPerSession")
    fun rejectExtremeQuestionsPerSession() {
        val exception = assertThrows<IllegalArgumentException> {
            TrainingConfig(questionsPerSession = 10_000)
        }
        assertThat(exception.message).contains("questionsPerSession must be 1–100")
    }

    @Test
    @DisplayName("should validate both fields on construction")
    fun validateBothFieldsTogether() {
        val exception = assertThrows<IllegalArgumentException> {
            TrainingConfig(sessionDuration = -1, questionsPerSession = 1000)
        }
        // First violation caught
        assertThat(exception.message).contains("sessionDuration")
    }

    // =====================
    // 🔄 Enum Tests
    // =====================

    @Test
    @DisplayName("should have all difficulty levels defined")
    fun difficultyLevelsExist() {
        assertThat(DifficultyLevel.values()).hasLength(3)
        assertThat(DifficultyLevel.values()).asList()
            .containsExactly(DifficultyLevel.EASY, DifficultyLevel.MEDIUM, DifficultyLevel.HARD)
    }

    @Test
    @DisplayName("displayName should format enum correctly")
    fun displayNameFormatting() {
        assertThat(DifficultyLevel.EASY.displayName()).isEqualTo("Easy")
        assertThat(DifficultyLevel.MEDIUM.displayName()).isEqualTo("Medium")
        assertThat(DifficultyLevel.HARD.displayName()).isEqualTo("Hard")
    }

    @Test
    @DisplayName("should support enum comparison by value")
    fun enumComparison() {
        val level1 = DifficultyLevel.HARD
        val level2 = DifficultyLevel.HARD
        val level3 = DifficultyLevel.EASY

        assertThat(level1).isEqualTo(level2)
        assertThat(level1).isNotEqualTo(level3)
    }

    // =====================
    // 📊 Boundary Tests
    // =====================

    @Test
    @DisplayName("should accept valid configs at boundaries")
    fun boundaryValidConfigs() {
        val configs = listOf(
            TrainingConfig(sessionDuration = 30, questionsPerSession = 1),
            TrainingConfig(sessionDuration = 3600, questionsPerSession = 100),
            TrainingConfig(sessionDuration = 1800, questionsPerSession = 50)
        )

        configs.forEach { config ->
            assertThat(config).isNotNull()
        }
    }

    @Test
    @DisplayName("should handle boolean flag correctly")
    fun adaptiveModeBehavior() {
        val withAdaptive = TrainingConfig(adaptiveMode = true)
        val withoutAdaptive = TrainingConfig(adaptiveMode = false)

        assertThat(withAdaptive.adaptiveMode).isTrue()
        assertThat(withoutAdaptive.adaptiveMode).isFalse()
        assertThat(withAdaptive).isNotEqualTo(withoutAdaptive)
    }

    @Test
    @DisplayName("should preserve toString format")
    fun toStringFormat() {
        val config = TrainingConfig(
            sessionDuration = 300,
            questionsPerSession = 10,
            adaptiveMode = true,
            difficultyLevel = DifficultyLevel.MEDIUM
        )

        val str = config.toString()
        assertThat(str).contains("sessionDuration=300")
        assertThat(str).contains("questionsPerSession=10")
        assertThat(str).contains("adaptiveMode=true")
        assertThat(str).contains("difficultyLevel=MEDIUM")
    }

    // =====================
    // 🎯 State Mutation Tests
    // =====================

    @Test
    @DisplayName("copy should not mutate original config")
    fun copyDoesNotMutateOriginal() {
        val original = TrainingConfig(sessionDuration = 400)
        val _ = original.copy(sessionDuration = 800)

        assertThat(original.sessionDuration).isEqualTo(400)
    }

    @Test
    @DisplayName("multiple copies maintain immutability chain")
    fun immutabilityChain() {
        val config1 = TrainingConfig(sessionDuration = 300)
        val config2 = config1.copy(questionsPerSession = 20)
        val config3 = config2.copy(adaptiveMode = false)
        val config4 = config3.copy(difficultyLevel = DifficultyLevel.HARD)

        assertThat(config1.sessionDuration).isEqualTo(300)
        assertThat(config1.questionsPerSession).isEqualTo(10)
        assertThat(config2.questionsPerSession).isEqualTo(20)
        assertThat(config3.adaptiveMode).isFalse()
        assertThat(config4.difficultyLevel).isEqualTo(DifficultyLevel.HARD)
    }
}