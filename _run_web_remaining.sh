#!/bin/bash
# Run remaining 14 web layers (ExamSim L2-L5, SkillMap L1-L5, ReadinessScore L1-L5)
cd "C:\Users\Admin\.claude\current-projects\DriveAI-AutoGen"
export PYTHONUNBUFFERED=1

count_files() {
    find projects/askfin_web/ -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v quarantine | wc -l
}

run_layer() {
    local label="$1"
    local prompt="$2"
    echo "=== $label ==="
    rm -rf generated_code/ 2>/dev/null
    python -u main.py --project askfin_web --profile dev --approval auto "$prompt" 2>&1 | tail -3
    echo "Files: $(count_files)"
    echo ""
}

# ExamSim L3-L5
run_layer "ExamSim L3: Application" "Generate ONLY custom React hooks for ExamSimulation. Import types and services. Create: useExamSession manage exam state current question timer answer submission. useExamTimer countdown hook with remaining time. useExamResults load result category breakdown gap analysis. Use useState useEffect useCallback. Export from hooks. NO JSX components."

run_layer "ExamSim L4: Presentation" "Generate ONLY React TSX components for ExamSimulation. Import hooks. Create: ExamStartScreen exam info start button. ExamQuestionScreen question with timer answers progress N of 30. ExamResultScreen score pass fail category breakdown gap analysis. CategoryBreakdownChart horizontal bars per category. Use use client and Tailwind CSS. Export from components."

run_layer "ExamSim L5: Polish" "Enhance ExamSimulation React code. Add timer animation pulsing when under 60s. AnimatePresence for answer transitions. Responsive design mobile first. Loading skeleton. Error boundary. Aria labels on all interactive elements."

# SkillMap L1-L5
run_layer "SkillMap L1: Foundation" "Generate ONLY TypeScript types for SkillMap. Use existing types. Create: interface CategoryCompetence with category competenceLevel totalAnswered correctAnswers lastPracticed. Interface SkillMapData with categories overallCompetence strongCategories weakCategories. Enum CompetenceLevel BEGINNER DEVELOPING COMPETENT PROFICIENT EXPERT. Export from types. NO React."

run_layer "SkillMap L2: Domain" "Generate ONLY TypeScript services for SkillMap. Create: SkillMapService calculate competence per category from answer history determine strong weak overall competence. CompetenceCalculator weighted scoring recent answers count more. Export from services. COMPLETE implementations. NO React."

run_layer "SkillMap L3: Application" "Generate ONLY React hooks for SkillMap. Create: useSkillMap load skill map data refresh after training sort filter categories. Export from hooks. NO JSX."

run_layer "SkillMap L4: Presentation" "Generate ONLY React TSX for SkillMap. Create: SkillMapScreen grid of category cards. CategoryCompetenceCard name progress bar level color coded. CompetenceIndicator circular progress. SkillMapHeader overall competence summary. Use Tailwind grid and use client. Export from components."

run_layer "SkillMap L5: Polish" "Enhance SkillMap React code. Add animated progress bars. Color transitions red to yellow to green. Empty state. Responsive grid 1col mobile 2col tablet 3col desktop. Accessibility for competence levels."

# ReadinessScore L1-L5
run_layer "ReadinessScore L1: Foundation" "Generate ONLY TypeScript types for ReadinessScore. Create: interface ReadinessData with overallScore milestones trend lastUpdated. Interface ReadinessMilestone with name threshold achieved achievedAt. Enum ReadinessTrend IMPROVING STABLE DECLINING. Export from types. NO React."

run_layer "ReadinessScore L2: Domain" "Generate ONLY TypeScript services for ReadinessScore. Create: ReadinessCalculationService compute 0 to 100 from training 40 percent exams 35 percent consistency 15 percent coverage 10 percent. MilestoneTracker track unlock milestones. TrendAnalyzer 7 day comparison. COMPLETE implementations. Export from services. NO React."

run_layer "ReadinessScore L3: Application" "Generate ONLY React hooks for ReadinessScore. Create: useReadiness readiness score milestones trend auto refresh. Export from hooks. NO JSX."

run_layer "ReadinessScore L4: Presentation" "Generate ONLY React TSX for ReadinessScore. Create: ReadinessScreen large circular progress 0 to 100 percent milestone list trend indicator motivational message. ReadinessCircle animated SVG circle. MilestoneRow name achieved locked icon date. TrendBadge arrow with color. Use Tailwind and use client. Export from components."

run_layer "ReadinessScore L5: Polish" "Enhance ReadinessScore React code. Add animated score counter count up from 0. Milestone unlock animation scale effect. Trend arrow animation. Responsive layout. Motivational messages per score range. Accessibility."

echo ""
echo "=== ALL 14 LAYERS COMPLETE ==="
echo "Total files: $(count_files)"
