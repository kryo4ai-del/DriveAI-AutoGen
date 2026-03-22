export enum BreathingTechniqueType {
  BOX_BREATHING = 'box',
  FOUR_SEVEN_EIGHT = '478',
  DEEP_CALM = 'deep',
  ENERGIZE = 'energize',
}

export interface BreathingCycle {
  inhale: number; // milliseconds
  hold: number;
  exhale: number;
  holdAfterExhale?: number;
}

export interface BreathingTechnique {
  id: BreathingTechniqueType;
  name: string;
  description: string;
  cycle: BreathingCycle;
  duration: number; // recommended session duration in seconds
  icon: string;
  emotional?: string; // e.g., "Calming", "Energizing"
}

export const BREATHING_TECHNIQUES: Record<BreathingTechniqueType, BreathingTechnique> = {
  [BreathingTechniqueType.BOX_BREATHING]: {
    id: BreathingTechniqueType.BOX_BREATHING,
    name: 'Box Breathing',
    description: 'Equal counts for balance and focus',
    cycle: {
      inhale: 4000,
      hold: 4000,
      exhale: 4000,
      holdAfterExhale: 4000,
    },
    duration: 300, // 5 minutes
    icon: '📦',
    emotional: 'Calming',
  },
  [BreathingTechniqueType.FOUR_SEVEN_EIGHT]: {
    id: BreathingTechniqueType.FOUR_SEVEN_EIGHT,
    name: '4-7-8 Breathing',
    description: 'Deep, soothing rhythm for relaxation',
    cycle: {
      inhale: 4000,
      hold: 7000,
      exhale: 8000,
    },
    duration: 300,
    icon: '🌙',
    emotional: 'Deeply Calming',
  },
  [BreathingTechniqueType.DEEP_CALM]: {
    id: BreathingTechniqueType.DEEP_CALM,
    name: 'Deep Calm',
    description: 'Slow breathing for stress relief',
    cycle: {
      inhale: 5000,
      hold: 2000,
      exhale: 6000,
    },
    duration: 300,
    icon: '🧘',
    emotional: 'Grounding',
  },
  [BreathingTechniqueType.ENERGIZE]: {
    id: BreathingTechniqueType.ENERGIZE,
    name: 'Energize',
    description: 'Quick rhythm to boost alertness',
    cycle: {
      inhale: 2000,
      hold: 1000,
      exhale: 2000,
    },
    duration: 180,
    icon: '⚡',
    emotional: 'Invigorating',
  },
};

export type BreathingPhase = 'inhale' | 'hold' | 'exhale' | 'idle';