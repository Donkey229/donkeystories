# Vlogg och minnesapp

> Mapp: `C:\Donkeystories\projekt\vlog` · GitHub: `Donkey229/vlog` (publikt repo, men innehållet ligger bakom inloggning) · Live: https://donkey229.github.io/vlog/

## Vad det är
Det här är den **privata** vlogg- och minnesappen för Donkey och Emma ("Våra minnen – resor, vardag och musik"). Den är en webbapp (PWA) på GitHub Pages med Supabase som backend för inloggning, data och media.

Sidor: `index`, `admin`, `auth`, `minne`, `om`, `traffar`, `spel` och `404`.
Funktionerna finns i `js\`: kalender och tidslinje, dagens frågor, inför träffen, platser, närvaro, notiser och spel.
Den ersätter den nedlagda appen Du&Jag.

## Viktiga filer
- `*.html` – sidorna
- `js\` – logiken, en fil per funktion
- `js\pages\` – sidspecifik kod
- `js\vendor\` – supabase.js, mediabunny.js, jszip, exifr-lite
- `css\vlogg.css`, `css\spel.css`
- `sw.js`, `manifest.webmanifest` – PWA
- `.nojekyll`
- `.github\workflows\keepalive.yml` – pingar Supabase dagligen så att gratisprojektet inte pausas. Den får bara innehålla publika (publishable) värden.

## Så körs det
Det finns inget byggsteg. GitHub Pages publicerar `main`. Lokalt kan mappen serveras, men inloggningen kräver Supabase.

## Beslut och regler
- **Privat.** Sidan har `noindex` och ska aldrig länkas från den publika hemsidan.
- Inga hemliga nycklar i repot, bara Supabases publika nyckel. Repot är publikt.
- Ingen egen domän (CNAME) tills vidare.
- Inga ändringar på GitHub utan Donkeys uttryckliga ja.
- Arbetsfiler som film och import ligger i `projekt\vlogg` och `projekt\vlogg-import`, inte i repot.

## Status och nästa steg
Appen är live och har nyligen gjorts om: Hem/Vi två, kalender, minne, spel, träffar och admin.
Fyll på här när du arbetar med projektet.
