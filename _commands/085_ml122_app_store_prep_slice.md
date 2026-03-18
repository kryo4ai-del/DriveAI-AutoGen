# 085 Ml122 App Store Prep Slice

**Status**: pending
**Erstellt**: 2026-03-18
**Quelle**: Prompt Pilot (automatisch)

## Auftrag

# mac-driveai-ml122-app-store-prep-slice.md

Goal:
Create the smallest coherent App Store preparation slice for AskFin so the product becomes meaningfully more ship-ready without changing the protected learning core.

Prompt ist für Mac

Task:
Inspect the current AskFin presentation/readiness state and choose the smallest high-value App Store preparation subset that can be implemented safely on the protected baseline.

Current confirmed state:
- template-schema abstraction was intentionally stopped as overengineering
- protected baseline remains green
- AskFin has a strong working learning loop and protected gates
- next higher-value direction identified: App Store preparation or content expansion

Important:
Do not start another generation/autonomy run.
Do not broaden into a full redesign or full marketing package.
Do not introduce premature factory abstractions.
The goal is one bounded, high-leverage ship-readiness step.

Focus especially on:
- which App Store prep slice has the highest immediate leverage
- whether the best bounded target is:
  - app icon readiness
  - launch / branding polish
  - screenshot-ready key screens
  - metadata-ready inventory
- keeping the scope tight and user-visible
- preserving the protected baseline and running golden gates afterward if practical

Required checks:
1. Inspect the current AskFin presentation/readiness state.
2. Identify the safest highest-value App Store prep subset.
3. State clearly which slice was chosen and why.
4. Implement that bounded slice.
5. Run build and golden gates afterward if practical.
6. Record whether:
   - the slice works,
   - the baseline remains green,
   - or a concrete blocker appears.
7. If a blocker appears, isolate the first concrete blocker exactly.
8. End with one single next recommended step.

Expected report:
1. Current presentation/readiness baseline inspected
2. Chosen App Store prep slice and why
3. Implementation summary
4. Build/golden gate outcome
5. Any blockers found
6. Single next recommended step

## Nach Abschluss

1. Ergebnis in `_commands/085_ml122_app_store_prep_slice_result.md`
2. `git add -A && git commit -m "ml122_app_store_prep_slice: execute command 085" && git push`
