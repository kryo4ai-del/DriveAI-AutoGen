package com.driveai.breathflow.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "sessions")
data class SessionEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val technique: String,
    val durationSeconds: Int,
    val cyclesCompleted: Int,
    val timestamp: Long,
    val notes: String = ""
)