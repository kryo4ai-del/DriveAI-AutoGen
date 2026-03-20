package com.driveai.askfin.ui.viewmodels

@HiltViewModel
class ReadinessScoreViewModel @Inject constructor(
    private val readinessRepository: ReadinessRepository
) : ViewModel() {
    // No retry logic, no error recovery