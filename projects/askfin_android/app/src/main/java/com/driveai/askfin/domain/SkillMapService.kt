package com.driveai.askfin.domain
import javax.inject.Singleton
import javax.inject.Inject

@Singleton
class SkillMapService @Inject constructor(
    private val calculator: CompetenceCalculator
)