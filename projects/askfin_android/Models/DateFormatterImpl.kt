package com.driveai.askfin.domain.formatters

import dagger.Reusable
import java.text.SimpleDateFormat
import java.util.*
import javax.inject.Inject

/**
 * Abstraction for date formatting.
 * Allows easy mocking in tests and i18n support.
 */
interface DateFormatter {
    /**
     * Format millisecond timestamp to readable milestone date.
     * @param dateMs UTC milliseconds since epoch
     * @return Formatted date string, or "Unknown date" on error
     */
    fun formatMilestoneDate(dateMs: Long): String
}

@Reusable
class DateFormatterImpl @Inject constructor(
    private val locale: Locale = Locale.US  // Explicit locale for consistency
) : DateFormatter {

    // SimpleDateFormat is not thread-safe — create new instance per format call
    // Avoid caching instance as a field.
    override fun formatMilestoneDate(dateMs: Long): String = try {
        val formatter = SimpleDateFormat("MMM d, yyyy", locale)
        formatter.format(Date(dateMs))
    } catch (e: Exception) {
        "Unknown date"  // Graceful fallback
    }
}