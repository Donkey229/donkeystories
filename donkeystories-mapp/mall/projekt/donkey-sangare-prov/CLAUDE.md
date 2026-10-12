# Donkey-sångare (prov)

> Mapp: `C:\Donkeystories\projekt\donkey-sangare-prov` · Obs: mappen är stor (ComfyUI och modeller, cirka 26 GB)

## Vad det är
Det här är prov på en tecknad Donkey-åsna som sjunger, med munrörelser från sångrösten (via Demucs), helt lokalt.
Det finns också ett realistiskt prov med Wan2.2-S2V i ComfyUI portable.
Styrelsen valde den tecknade figuren och bygger vidare på den när inkomstdelarna är klara.

## Så körs det
- **Tecknad:** `gor_video.py` med Python 3.14. 15 s video tar cirka 37 s.
- **Wan:** ComfyUI headless på 127.0.0.1:8188, offline (`HF_HUB_OFFLINE=1`).

## Regler
- Använd aldrig riktiga personers ansikten utan deras ja. Aldrig Donkey och Emma.
- Varje nedladdning kräver Donkeys ja för exakt fil, källa och storlek.
- ComfyUI körs bara på 127.0.0.1, offline, och stängs efteråt.

## Nästa steg
- Gör den tecknade sångaren generell för valfri låt. I dag är den hårdkodad till en låt.
