# Donkey Grading

> Mapp: `C:\Donkeystories\projekt\donkey-grading` · Ansvarig i Donkey Lab: Leo

Donkey Grading är ett eget färggraderingsprogram:
- LUT och filter
- vectorscope
- export via ffmpeg
- auto-vitbalans
- igenkänning av Sony S-Log2

Programmet äger alla looks, som ligger i `projekt\donkey-looks`.
Det ses som den säljbara produkten (lookpaket).

## Regler
- En look får aldrig skrivas över. Spara nya versioner i stället.
- Förhandsvisning och export får aldrig skilja sig åt (mindre än 1/255).
- Panelen och Film läser bara looks härifrån. All färglogik ligger här.

## Lookpaket (byggda 2026-10-01, inte sålda)
- **S-Log2 Essentials** (249 kr): omvandling plus 5 looks
- **Ljus & luftig Nordic** (149 kr): 6 looks

Paketen byggs med `py -3.14 lookpaket.py --bara "S-Log2 Essentials" --ersatt` och ligger i `tester\lookpaket\`.
Donkey har godkänt säljbilderna, som inte visar några människor, ingen läsbar text och inga varumärken.
Det som saknas är betallänk, licensuppgifter (licensgivare, ångerrätt, moms) och test i Resolve, Premiere, VEGAS och CapCut.
Andras namn (t.ex. Kodak, Fuji, BEER BAIYOKE) får inte användas i looknamn.

## Nästa steg (rådets förslag)
- före/efter och batch
- matchning mot en referensbild
- stöd för S-Log3 och iPhone HLG
- export av lookpaket till hemsidans Looks-sida
- testa på fler kameror
