package com.driveai.askfin.domain

@Provides
@Singleton
fun provideSkillMapRepository(dao: SkillMapDao): SkillMapRepository {
    return SkillMapRepositoryImpl(dao)  // ✅ Correct...
}

// But GetSkillsUseCase needs the interface, not impl
class GetSkillsUseCase @Inject constructor(
    private val repository: SkillMapRepository  // ✅ Interface injection
)