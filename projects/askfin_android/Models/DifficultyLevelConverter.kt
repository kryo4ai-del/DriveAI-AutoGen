// com.driveai.askfin.data.local.converters.DifficultyLevelConverter.kt
import androidx.room.TypeConverter
import com.driveai.askfin.data.models.DifficultyLevel

class DifficultyLevelConverter {
    @TypeConverter
    fun fromDifficultyLevel(value: DifficultyLevel?): String? = value?.name
    
    @TypeConverter
    fun toDifficultyLevel(value: String?): DifficultyLevel? = 
        value?.let { DifficultyLevel.valueOf(it) }
}