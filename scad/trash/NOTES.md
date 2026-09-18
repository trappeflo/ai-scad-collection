# Verworfene Iterationen

Notizen zu den Dateien in diesem Ordner (Skill `archive`).
Verworfen am 2026-09-18, nachdem die jeweilige Nachfolge-Version
freigegeben und nach `scad/finished/` verschoben wurde.

| Datei | Nachfolger | Warum verworfen |
|---|---|---|
| `kartenbox_uno_001.scad` | `kartenbox_uno_002` | Kartenmaß war nur grob gemessen (90 x 60 mm). Mit `card_clear_xy` hätten die Karten ~2 mm/Seite Spiel gehabt. 002 nutzt das UNO-Standardmaß 87 x 56 mm. |
| `laptop_tablet_staender_001.scad` | `laptop_tablet_staender_002` | Zu kippelig: ohne Fußleiste warf ein Schubs von ~130 g oben am Laptop den Ständer um. 002 bringt die überstehende Fußleiste und `base_d` 110 -> 130 mm. |
| `laptop_tablet_staender_002.scad` | `laptop_tablet_staender_003` | Wirkte klobig und zu lang. 003 rundet die oberen Ecken und kürzt den Körper 130 -> 100 mm, hält die Standfestigkeit aber über den in Y überstehenden Fuß. |
| `pin_magnetsockel_001.scad` | `pin_magnetsockel_002` | Nach dem Druck: Pin passte nicht ganz in den Rand (`pin_fit` 0.3 mm/Seite zu knapp), Clutch stand hinten über. 002 korrigiert beides und entfernt die Griffkerbe. |
