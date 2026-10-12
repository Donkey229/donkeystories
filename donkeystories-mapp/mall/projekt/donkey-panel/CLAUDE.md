# Donkey Panel (VEGAS-tillägg)

> Mapp: `C:\Donkeystories\projekt\donkey-panel` · Ansvarig i Donkey Lab: Holger

Donkey Panel är ett tillägg för VEGAS Pro 15 (`vegas_extension\DonkeyControlPanel.dll`) med LUT-hanterare och AI-knappar via claude.exe. Projektversioner sparas i `projektversioner\`.

## Regler
- All färglogik flyttas till Donkey Grading. Panelen läser bara LUT-filer från `donkey-looks`.
- Smart App Control kan blockera DLL:en. Rapportera, och ändra aldrig inställningen.
- AI-knapparna kräver att claude.exe är inloggad (`/login`).

## Kända fel
- "Matcha klipp" ignorerar LUT-styrkan.
- Två osparade projekt delar versionsmapp.
- WAV-fel efter "Skickat till Project Media".
