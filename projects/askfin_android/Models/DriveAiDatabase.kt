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