# Prompt: Druckfeedback

Anbieterneutraler Einstiegs-Prompt (siehe `AGENTS.md`). `<ARGUMENTE>`
durch die Eingabe des Nutzers ersetzen. In Claude Code als Befehl
`/druckfeedback` eingebunden (`.claude/skills/druckfeedback/SKILL.md`).

---

Druckfeedback: <ARGUMENTE>

Lies `skills/print-feedback.md` und folge ihm. Im Einzelnen:

1. **Datei und Bericht finden.** Welche Version wurde gedruckt? Lies
   `qa/<stem>/report.md`. Gibt es keinen Bericht, sag das offen und
   halte das Ergebnis trotzdem fest (Abschnitt "Print result" nach
   `qa/TEMPLATE.md`).
2. **Freigabe prüfen.** Steht die Freigabe (G5) für genau diesen Umfang im
   Bericht? Wenn nicht: im Bericht nachtragen, dass ohne dokumentierte
   Freigabe gedruckt wurde, und was gedruckt wurde.
3. **Nachfragen, was fehlt.** Geh die Anforderungstabelle und die Befunde
   des Berichts durch. Frag gezielt nach jeder Zeile, zu der der Nutzer
   noch nichts gesagt hat (Passungen, Funktion, Maße). Frag nach
   gemessenen Werten, wo es um Passungen geht. Rate keine Ergebnisse.
4. **Mit der Vorhersage abgleichen.** Pro Zeile: stimmt das Ergebnis mit
   der Vorhersage überein? Ordne jeden Befund ein: echt / berechtigter
   Vorbehalt / Fehlalarm / übersehener Fehler (escaped defect, mit der
   Stufe G1–G4, die ihn hätte finden müssen).
5. **Context aktualisieren:**
   - Passungsergebnisse → `context/tolerances.md` (Material, Geometrie,
     Spiel pro Seite, Ergebnis, gemessen oder nur Einschätzung)
   - Übersehene Fehler → neuer Eintrag in `context/failure-modes.md`
   - Fehlalarme → Prüfregel in `skills/` bzw. `context/failure-modes.md`
     entschärfen, mit dem Beispiel als Kalibrierung
   - Neues Material → `context/materials.md`
6. **Zusammenfassung für den Nutzer:** Wie gut lag die Prüfung (Tabelle:
   Befund → Ergebnis), was wurde geändert, was ist noch offen, Vorschlag
   für die nächste Version.

Keine Änderung an `.scad`-Dateien. Eine Korrektur wird eine neue Version
(`_00X+1`) durch den design-agent (`agents/design-agent.md`) und geht
wieder durch `rules/pre-print-gate.md`.
