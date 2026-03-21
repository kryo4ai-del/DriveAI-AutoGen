package com.driveai.askfin.data.local

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
    id = this.id,
    threshold = this.threshold,
    title = this.title,
    icon = this.icon,
    unlockedAt = this.unlockedAt,
    isUnlocked = this.isUnlocked
)

fun Milestone.toEntity(): MilestoneEntity = MilestoneEntity(
    id = this.id,
    threshold = this.threshold,
    title = this.title,
    icon = this.icon,
    unlockedAt = this.unlockedAt,
    isUnlocked = this.isUnlocked
)