export interface AccessibleError {
  message: string;
  /** User-friendly description of what went wrong */
  userMessage: string;
  /** Actionable recovery suggestion */
  suggestion: string;
  /** ARIA alert role: 'alert' | 'status' */
  ariaRole: 'alert' | 'status';
}

export function useSkillMap(userId: string) {
  const [skillMap, setSkillMap] = useState<SkillMapData | null>(null);
  const [accessibleError, setAccessibleError] = useState<AccessibleError | null>(null);

  useEffect(() => {
    async function load() {
      try {
        const categories = await fetchUserSkillMap(userId);
        const { skillMap: map, errors: validationErrors } = buildSkillMap(categories);
        
        if (validationErrors.length > 0) {
          setAccessibleError({
            message: `Validation error in ${validationErrors.length} categories`,
            userMessage: 'Some skill data could not be loaded.',
            suggestion: 'Please refresh the page or contact support.',
            ariaRole: 'alert',
          });
        }
        setSkillMap(map);
      } catch (err) {
        setAccessibleError({
          message: err instanceof Error ? err.message : 'Unknown error',
          userMessage: 'Failed to load your skill data.',
          suggestion: 'Check your internet connection and try again.',
          ariaRole: 'alert',
        });
      }
    }
    load();
  }, [userId]);

  return { skillMap, accessibleError, loading };
}