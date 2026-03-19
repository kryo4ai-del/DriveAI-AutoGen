package com.driveai.askfin.data.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.driveai.askfin.data.models.Milestone

@Entity(tableName = "milestones")
data class MilestoneEntity(
    @PrimaryKey
    val id: String,
    val threshold: Int,
    val title: String,
    val icon: String,
    val unlockedAt: Long? = null,
    val isUnlocked: Boolean = false,
    val syncedAt: Long = System.currentTimeMillis()
)

fun MilestoneEntity.toDomain(): Milestone = Milestone(
    id = id,
    threshold = threshold,
    title = title,
    icon = icon,
    unlockedAt = unlockedAt,
    isUnlocked = isUnlocked
)

fun Milestone.toEntity(): MilestoneEntity = MilestoneEntity(
    id = id,
    threshold = threshold,
    title = title,
    icon = icon,
    unlockedAt = unlockedAt,
    isUnlocked = isUnlocked
)