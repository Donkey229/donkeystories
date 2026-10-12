# Sparly – ekonomi-app

> Mapp: `C:\Donkeystories\projekt\sparly` · Låg tidigare på Skrivbordet (i OneDrive) · GitHub: inget repo än · Live: inte publicerad

## Vad det är
En svensk privatekonomi-app i **en enda fristående HTML-fil** (`sparly.html`, cirka 1600 rader) med all CSS och JS inbyggd.
Den har inga externa bibliotek eller typsnitt och ingen server. All data sparas bara i telefonens `localStorage` (nyckeln `sparly.data.v1`).
Appen är byggd för två användare: Donkey med Samsung (Chrome/Samsung Internet) och Emma med iPhone (Safari).

Funktioner:
- inkomster och utgifter med kategorier och egna färger
- återkommande poster
- budget per kategori: grön, gul vid 80 %, röd vid 100 %
- sparmål och "Kvar att spendera"
- kalender med års-, månads- och dagvy
- SVG-diagram
- sök och filter, svep för att ändra eller ta bort
- export och import som JSON, samt backup-påminnelse

Designen är glassmorphism på krämvit botten (#FAF6EE) med en glasmeny längst ner: Hem, Kalender, +, Budget och Mål.

## Viktiga filer
- `sparly.html` – hela appen (masterfilen)
- `sparly-chatt.md` – logg över allt som sagts och bestämts. **Fortsätt logga här.**
- `testa-sparly.md` – testlista med 15 punkter för Samsung och iPhone
- `LAGG-UT-APPEN.md` – steg för steg för att publicera på GitHub Pages
- `bygg-webbapp.ps1` – kopierar `sparly.html` till `webbapp\index.html` och höjer cache-versionen i `webbapp\sw.js`
- `webbapp\` – den installerbara webbappen (PWA): `index.html`, `sw.js`, `manifest.webmanifest` och tre ikoner

## Så körs det
- **Som fil:** öppna `sparly.html` i en webbläsare. På iPhone krävs Koder eller Textastic, eftersom Filer-appen inte kör JS.
- **Bygg webbappen** efter varje ändring i `sparly.html`: `powershell -ExecutionPolicy Bypass -File .\bygg-webbapp.ps1`
- **Lokal test:** en liten PowerShell-server (HttpListener) på `http://localhost:8765`, i mobilstorlek 375x812.

## Status (2026-10-12)
- `sparly.html` är klar, granskad i två rundor (29 + 7 fynd, alla rättade) och testad i mobilstorlek.
- PWA-delen är byggd, men offline-läget (service worker) är inte verifierat på riktigt.
- En PWA-granskning pågick när sessionen slutade. Resultatet är inte genomgånget.
- Inget är uppladdat till GitHub.

## Beslut och regler
- Appen ska vara **en** fristående HTML-fil. `sparly.html` är master och `webbapp\index.html` en kopia.
- All appdata ska bara ligga lokalt i telefonen. Appen får aldrig skicka data någonstans. Behåll CSP `connect-src 'none'`.
- Allt på svenska: belopp som "1 250 kr", datum som 2026-10-12, svenska månadsnamn.
- Måste fungera både på iPhone och Samsung.
- "Sparly ska vara en app": vägen är en installerbar webbapp (PWA) via GitHub Pages. Inte APK. Som lokal fil ska den fortsätta fungera.
- Sparly ska **inte** ligga i `donkeystories`-repot. Ett eget repo, `Donkey229/sparly`, är planerat.
- Inget laddas upp till GitHub utan Donkeys ja. **Riktiga backupfiler (`sparly-backup-*.json`) får aldrig hamna i ett repo.**
- Datorn har varken Python eller Git. Använd PowerShell.

## Nästa steg
1. Gå igenom resultatet från PWA-granskningen och rätta. Kör sedan `bygg-webbapp.ps1` igen.
2. Verifiera offline-läget på riktigt, via https eller i telefonen.
3. När Donkey säger ja:
   - skapa `Donkey229/sparly` (måste vara publikt för gratis Pages)
   - ladda upp innehållet i `webbapp\`
   - slå på Pages, så att appen nås på `https://donkey229.github.io/sparly/`
4. Donkey (Samsung) och Emma (iPhone) testar enligt `testa-sparly.md`.
5. Idéer som inte är byggda: mörkt läge, PIN-kod, skuldspårning (lån, CSN), fakturakalender och CSV-export.
