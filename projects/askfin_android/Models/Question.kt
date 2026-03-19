data class Question(
       val id: String,
       val text: String,
       val category: QuestionCategory,
       val answers: List<Answer>,
       val explanation: String? = null,
       val sourceAttribution: String,  // ← "TÜV Official" or "Community (unofficial)"
       val lastVerifiedDate: Instant,  // ← When was accuracy last confirmed?
       val regulatoryRegion: String    // ← "Germany", "Austria", or "Switzerland"
   )