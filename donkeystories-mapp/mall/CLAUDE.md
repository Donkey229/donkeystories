# Donkeystories – läs detta först

Det här är Donkey Stories samlingsmapp. **Allt** arbete ligger här: projekt, anteckningar och sessioner.
Filen laddas automatiskt när Claude startas i `C:\Donkeystories` eller i en mapp under den.
Den globala filen `%USERPROFILE%\.claude\CLAUDE.md` pekar hit, så reglerna gäller också när Claude startas någon annanstans.

## Gör så här i varje session

1. **Läs först** `C:\Donkeystories\PROJEKT.md`. Där står alla projekt med mapp, status och nästa steg.
2. Ta reda på vilket projekt uppgiften gäller och läs projektets `CLAUDE.md` (i `projekt\<namn>\` eller `arkiv\<namn>\`). Är du osäker, fråga.
3. Arbeta i projektets mapp. Spara aldrig projektfiler utanför `C:\Donkeystories`.
4. **Innan du avslutar** eller när en större del är klar:
   - uppdatera projektets `CLAUDE.md` (status, beslut, nästa steg),
   - uppdatera projektets rad i `PROJEKT.md`,
   - skriv en sessionslogg i `sessioner\logg\` (mall längst ner).
5. **Nytt projekt:** skapa `projekt\<kort-namn>\` med en `CLAUDE.md` (mall: `verktyg\installation\mall\projekt\_ny\CLAUDE.md`) och lägg till en rad i `PROJEKT.md`.
6. Idéer och allmän info som inte hör till ett projekt sparas i `anteckningar\`.

## Mappen

| Mapp | Innehåll |
|---|---|
| `PROJEKT.md` | Projektlistan. Börja alltid här. |
| `projekt\` | Aktiva projekt, ett per mapp, var och en med egen `CLAUDE.md`. |
| `arkiv\` | Nedlagda och gamla projekt. Raderas aldrig. |
| `sessioner\logg\` | En kort sammanfattning per arbetspass, även de tidigare sessionerna. |
| `sessioner\claude-historik\` | Alla Claude Code-chattar (rådata, en mapp per Windows-konto). Rör inte filerna. |
| `anteckningar\` | Idéer och allmän info. |
| `verktyg\installation\` | Installationsskriptet. Det går att köra igen. |

### Om länkarna på de gamla platserna

När mappen skapades flyttades projekten hit. På de gamla platserna (t.ex. `Dokument\donkey-cowork`) finns nu en **länk** (junction) som pekar hit.
Den gör att skrivbordsgenvägar, schemalagda uppgifter och program som Donkey Cowork fortsätter fungera.

- Ta inte bort länkarna och behandla dem inte som kopior. Det finns bara en version av varje projekt, och den ligger här.
- Använd alltid de nya sökvägarna (`C:\Donkeystories\projekt\...`) i nya filer, skript och genvägar.
- Projekt som låg på en annan disk (t.ex. `E:\Musik`) ligger kvar där. I `projekt\` finns en länk till dem.
- Projekt som låg i OneDrive flyttades ut ur OneDrive. Där de låg finns en vanlig genväg.

## Hur Donkey vill att du jobbar

- Svara på **svenska**, kort och enkelt. Förklara tekniska ord. Inga em-streck.
- Avsluta varje svar med en statusrad: 🟢 Klart / ⏳ Väntar på dig / 🔴 Behöver dig.
- Rapportera efter varje steg: **Gjort, Fel, Nästa**.
- Hittar du ett fel: laga det utan att fråga. Fråga först vid ny funktionalitet, borttagning av något som fungerar, ändring av en hård regel, eller frågor om smak och stil.
- Ge val som numrerade alternativ med din rekommendation först.
- Inget är klart förrän det är testat. Säg aldrig att något fungerar utan att ha kört det.
- **Radera aldrig Donkeys filer.** Flytta till `arkiv\` i stället, och visa en lista först.
- **GitHub och publicering:** ingen push, inga nya grenar, inga PR:er, ingen DNS-ändring och ingen uppladdning (YouTube, webb) utan ett uttryckligt ja i chatten.
- **Privat och publikt blandas aldrig.** Privat är vlogg- och minnesappen, Emma & Du, Du&Jag, Sparly-data och arbetsorder. Publika repon (`donkeystories`, `vlog`) får aldrig innehålla privata uppgifter, lösenord eller nycklar.
- Ändra aldrig Windows-, säkerhets- eller energiinställningar (t.ex. Smart App Control). Rapportera i stället.
- Var sparsam med kvoten. Fråga innan stora agentflöden eller återkommande bevakningar.
- **Flera Claude-sessioner samtidigt:** skriv in dig i `projekt\donkey-cowork\foretaget\samordning.md` innan du ändrar filer, och rör inte filer som en annan session har låst.
- Publicering, nedladdning av stora filer eller modeller, pengar, konton och systeminställningar kräver alltid Donkeys ja.
- Thai-texter läses av en thai-läsare innan något publiceras.
- Numrera frågor så att Donkey kan svara kort ("1 ja 2 nej").
- Färdiga program får en genväg på skrivbordet, inte lösa filer.
- Skriv aldrig lösenord, koder eller nycklar i den här mappen.

## Datorn

- Python: `py -3.14`. Donkey Film har en egen venv (`_py311`).
- Lokala servrar, bara på 127.0.0.1: 8765 Arbetsorder · 8766 Ljudbrädan · 8767 Donkey Studio · 8768 God Mode · 8769 Lyrics · 8770 Donkey Cowork · 8786 Tempelvakten · 8811–8820 Tonjakten · 8188 ComfyUI. Testservrar använder 8779 och 8799.
- Program: Cubase Pro 10.5 (rör aldrig Cubase automatiskt), VEGAS Pro 15, ffmpeg med NVENC, Chrome.
- Musiken ligger i `E:\Musik` (Stilar, Thai, Ljud, Effect sounds) och ska bara läsas. Övriga mappar på E: (foto, video, nedladdningar) är privata. Öppna dem inte utan att Donkey ber om det.
- GitHub-kontot heter **Donkey229**. På datorn där Sparly byggdes finns varken Git eller Python, bara PowerShell.
- Donkey Cowork (http://127.0.0.1:8770) är projektpanelen och har en egen projektlista (`donkey-cowork\data.json`). Håll den och `PROJEKT.md` i takt.

## Moln och mobil

Claude i molnet (claude.ai/code och mobilen) kommer inte åt `C:\`. Där finns bara GitHub-repona.
Behöver arbetet filerna här, be Donkey starta Remote Control på datorn.
Skriv då sammanfattningen så att den kan läggas in i `sessioner\logg\` senare.

## Mall för sessionslogg

Filnamn: `sessioner\logg\ÅÅÅÅ-MM-DD-<projekt>-<ämne>.md`

```markdown
# ÅÅÅÅ-MM-DD – <projekt>: <ämne>
- **Var:** dator / moln / mobil (Remote Control)
- **Gjort:**
- **Beslut:**
- **Kvar / nästa steg:**
- **Filer:**
```

## Första sessionen efter installationen

Fråga Donkey om du får gå igenom de gamla chattarna i `sessioner\claude-historik\`. Komplettera sedan projektens `CLAUDE.md` och `PROJEKT.md` med detaljer som saknas.
Den här mappen är privat och finns bara på datorn, så här får privata detaljer stå. De får aldrig kopieras till ett publikt repo.
