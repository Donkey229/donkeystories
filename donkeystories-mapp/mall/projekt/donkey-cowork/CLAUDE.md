# Donkey Cowork och Donkey Lab

> Mapp: `C:\Donkeystories\projekt\donkey-cowork` · Panel: http://127.0.0.1:8770 · Genväg: "Donkey Cowork" på skrivbordet

## Vad det är
**Donkey Cowork** är den lokala projektpanelen. Den ska bli **Donkey Hub** tillsammans med God Mode. Panelen har:
- live-koll på projektmappar och Claude-sessioner
- ett råd med fem ingenjörer: Viktor, Dante, Leo, Sami och Holger
- en chatt
- fliken Plan & promptar
- en dagbok

**Donkey Lab** (`foretaget\`) är företaget där AI-delägarna driver projekten via den schemalagda uppgiften `donkey-styrelsemote` i Claude-appen.

## Viktigt
Har projektet egna regler (`CLAUDE.md` eller `.claude\CLAUDE.md`) gäller de först. Donkeys löpande order står i `foretaget\STYRELSEN.md` och går före mötesprompten.
- Servern lyssnar bara på 127.0.0.1 och får aldrig ut på internet.
- Bara ett styrelsepass åt gången (låset är `foretaget\pass-pagar.txt`).
- **Samordning:** alla Claude-sessioner skriver in sig i `foretaget\samordning.md` innan de ändrar filer, och rör inte låsta filer (Donkeys order 2026-10-01).
- Dagboken ligger i `foretaget\dagbok\ÅÅÅÅ-MM-DD.md`. Lägg bara till, skriv aldrig över.
- Styrelsens hjälpagenter finns i `%USERPROFILE%\.claude\agents\` (donkey-viktor, -dante, -leo, -sami, -holger, -claude-hub och filmkontrollant). Mötesprompten finns i `%USERPROFILE%\.claude\scheduled-tasks\donkey-styrelsemote\SKILL.md`. De pekar på de gamla sökvägarna under Dokument, som fortfarande fungerar via länkarna. Uppdatera dem till `C:\Donkeystories\projekt\...` när det passar, efter Donkeys ja.
- Mejl får bara gå till Donkeys egen Gmail, högst 2 per dag och aldrig kl 22–08.
- Ingenting publiceras utan Donkeys ja i Claude-chatten.
- Kvottak för styrelsen: 80 % av veckokvoten.
- `data.json` innehåller projektkorten med mappar. Håll det i takt med `C:\Donkeystories\PROJEKT.md`. De gamla sökvägarna fungerar via länkar, men använd de nya.

## Viktiga filer
- `server.py` och `index.html` – panelen
- `data.json` – projekt, ingenjörer, beslut och plan
- `PLAN.md` – huvudplanen
- `promptar\1–5` – en prompt per steg
- `foretaget\` – STYRELSEN.md, roller.md, musikstrategi.md, sprintplan.md, marknadsplan.md och dagbok\
- `Öppna Cowork.bat` och `Logga in Claude.bat`

## Huvudplanen (PLAN.md)
1. Grading-looks
2. Film och Musikvideo slås ihop
3. Donkey Hub (God Mode och Cowork)
4. Hemsidan design-v2
5. Avveckla Du&Jag (klart)

Inkomstprojekt som styrelsen valt: **Donkey Låtvideo** (Dante) och **Donkey Musikbibliotek** (Leo).
