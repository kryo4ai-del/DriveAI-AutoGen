package com.driveai.askfin.domain

@Singleton
class SkillMapService @Inject constructor(
    private val calculator: CompetenceCalculator
)