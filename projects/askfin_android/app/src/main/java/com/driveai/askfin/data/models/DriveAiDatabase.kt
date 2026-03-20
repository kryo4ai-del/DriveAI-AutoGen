package com.driveai.askfin.data.models
import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

@Database(
    entities = [
        UserAnswerEntity::class,
        SkillMapSnapshotEntity::class  // New entity
    ],
    version = 1,
    exportSchema = true
)
@TypeConverters(DateTimeConverter::class)
abstract class DriveAiDatabase : RoomDatabase() {
    // ...
}

// Minimal placeholders for unresolved references
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity
data class UserAnswerEntity(
    @PrimaryKey val id: Int = 0
)

@Entity
data class SkillMapSnapshotEntity(
    @PrimaryKey val id: Int = 0
)

class DateTimeConverter