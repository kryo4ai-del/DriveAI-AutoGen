package com.driveai.askfin.ui.viewmodels

// In domain/formatters/DateFormatter.kt
interface DateFormatter {
    fun formatMilestoneDate(dateMs: Long): String
}

class DateFormatterImpl : DateFormatter {
    private val formatter = SimpleDateFormat("MMM d, yyyy", Locale.US) // Use US locale for consistency

    override fun formatMilestoneDate(dateMs: Long): String = try {
        formatter.format(Date(dateMs))
    } catch (e: Exception) {
        "Unknown date"
    }
}

// ✅ Inject into ViewModel:
@HiltViewModel
    ...
) : ViewModel() { ... }