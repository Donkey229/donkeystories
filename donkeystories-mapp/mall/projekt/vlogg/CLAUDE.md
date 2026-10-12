# Vlogg och minnesapp (privat)

> Mapp: `C:\Donkeystories\projekt\vlogg` (källan) · Publicerad kopia: GitHub `Donkey229/vlog` (bara `site\`) · Live: https://donkey229.github.io/vlog/

## Vad det är
Den **privata** minnesvloggen för Donkey och Emma ("Våra minnen – resor, vardag och musik"). Den är en webbapp (PWA) med:
- kalender med dagar och resor
- minnessidor med bild, film, ljud och inbäddningar
- tidslinjen "vägen", platser, träffar med nedräkning och närvaro
- reaktioner, kommentarer och push-notiser
- dagar tillsammans och en iPhone-widget (via appen Scriptable)
- Frågor & spel

Appen är på tre språk (SV/EN/TH). Allt är privat som standard, och varje minne kan göras offentligt. Bara Donkey ser Admin.
Backend är Supabase: databas med RLS, inloggning bara via inbjudan, privat lagring och Edge Functions (`admin-users`, `notis`, `widget`, `paminn`).
Appen ersätter den nedlagda Du&Jag.

## Mappar
- `site\` – appen. **Bara den här mappen** laddas upp till `Donkey229/vlog`.
- `sql\` – databasen. Filerna körs i nummerordning i Supabase SQL Editor. `04_tester.sql` är RLS-testerna.
- `functions\` – Edge Functions.
- `tests\`, `tools\` – tester och verktyg (`kor_tester.sh`, `webbkopia.py`, `ikoner.py`, `pg_lokal.py`).
- `templates\` – inbjudningsmejl.
- `docs\`, `.superpowers\` – specar, planer och logg. **Bara lokalt**, de ligger aldrig i git eller på GitHub.
- Git: lokala repot har ingen remote. Arbetsgrenen heter `bygge`. Worktrees finns i `Dokument\vlogg-wt\a…g`.

## Så körs det
- **Tester:**
  - `bash tools/kor_tester.sh` – webbläsarsviten i headless Edge
  - `py -3.14 -m pytest tests -q`
- **Förhandsvisning:** `py -3.14 -m http.server 8771` i mappen. Öppna sedan `/site/index.html`.
- **Publicering:** `git push` fungerar inte på datorn. Ändrade filer ur `site\` laddas upp via github.com/Donkey229/vlog i Chrome, i ordningen nya moduler → `js\pages` → css → HTML sist.
- **Databas:** Claude får inte köra produktions-SQL. Samla SQL:en i en fil och lägg den i urklipp, så klickar Donkey Run själv.

## Regler
- **Privat.** Blandas aldrig med publikt eller kommersiellt material. Den privata vloggen länkas aldrig från hemsidan.
- Inga hemligheter i koden, bara Supabases publika nyckel. **`Dokument\vlogg-hemligt`** innehåller en hemlig nyckel. Den flyttas inte, läses inte i onödan och laddas aldrig upp.
- Ingen bild får försvinna om inte ägaren tar bort den. Samma datum betyder samma händelse.
- Filmer: originalen stannar lokalt. Vloggen får webbkopior på högst 48 MB, och all EXIF/GPS rensas.
- Inget skickas till Emma utan Donkeys uttryckliga ok.
- Arbeta testdrivet (rött, sedan grönt) och låt granskningsagenterna (`vlogg-*` i `%USERPROFILE%\.claude\agents`) granska före publicering.

## Status (2026-10-02)
- Live. Omdesignen publicerades 2026-10-02. RLS-testerna är gröna, och påminnelser körs via cron var 5:e minut.
- Lagringen låg på cirka 650 av 1024 MB (gratisplanen). Donkey: "Vi avvaktar".

## Kvar
- Emma granskar de thailändska texterna.
- Ett gammalt frågepaket ligger fortfarande publicerat i `site/js/spel/fragor_a.js`. Det ska bort efter Donkeys ja.
- Fyra filmer från 24 aug (i `projekt\vlogg-import\resan`) är inte uppladdade.
- Två tvådagarsminnen ska ändras från "Dag" till "Utflykt" (Donkey bekräftar).
- Ett foto i juni-minnet är taget i september. Donkey avgör.
- Kontrollera att GitHub-workflowet `keepalive.yml` körs, annars pausas Supabase.
- Flytt till vlog.donkeystories.com när domänen fungerar. Det kräver ny inloggning och nya notiser.
