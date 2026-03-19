import kotlinx.serialization.Serializable
import androidx.room.TypeConverters

@Serializable
data class ExamResult(val completedAt: Instant, ...)