package com.driveai.askfin.data.models

import kotlinx.serialization.Serializable
import androidx.room.TypeConverters
import java.time.Instant

@Serializable
data class ExamResult(val completedAt: String)