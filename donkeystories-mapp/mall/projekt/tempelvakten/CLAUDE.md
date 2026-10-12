# Tempelvakten (lura AI-vakten)

> Mapp: `C:\Donkeystories\projekt\tempelvakten` · Start: `Starta Tempelvakten.bat` (http://127.0.0.1:8786)

I spelet chattar eller pratar spelaren med en jättestaty som vaktar ett hemligt ord. Talet tolkas med Films lokala Whisper.
Det finns 5 nivåer och 5 vakter. Spelet har en regelbaserad hjärna, en domare (`motor.py`) och ett läckfilter.

## Status
Spelet är byggt och testerna är gröna. Holger godkände det med anmärkning.

## Regler
- Servern lyssnar bara på 127.0.0.1:8786. Inga nätanrop.
- Donkey sa **nej** (2026-10-01) till att ladda ner en lokal språkmodell. Den regelbaserade hjärnan används.
- Ingen skrivbordsgenväg förrän Holger godkänt.

## Nästa steg
- Rätta Holgers fynd T1: man vinner direkt om man skriver alla fyra nivå-5-orden ihop. Det måste rättas innan någon annan än Donkey spelar.
