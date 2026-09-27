# Prompt: Neues Objekt

Anbieterneutraler Einstiegs-Prompt (siehe `AGENTS.md`). `<ARGUMENTE>`
durch die Eingabe des Nutzers ersetzen. In Claude Code als Befehl
`/neues-objekt` eingebunden (`.claude/skills/neues-objekt/SKILL.md`).

---

Neues Objekt: <ARGUMENTE>

Du arbeitest ab jetzt als design-agent. Lies zuerst, in dieser Reihenfolge:

1. `agents/design-agent.md` (deine Rolle)
2. `rules/` komplett, besonders `rules/pre-print-gate.md`
3. `context/` komplett (Regel `context-first`, inkl. `failure-modes.md`)
4. `skills/design-conversation.md` und `skills/modeling.md`
5. `scad/templates/` und die Tabelle "Templates" in `README.md`: Gibt es
   eine passende Vorlage, schlage sie vor, statt neu zu modellieren.

Dann der Ablauf, ohne Schritte zu überspringen:

1. **Anforderungen klären** (Skill `design-conversation`). Noch kein Code.
   Frag gezielt nach dem, was fehlt. Am Ende steht die
   Anforderungstabelle (ID, Anforderung, Soll, Quelle
   gemessen/nominal/angenommen, Prüfmethode). **Warte auf die
   Bestätigung des Nutzers.**
2. **Entwurf** `scad/draft/<name>_001.scad` (Skill `modeling`): Tabelle im
   Dateikopf, `assert()` für alles Berechenbare, `part`-Schalter mit
   `print`, Einzelteilen und bei Bedarf `fit_test`, `assembly`,
   `interference`. Prüfe vorher, ob der Name in `scad/` schon vergeben ist.
3. **Selbstprüfung G1** mit `python tools/check.py`. Ein Entwurf, der G1
   nicht besteht, geht nicht in die QA.
4. **QA in frischem Kontext:** Starte den `qa-agent` als Subagent (falls
   das Tool Subagents hat, sonst bitte den Nutzer, eine neue Session mit
   `agents/qa-agent.md` zu öffnen). Gib ihm nur den Dateipfad und die
   Anforderungstabelle mit, nicht deine Überlegungen. Speichere
   den zurückgegebenen Bericht unverändert als `qa/<name>_001/report.md`.
5. **Freigabe G5:** Zeig dem Nutzer die Zusammenfassung, die Befunde und
   die Bildpfade und frag nach der Freigabe. Eine Empfehlung der QA ist
   keine Freigabe. Trag die Antwort des Nutzers wörtlich in den Bericht
   ein.
6. Erst danach Skill `export-stl`, nur für den freigegebenen Umfang (z. B.
   nur `fit_test`).

Befunde aus der QA werden in einer neuen Version (`_002`) behoben, die
wieder durch die Prüfung geht. Nichts wird nach `scad/finished/`
verschoben ohne ausdrückliche Anweisung des Nutzers.
