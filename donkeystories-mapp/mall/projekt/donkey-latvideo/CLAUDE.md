# Donkey Låtvideo (videotjänst för musiker)

> Mapp: `C:\Donkeystories\projekt\donkey-latvideo` · Inkomstprojekt 1 i Donkey Lab, ansvariga Dante och Viktor

## Vad det är
Kunden lägger låt och omslag i `inkorg\` och får en zip i `leverans\` med fyra saker, gjorda med Donkey Films kärna:
- Spotify Canvas
- kortvideo med neon-karaoke
- YouTube-visualizer
- miniatyr

Flödet vägrar ordrar som saknar rättighetsintyg.

## Så körs det
- `Gör orderna.bat` gör alla nya ordrar. En enskild order: `donkey-film\_py311\Scripts\python.exe -X utf8 gor_order.py inkorg\<order>`
- `Rensa gamla ordrar.bat` rensar kundfiler.
- **Tester:** `tester\test_gor_order.py`

## Status (2026-10-01)
- Flödet är byggt och testat. En demo-order tog cirka 2 minuter.
- Säljsidan `latvideo.html` finns i hemsidans design-v2. Priset är inte bestämt.

## Regler
- Låt, omslag och text raderas 30 dagar efter leverans. Videor och logg sparas. Donkey bekräftar.
- Beställning sker via en mejl-länk. Inget formulär och ingen uppladdning.

## Nästa steg
1. Bestäm pris (199 eller 399 kr är bara en gissning).
2. Gör tre demo-ordrar.
