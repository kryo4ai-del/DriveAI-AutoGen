package com.driveai.askfin.data.local.converters

import androidx.room.ProvidedTypeConverter
import androidx.room.TypeConverter
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneOffset

/**
 * Room type converters for java.time classes.
 * 
 * Why Instant instead of LocalDateTime?
 * - Instant is timezone-agnostic (UTC), ensuring consistency across timezones.
 * - LocalDateTime is timezone-naive, causing bugs when device timezone changes.
 */
@ProvidedTypeConverter
class DateTimeConverter {
    @TypeConverter
    fun fromInstant(value: Instant?): Long? = value?.toEpochMilli()

    @TypeConverter
    fun toInstant(value: Long?): Instant? = value?.let { Instant.ofEpochMilli(it) }

    @TypeConverter
    fun fromLocalDateTime(value: LocalDateTime?): String? = value?.toString()

    @TypeConverter
    fun toLocalDateTime(value: String?): LocalDateTime? = value?.let { LocalDateTime.parse(it) }
}