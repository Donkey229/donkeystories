# Donkey Film

> Mapp: `C:\Donkeystories\projekt\donkey-film` · Start: `Starta Donkey Film.bat`

## Vad det är
Donkey Film gör färdiga klipp av en låt plus film eller bilder:
- TikTok, Reels, Shorts och YouTube
- Spotify Canvas
- fyrkantigt flöde
- en omslagsbild

Den bygger på PySide6, FFmpeg (NVENC), librosa och faster-whisper (undertexter) och har en egen venv: `_py311`.

## Viktigt
- Projektets egna regler (`CLAUDE.md` eller `.claude\CLAUDE.md`) och `LÄS MIG.md` gäller först.
- Rör aldrig VEGAS. Appen renderar själv med FFmpeg.
- Nycklar i koden är ASCII (stjarnfall, solnedgang). Byt dem aldrig mot å, ä eller ö.
- Smart App Control blockerar vissa DLL:er i `_py311`. Rapportera, och ändra aldrig inställningen.

## Status (2026-10-01): cirka 96 %
- Musikvideo (Galaxy, 4K) är inflyttad. Fas B (looks från Donkey Grading) och C1 (automatisk sångtext och en kö som tål avbrott) är klara.
- Neon-karaoke är förval i kortvideor (Donkeys val). Sångtiderna tas fram via Demucs (`core\roststam.py`).
- Testerna: 369 tester, varav 2 gamla fel i `test_visuals.TestSnabbvagenMotVanligaVagen`.
- Kortvideor för låt 14–19 väntar på att neon-texten som överlappar omslagskortet rättas.

## Kvar
- Rätta neon-texten och gör sedan om kortvideorna.
- Engelska rader där första ordet hålls ut hamnar sent.
- Fel med thailändska filnamn i `core\jobs.py` rad 40.
- Snabbförhandsvisning (punkt 11).
- Faster-whisper frågar HuggingFace vid laddning. Sätt `HF_HUB_OFFLINE=1`.
- Gamla `musikvideo` lämnas orörd tills Donkey har testat och sagt ja.

## Regler
- Kör aldrig Films fönster mot Donkeys riktiga `installningar.json`. Använd en kopia via LOCALAPPDATA.
- Kör `Kör testerna.bat` innan något sägs vara klart.
- Ändra aldrig något på E:.

## Så körs det
- **Starta:** `Starta Donkey Film.bat`
- **Testa:** `Kör testerna.bat`
