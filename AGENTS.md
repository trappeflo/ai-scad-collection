# OpenSCAD-KI-Workflow

KI-gestützter OpenSCAD-Workflow für 3D-Druck. Ziel ist Zeitersparnis gegenüber klassischem CAD durch KI-unterstützte Modellierung.

Diese Datei ist die **anbieterneutrale** Projektanweisung (Standard `AGENTS.md`). Sie gilt für jedes KI-Tool. Tool-spezifische Adapter (z. B. `CLAUDE.md`, `.claude/`) verweisen nur hierher und ergänzen Komfortfunktionen.

## Vorgehen

- Vor jedem Modellierungs-Task müssen alle Dateien in `context/*.md` gelesen werden (Drucker, Toleranzen, Materialien, bekannte Fehlerbilder in `failure-modes.md`).
- Rollen: `agents/design-agent.md` (Gespräch + Modellierung) und `agents/qa-agent.md` (nur Prüfung). Die QA läuft in einem **eigenen, frischen Kontext**: als Subagent, wenn das Tool das kann, sonst als neue Session/neuer Chat. Sie bekommt nur den Dateipfad und die Anforderungstabelle.
- Regeln in `rules/`, Workflow-Bausteine in `skills/`. Beide gelten für jede Session.
- **Vor jedem Druck gilt `rules/pre-print-gate.md`:** G1 technisch (`tools/check.py`), G2 Maße, G3 blinde Sichtprüfung, G4 Druckbarkeit (alle durch den `qa-agent`), G5 Freigabe durch den Nutzer. Ohne G5 kein STL-Export zum Drucken.
- Prüfberichte liegen in `qa/<datei>/report.md` (Vorlage `qa/TEMPLATE.md`) und bleiben als Nachweis im Repo. Nur der Bericht wird versioniert; Bilder, Schnitte und Logs in den Unterordnern sind lokale Arbeitsdaten und lassen sich mit den Befehlen im Bericht neu erzeugen. Der Bericht muss deshalb die exakten `check.py`-Befehle und alle Messwerte selbst enthalten, nicht nur Verweise auf die Unterordner.
- Fertige Modelle werden **nicht automatisch** vom Agenten nach `scad/finished/` verschoben. Das Verschieben erfolgt ausschließlich nach manueller Freigabe durch den Nutzer.

## Einstiegs-Prompts

- Neues Objekt: `prompts/neues-objekt.md`
- Druckergebnis aufnehmen: `prompts/druckfeedback.md`

Tools mit eigenen Befehlen binden diese Dateien als Befehl ein (Claude Code: `/neues-objekt`, `/druckfeedback`). Ohne Befehle: den Inhalt der Datei als Prompt verwenden bzw. die Datei im Prompt referenzieren.

## Werkzeuge

- `python tools/check.py <datei> --part <teil>=<volumes> --empty interference --cut <z>`: G1-Prüfung, Ansichten und Schnitte nach `qa/<datei>/check/`.
- `python tools/check.py <datei> --quick`: Schnellprüfung (Syntax, `assert`, Warnungen) in ~1 s. Nach jeder Änderung an einer `.scad`-Datei ausführen, falls das Tool das nicht automatisch per Hook tut. Achtung: OpenSCAD 2021.01 beendet sich auch bei fehlgeschlagenem `assert()` mit Exit-Code 0, deshalb wertet das Skript die Ausgabe aus.
