@AGENTS.md

## Claude-Code-Adapter

Alles Inhaltliche steht in `AGENTS.md` und den verlinkten Dateien. Hier nur, was Claude Code zusätzlich automatisiert:

- **Subagent** `qa-agent` (`.claude/agents/qa-agent.md`): QA in frischem Kontext, ohne Edit/Write-Werkzeug.
- **Befehle** `/neues-objekt` und `/druckfeedback` (`.claude/skills/`): dünne Hüllen um `prompts/neues-objekt.md` und `prompts/druckfeedback.md`. Nicht verwechseln mit `skills/` im Repo (Workflow-Bausteine der Agents).
- **Hook** (`.claude/settings.json`): Nach jedem Write/Edit einer `.scad`-Datei läuft automatisch `python tools/check.py --hook` (= Schnellprüfung).
