# 123-0 Factory Transition Report

**Datum**: 2026-03-18
**Agent**: Claude Code (Mac, Xcode 26.3)

## Learning App als Factory Template

11 Capabilities, davon 9 sofort wiederverwendbar (App Shell, Training Engine, Competence Service, Exam Engine, History, Gates, Build). 2 domain-spezifisch (Questions, Topics).

Factory Template = Shell + Engine + Services + Views + Tests + Build. Customization: TopicArea enum + questions.json + Branding.

Höchster Factory-Hebel: TopicArea/Question Schema als generisches Protocol.
