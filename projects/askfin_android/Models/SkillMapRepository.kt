interface SkillMapRepository {
    // ... existing ...
    
    /**
     * Batch updates skill maps for multiple users (optional pagination).
     * Used for nightly recalculations, analytics refresh.
     */
    suspend fun updateSkillMapsForUsers(userIds: List<String>): Map<String, SkillMapData?>
}