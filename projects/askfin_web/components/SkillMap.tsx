// ❌ Suspense won't work properly without async parent
export function SkillMap(props: SkillMapProps) {
  return (
    <Suspense fallback={<div className="..." />}>
      <SkillMapContent {...props} />
    </Suspense>
  );
}