// data/local/AppDatabase.kt
package com.driveai.askfin.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import com.driveai.askfin.data.models.ReadinessScoreHistoryEntity
import com.driveai.askfin.di.LocalDateTimeConverters

@Database(
    entities = [
        ReadinessScoreHistoryEntity::class,
        // ... other entities
    ],
    version = 1
)
@TypeConverters(LocalDateTimeConverters::class)
abstract class AppDatabase : RoomDatabase() {
    // DAO getters...
}