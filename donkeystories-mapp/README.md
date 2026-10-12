# C:\Donkeystories – samla allt på ett ställe

Den här mappen innehåller ett installationsskript för Windows. Det samlar alla Donkey Stories-projekt, sessioner och Claude-instruktioner i **`C:\Donkeystories`**.
Från och med då läser Claude alltid den mappen innan arbetet börjar.

> Claude i molnet kommer inte åt din dator, så **du kör skriptet själv, en gång, på datorn**. Det frågar innan det flyttar något.
> Det tar aldrig bort dina filer.

## Det här gör skriptet

1. Skapar `C:\Donkeystories` med mapparna `projekt`, `arkiv`, `sessioner`, `anteckningar` och `verktyg`.
2. Hittar dina projekt:
   - kända projektmappar i Dokument och på Skrivbordet
   - mappar där Claude har jobbat
   - dina GitHub-repon
3. Flyttar varje projekt till `C:\Donkeystories\projekt\` efter ditt ja:
   - **Samma disk:** på den gamla platsen blir det en **länk** till den nya. Genvägar på skrivbordet, schemalagda uppgifter och Donkey Cowork fungerar som förut.
   - **OneDrive (t.ex. Sparly på Skrivbordet):** mappen flyttas ut ur OneDrive, och en genväg läggs där den låg.
   - **Annan disk (`E:\Musik`):** ingenting flyttas, så att C: inte blir full. Mappen får en länk i `C:\Donkeystories\projekt\musik`.
4. Hämtar GitHub-repon som saknas, om Git finns.
5. Skriver `CLAUDE.md` (regler) och `PROJEKT.md` (alla projekt med status och nästa steg) i `C:\Donkeystories`, en `CLAUDE.md` i varje projekt och en sammanfattning av varje tidigare session i `sessioner\logg`.
6. Sparar **alla Claude Code-chattar** i `C:\Donkeystories\sessioner\claude-historik`, och gör att gamla chattar går att öppna från projektens nya platser.
7. Ställer in Claude Code:
   - Claude läser `C:\Donkeystories` först i varje session.
   - Chattar sparas i 10 år, i stället för att raderas efter 30 dagar.
   - Claude får arbeta i mappen från alla projekt.

Allt som ändras i Claudes inställningar säkerhetskopieras först, till `C:\Donkeystories\verktyg\sakerhetskopior`.

## Innan du börjar

- **Spara och stäng** Claude-appen, alla Claude Code-fönster, VEGAS och Cubase. Skriptet erbjuder sig att stänga de lokala Python-servrarna (Cowork, God Mode, Lyrics och de andra) och väntar tills Claude är stängt.
- Kör skriptet på **varje dator och Windows-konto** där du har använt Claude: huvuddatorn med projekten i Dokument, och kontot där Sparly ligger på Skrivbordet.

## Steg 1: hämta och provkör (ändrar ingenting)

Öppna **PowerShell**: tryck på Start, skriv `PowerShell` och tryck Enter. Klistra in de här raderna och tryck Enter:

```powershell
$m = "$env:TEMP\donkeystories-setup"
[Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-WebRequest "https://github.com/Donkey229/donkeystories/archive/refs/heads/claude/donkeystories-folder-setup-5gzoey.zip" -OutFile "$m.zip" -UseBasicParsing
Expand-Archive "$m.zip" $m -Force
Get-ChildItem $m -Recurse -File | Unblock-File
$k = (Get-ChildItem $m -Recurse -Filter installera.cmd | Select-Object -First 1).FullName
& $k -Provkorning
```

Skriptet visar då vad det **skulle** göra: vilka mappar det hittade och vart de skulle flyttas. Ingenting ändras.

## Steg 2: kör på riktigt

I samma PowerShell-fönster:

```powershell
& $k
```

Svara `j` (ja) eller `n` (nej) på frågorna. Att bara trycka Enter väljer förslaget inom hakparentes, där den stora bokstaven är förslaget.
Det går också bra att dubbelklicka på `installera.cmd` i den uppackade mappen.

Skriptet kan köras flera gånger. Det som redan är gjort hoppas över.

**Om Windows stoppar skriptet** (Smart App Control eller "begränsat läge"): högerklicka på `installera.ps1` → Egenskaper → kryssa i **Avblockera** → OK, och försök igen. Raden `Unblock-File` ovan gör samma sak.

## Efteråt

1. **Starta Claude i `C:\Donkeystories`.** I Claude-appen väljer du mappen `C:\Donkeystories`, eller en projektmapp under den, och skriver till exempel *"Läs C:\Donkeystories och berätta vad som finns"*.
2. **Starta servrarna igen** (Donkey Cowork och de andra) med genvägarna på skrivbordet.
3. **Cowork i Claude-appen:** Cowork läser inte alltid CLAUDE.md. Gå till **Inställningar → Allmänt → Instruktioner för Claude** och skriv:
   *"Läs alltid C:\Donkeystories\CLAUDE.md och C:\Donkeystories\PROJEKT.md först. Spara allt nytt i C:\Donkeystories."*
   Välj sedan mappen `C:\Donkeystories` när du startar en Cowork-uppgift.
4. **Gamla chattar:** alla finns kvar. De syns i `/resume` om du startar Claude i den gamla mappen (den är nu en länk). I den nya mappen öppnar du dem med `claude --resume <id>`. Listan med id finns i `C:\Donkeystories\sessioner\aterupptagning.md`.
   Första gången du öppnar en flyttad projektmapp frågar Claude om du litar på mappen. Svara ja. Har ett projekt haft egna MCP-servrar behöver de läggas till igen.
5. **Första sessionen:** be Claude gå igenom de gamla chattarna i `sessioner\claude-historik` och fylla på projektens `CLAUDE.md`. Där får privata detaljer stå, eftersom mappen bara finns på datorn.
6. **Säkerhetskopia:** `C:\Donkeystories` säkerhetskopieras inte automatiskt, varken av OneDrive eller av Filhistorik. Lägg till mappen i din säkerhetskopiering.
7. **Git saknas** på datorn där Sparly ligger. Vill du att skriptet ska kunna hämta repona, installera Git (kör `winget install --id Git.Git -e` i PowerShell) och kör skriptet igen.

## Moln och mobil

Claude i molnet och i mobilen (claude.ai/code) **kommer inte åt `C:\`**. Där finns bara GitHub-repona.
Vill du jobba med filerna i `C:\Donkeystories` från mobilen, starta **Remote Control** på datorn.
Ska Claude i molnet också kunna läsa samlingsmappen behövs ett **privat** GitHub-repo för den. `C:\Donkeystories\.gitignore` är redan förberedd för det.

## Ångra

- **Ett projekt:** ta bort länken på den gamla platsen och flytta tillbaka mappen.
  - Ta bort länken med `cmd /c rmdir "C:\Users\...\Documents\projektnamn"`. Det tar bara bort länken, inte filerna.
  - **Använd aldrig `Remove-Item -Recurse` på en länk**, eftersom den kan radera filerna den pekar på.
  - Flytta sedan tillbaka mappen från `C:\Donkeystories\projekt\`.
- **Chatthistoriken:** stäng Claude och kör `cmd /c rmdir "%USERPROFILE%\.claude\projects"`. Flytta sedan tillbaka mappen `C:\Donkeystories\sessioner\claude-historik\<ditt kontonamn>` till `%USERPROFILE%\.claude\projects`.
- **Claude-inställningarna:** kopiorna av `settings.json` och `CLAUDE.md` som de såg ut innan ligger i `C:\Donkeystories\verktyg\sakerhetskopior\`.

## Filer här

| Fil | Vad |
|---|---|
| `installera.cmd` | Dubbelklicka för att köra |
| `installera.ps1` | Själva skriptet (Windows PowerShell 5.1) |
| `projekt.json` | Listan över projekt och var de låg innan |
| `mall\` | Det som kopieras till `C:\Donkeystories`: CLAUDE.md, PROJEKT.md, projektens CLAUDE.md och sessionsloggar |

Mappen publiceras inte på hemsidan (se `_config.yml` i repots rot). Den innehåller inga lösenord eller privata uppgifter.
