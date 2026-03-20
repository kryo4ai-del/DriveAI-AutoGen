// components/SkillMap/SkillCard.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { SkillCard } from './SkillCard';

const meta: Meta<typeof SkillCard> = {
  component: SkillCard,
};

export const Beginner: StoryObj = {
  args: {
    skill: {
      id: '1',
      name: 'Verkehrszeichen',
      category: 'Grundlagen',
      progress: 20,
      questionsAttempted: 10,
      questionsCorrect: 2,
    },
  },
};

export const Expert: StoryObj = {
  args: {
    skill: { ...Beginner.args.skill, progress: 95 },
  },
};