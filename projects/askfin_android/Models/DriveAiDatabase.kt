@Database(
    entities = [SessionEntity::class],
    version = 1,
    exportSchema = true
)
@TypeConverters(DifficultyLevelConverter::class)
abstract class DriveAIDatabase : RoomDatabase() {
    abstract fun sessionDao(): SessionDao
}