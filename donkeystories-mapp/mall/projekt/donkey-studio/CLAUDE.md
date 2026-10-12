# Donkey Studio (Cubase AI Panel)

> Mapp: `C:\Donkeystories\projekt\donkey-studio` · Panel: http://127.0.0.1:8767 · GitHub: inget

## Vad det är
En lokal panel som gör musik helt **utanför** Cubase 10.5, i två lägen:
- **REMIX:** en låt blir en tydligt annorlunda remix.
- **CREATE:** stil plus BPM blir en hel låt.

Projektet bygger på tre pelare:
1. **Kunskap** (`knowledge\`, 116 prov i `pass_criteria.md`)
2. **Öron** (`analysis\`, som mäter och kritiserar)
3. **Feedback** (betyg, inte byggd än)

Tio agentroller finns i `.claude\agents\`. Cubase används bara för slutimporten, via mapparna `till_cubase\` och `fran_cubase\`.

## Viktigt
**Donkey Studio har en egen regelbok med hårda regler 1–15** (i projektets egen `CLAUDE.md` eller `.claude\CLAUDE.md`) och en logg i `PROGRESS.md`. De är facit, så läs dem först.
De viktigaste reglerna:
- Styr aldrig Cubase. Ingen mus, inget tangentbord, och starta eller stäng det inte.
- Radera aldrig filer. `E:\Musik` får bara läsas.
- Python körs alltid som `py -3.14`.
- Starta inga servrar i agenter. Panelen kör på 8767, och testservrar använder 8799.
- Gränsvärden ändras bara med korpusbevis (regel 15).

## Så körs det
- **Tester:** `py -3.14 -m pytest tests -q -p no:cacheprovider --deselect tests/test_rekommendera.py::test_cache_ar_byggd_och_idempotent`
- **Kunskap:** `py -3.14 tools\validate_knowledge.py` (ska säga OK)

## Status (2026-09-29)
- Pelare 1 och 2 är byggda och verifierade: 1064 tester gröna och validatorn OK.
- "Val 1" (mål och spärr) är genomfört.
- Smart App Control blockerar ljud till MIDI (basic-pitch). Donkey måste själv besluta om inställningen. Ändra den aldrig.

## Nästa steg
1. Tre beslut väntar på Donkey. Föreslaget svar: "46, behåll, höj".
   - ARR-07:s spärr
   - spärrens bredd
   - ARR-10:s övre gräns
2. Mät fyra nya genrer: Drill, Trapstep, Lo-fi hiphop och Synthwave.
3. Därefter CREATE-läget, REMIX-läget och pelare 3.
4. Verktyg att välja bland, ett i taget och efter Donkeys ja: sfizz, beat_this, CLAP, Surge XT och torchcrepe.
