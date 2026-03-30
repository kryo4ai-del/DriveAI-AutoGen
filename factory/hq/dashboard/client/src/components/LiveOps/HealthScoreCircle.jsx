/**
 * HealthScoreCircle — Wiederverwendbare SVG-Component fuer den farbcodierten Health Score.
 *
 * Props:
 *   score    (number)   — 0-100
 *   size     ("sm"|"md"|"lg")
 *   animated (boolean)  — Pulsier-Animation fuer rote Scores
 */

const SIZE_MAP = {
  sm: { width: 48, fontSize: 14, strokeWidth: 4 },
  md: { width: 80, fontSize: 22, strokeWidth: 5 },
  lg: { width: 120, fontSize: 34, strokeWidth: 6 },
};

function getColor(score) {
  if (score >= 80) return '#22c55e'; // green
  if (score >= 50) return '#eab308'; // yellow
  return '#ef4444'; // red
}

function getZone(score) {
  if (score >= 80) return 'green';
  if (score >= 50) return 'yellow';
  return 'red';
}

export default function HealthScoreCircle({ score = 0, size = 'md', animated = true }) {
  const cfg = SIZE_MAP[size] || SIZE_MAP.md;
  const radius = (cfg.width - cfg.strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const progress = Math.min(Math.max(score, 0), 100);
  const offset = circumference - (progress / 100) * circumference;
  const color = getColor(score);
  const zone = getZone(score);

  const shouldPulse = animated && zone === 'red';

  return (
    <div
      className={`relative inline-flex items-center justify-center ${shouldPulse ? 'animate-pulse' : ''}`}
      style={{ width: cfg.width, height: cfg.width }}
    >
      <svg width={cfg.width} height={cfg.width} className="-rotate-90">
        {/* Background circle */}
        <circle
          cx={cfg.width / 2}
          cy={cfg.width / 2}
          r={radius}
          fill="none"
          stroke="rgba(255,255,255,0.1)"
          strokeWidth={cfg.strokeWidth}
        />
        {/* Progress circle */}
        <circle
          cx={cfg.width / 2}
          cy={cfg.width / 2}
          r={radius}
          fill="none"
          stroke={color}
          strokeWidth={cfg.strokeWidth}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          style={{ transition: 'stroke-dashoffset 0.6s ease' }}
        />
      </svg>
      <span
        className="absolute font-bold text-white"
        style={{ fontSize: cfg.fontSize }}
      >
        {Math.round(score)}
      </span>
    </div>
  );
}

export { getColor, getZone };
