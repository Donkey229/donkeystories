# Donkey Stories – central hemsida

> Mapp: `C:\Donkeystories\projekt\donkeystories` · GitHub: `Donkey229/donkeystories` (**publikt**) · Live: https://donkey229.github.io/donkeystories/ (domänen donkeystories.com finns inte i DNS än)

## Vad det är
Den publika hemsidan "Donkey Stories – resor, musik och allt vi skapar". Den är en statisk sida (HTML/CSS/JS) på tre språk, SV/EN/TH, där valt språk sparas i `localStorage`.

Sektioner:
- hero
- Vlogg, Musik och Emma & Du
- Verktyg / Donkey Lab (Donkey Panel, Cubase AI Panel, Donkey Grading)
- Om oss
- Senaste video
- Samarbeten
- sidfot med sociala länkar (markerade "snart")

Designen är mörkt nattblå (#012235) med orange accent. Typsnitten ligger lokalt (Geist, Geist Mono och Noto Sans Thai), så sidan gör inga anrop till Google.

## Viktiga filer
- `index.html` – hela sidan (data-i18n-nycklar)
- `style.css` – stilen
- `app.js` – språkbyte och översättningar (TEXTS-ordboken)
- `fonts\` – egna typsnitt
- `img\` – bilder utan metadata
- `donkeystories-mapp\` – installationen av C:\Donkeystories (publiceras inte på sidan, se `_config.yml`)

## Så körs det
- Det finns inget byggsteg. Förhandsvisa med `py -3.14 -m http.server 8770` i mappen.
- Ändra texter i alla tre språken i `app.js`.
- **Publicering:** `git push` fungerar inte på huvuddatorn. Ändrade filer laddas upp via GitHub-webben i Chrome, och GitHub Pages publicerar `main` automatiskt.
- Lokala commits görs med GitHubs noreply-adress, aldrig med Gmail-adressen. Det gamla repot gjordes privat eftersom gamla commits innehöll den.

## Status (2026-10-12)
- `main` är publicerad. CNAME är borttagen, så sidan fungerar på github.io-adressen.
- På grenen `claude/vlog-styling-04md2i` finns en ny vloggsektion i reel-stil: stående 9:16-klipp med framstegsstaplar, Följ-knapp och rullande ljudrad.
  Den är inte ihopslagen och har ingen PR. Donkey har sett skärmbilder men inte sagt om något ska ändras.
- **Design-v2** ligger i mappen `design-v2\` och står i `.gitignore`, så den publiceras inte. Den byggdes offline 2026-10-01 och har 7 sidor:
  - Start, Musik, Looks, Musikbibliotek, Låtvideo, Verktyg och Kontakt
  - Integritet i sidfoten

  Sidorna finns på SV/EN/TH och har säljsidor för look- och musikpaket. Testerna är gröna.
  `tester\publiceringskoll.py` hittar 51 fynd, bland annat utkast-märken och interna namn. De måste bort före publicering.

## Beslut och regler
- Repot är **publikt**. Inget privat får läggas här: inga lösenord, ingen privat vlogg och inga bilder på Donkey och Emma tillsammans.
- Inga anrop till Google Fonts eller spårning. Bilderna publiceras utan metadata.
- All text ska finnas på svenska, engelska och thai.
- Visa inga påhittade siffror, till exempel gilla-antal.
- Respektera `prefers-reduced-motion`.
- Inga push, PR:er, grenar eller DNS-ändringar utan Donkeys uttryckliga ja.
- Hub, Panel, God Mode och andra interna verktyg syns aldrig på sidan. Den privata vloggen länkas inte.

## Nästa steg
1. Bestäm om domänen ska användas. Antingen köps donkeystories.com och DNS-posterna för GitHub Pages läggs in (då behövs CNAME igen), eller så används github.io-adressen.
2. Bestäm vad som ska hända med vloggsektionen på `claude/vlog-styling-04md2i`: PR, ändringar eller ta bort grenen.
3. Fyll i riktiga länkar (YouTube @DonkeyMusic, TikTok och Instagram) och "Senaste video".
   `og:image` i `index.html` pekar fortfarande på donkeystories.com, så förhandsbilden blir trasig när någon delar länken. Använd en relativ adress eller github.io-adressen tills domänen fungerar.
4. Design-v2 före publicering:
   - betallänkar
   - riktig mejladress
   - YouTube-id för videorna
   - thai-läsare
   - juridik (licens, säljarens namn, ångerrätt)
   - en ren publiceringskopia utan `tester\`

   Publiceras först när Donkey säger "publicera".
