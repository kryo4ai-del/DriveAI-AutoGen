package com.driveai.askfin.data.models

import androidx.room.Database
import androidx.room.RoomDatabase
import com.driveai.skillmap.data.models.SkillEntity

@Database(
    entities = [SkillEntity::class],
    version = 1,
    exportSchema = true
)
abstract class SkillMapDatabase : RoomDatabase() {
    abstract fun skillMapDao(): SkillMapDao
}