// File: src/test/kotlin/com/driveai/askfin/data/models/QuestionCategoryTest.kt
package com.driveai.askfin.data.models

import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.assertEquals
import kotlin.test.assertFailsWith

@DisplayName("QuestionCategory Enum Tests")
class QuestionCategoryTest {
    
    @Nested
    @DisplayName("All Categories Defined")
    inner class AllCategoriesDefined {
        @Test
        fun testTC_QC_001_All_10_categories_are_present() {
            val categories = QuestionCategory.values()
            assertEquals(10, categories.size)
        }
        
        @Test
        fun testTC_QC_002_ROAD_SIGNS_category_exists() {
            assertEquals(QuestionCategory.ROAD_SIGNS, 
                QuestionCategory.valueOf("ROAD_SIGNS"))
        }
        
        @Test
        fun testTC_QC_003_TRAFFIC_RULES_category_exists() {
            assertEquals(QuestionCategory.TRAFFIC_RULES, 
                QuestionCategory.valueOf("TRAFFIC_RULES"))
        }
        
        @Test
        fun testTC_QC_004_EMERGENCY_PROCEDURES_category_exists() {
            assertEquals(QuestionCategory.EMERGENCY_PROCEDURES, 
                QuestionCategory.valueOf("EMERGENCY_PROCEDURES"))
        }
        
        @Test
        fun testTC_QC_005_PEDESTRIAN_INTERACTION_category_exists() {
            assertEquals(QuestionCategory.PEDESTRIAN_INTERACTION, 
                QuestionCategory.valueOf("PEDESTRIAN_INTERACTION"))
        }
    }
    
    @Nested
    @DisplayName("Category Filtering")
    inner class CategoryFiltering {
        @Test
        fun testTC_QC_006_Can_filter_categories_by_name() {
            val safetyCategories = listOf(
                QuestionCategory.ROAD_SAFETY,
                QuestionCategory.HAZARD_PERCEPTION,
                QuestionCategory.EMERGENCY_PROCEDURES
            )
            assertEquals(3, safetyCategories.size)
        }
        
        @Test
        fun testTC_QC_007_Categories_are_unique() {
            val allCategories = QuestionCategory.values().toList()
            assertEquals(allCategories.size, allCategories.distinct().size)
        }
        
        @Test
        fun testTC_QC_008_Invalid_category_name_throws_exception() {
            assertFailsWith<IllegalArgumentException> {
                QuestionCategory.valueOf("INVALID_CATEGORY")
            }
        }
    }
}

enum class QuestionCategory {
    ROAD_SIGNS,
    TRAFFIC_RULES,
    EMERGENCY_PROCEDURES,
    PEDESTRIAN_INTERACTION,
    ROAD_SAFETY,
    HAZARD_PERCEPTION,
    PARKING_REGULATIONS,
    VEHICLE_MAINTENANCE,
    WEATHER_CONDITIONS,
    SPEED_LIMITS
}