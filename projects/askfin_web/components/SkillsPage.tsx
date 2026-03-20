'use client';

import { SkillMap } from '@/components/SkillMap/SkillMap';
import { useRouter } from 'next/navigation';

export default function SkillsPage() {
  const router = useRouter();

  return (
    <main className="max-w-6xl mx-auto px-4 py-8">
      <SkillMap
        userId="user-123"
        onNavigate={(route) => router.push(route)}
      />
    </main>
  );
}