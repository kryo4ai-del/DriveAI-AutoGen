interface ReadinessScreenProps {
  // ...
  onContinue?: () => void;
}

export function ReadinessScreen({ onContinue, ...props }: ReadinessScreenProps) {
  return (
    <button 
      onClick={onContinue}
      className="..."
    >
      Continue Learning
    </button>
  );
}

// Usage enforces callback
<ReadinessScreen onContinue={() => navigate('/learn')} />