/**
 * Existing TrainingMode types for reference/integration
 */
export interface TrainingQuestion {
  id: string;
  category: string;
  text: string;
  options: TrainingOption[];
  correctAnswerId: string;
  explanation: string;
}

export interface TrainingOption {
  id: string;
  text: string;
}
