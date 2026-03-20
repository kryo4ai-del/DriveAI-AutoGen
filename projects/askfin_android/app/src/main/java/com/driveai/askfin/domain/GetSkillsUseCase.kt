package com.driveai.askfin.domain
import dagger.Provides
import javax.inject.Singleton
import javax.inject.Inject

@Provides
@Singleton
fun provideSkillMapRepository(dao: SkillMapDao): SkillMapRepository {
    return SkillMapRepositoryImpl(dao)  // ✅ Correct...
}

// But GetSkillsUseCase needs the interface, not impl
class GetSkillsUseCase @Inject constructor(
    private val repository: SkillMapRepository  // ✅ Interface injection
)