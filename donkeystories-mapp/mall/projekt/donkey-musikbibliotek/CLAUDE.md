# Donkey Musikbibliotek (musikpaket)

> Mapp: `C:\Donkeystories\projekt\donkey-musikbibliotek` · Inkomstprojekt 2 i Donkey Lab, ansvarig Leo

## Vad det är
Licensierade musikpaket med 10 låtar vardera. Varje låt finns som sångversion, instrumental (via Demucs) och 30 s prov.
Paketet innehåller också omslag i 3000x3000 och 1280x720, `licens.txt` och `lattlista.csv`, samlat i en zip.
`katalog.py` inventerar låtarna på `E:\Musik` (565 unika låtar).

## Så körs det
- **Bygga ett paket:** `py -3.14 paketbyggare.py` (se `LÄS MIG.md`)
- **Tester:** `tester\test_paketbyggare.py`

## Status (2026-10-01)
- Paketbyggaren v1.1 är klar och testerna är gröna.
- Tre paket är byggda: Isan Trap, Phonk Drive och Lo-fi Study. Inget är sålt.

## Regler
- Pris 99 kr per paket (Donkey kan ändra).
- Paketen får säljas först när Donkey säger "publicera".
- Licensen förbjuder AI-träning och vidareförsäljning. Inget Content ID.
- Sunos märkning ligger kvar i filerna, byte för byte.
- `E:\Musik` läses bara.

## Nästa steg
1. Donkey lyssnar på instrumentalen till LD01 (den kan ha sångrester kvar).
2. Licensen är ett **utkast**. Säljarens namn, kontaktväg och lag saknas.
3. En betallänk per paket (Lemon Squeezy är förstahandsval, Gumroad reserv). Konto skapas bara efter Donkeys ja.
