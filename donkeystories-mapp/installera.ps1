#Requires -Version 5.1
<#
.SYNOPSIS
    Skapar C:\Donkeystories och samlar alla Donkey Stories-projekt, sessioner och
    Claude-instruktioner där.

.DESCRIPTION
    Skriptet gör följande, och frågar innan varje steg som flyttar eller ändrar något:

      1. Skapar mappen C:\Donkeystories med undermapparna projekt, sessioner,
         anteckningar, arkiv och verktyg.
      2. Letar upp projektmappar på datorn (kända platser, mappar där Claude Code
         har arbetat, och git-repon som hör till GitHub-kontot Donkey229).
      3. Flyttar de projektmappar du godkänner till C:\Donkeystories\projekt.
      4. Hämtar (klonar) GitHub-repon som inte redan finns på datorn.
      5. Skriver CLAUDE.md i samlingsmappen och i varje projekt, plus
         PROJEKT.md (projektlistan) och sammanfattningar av tidigare sessioner.
      6. Kopierar Claude Codes sessionshistorik så att gamla chattar går att
         återuppta från projektens nya platser, och flyttar (om du vill) hela
         historikmappen till C:\Donkeystories\sessioner\claude-historik.
      7. Ställer in Claude Code så att Claude alltid läser C:\Donkeystories
         först, får arbeta i mappen utan att fråga, och inte raderar gamla
         chattar efter 30 dagar.

    Skriptet går att köra flera gånger. Det skriver aldrig över filer som redan
    finns (förutom Donkeystories-blocket i din globala CLAUDE.md) och tar
    säkerhetskopior innan det ändrar Claude-inställningar.

.PARAMETER Mapp
    Var samlingsmappen ska ligga. Standard: C:\Donkeystories

.PARAMETER Provkorning
    Visa bara vad som skulle hända. Ingenting skapas, flyttas eller ändras.

.PARAMETER Ja
    Svara med standardsvaret på alla frågor (ingen interaktion).

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\installera.ps1 -Provkorning
#>
[CmdletBinding()]
param(
    [string]$Mapp = 'C:\Donkeystories',
    [string]$Hem = $env:USERPROFILE,
    [switch]$Provkorning,
    [switch]$Ja
)

$ErrorActionPreference = 'Stop'
$Sep = [System.IO.Path]::DirectorySeparatorChar
$PaWindows = ($PSVersionTable.PSEdition -eq 'Desktop') -or ($IsWindows -eq $true)
$Kalla = $PSScriptRoot
$Idag = Get-Date -Format 'yyyy-MM-dd'
$Tidsstampel = Get-Date -Format 'yyyyMMdd-HHmmss'
$Utf8UtanBom = New-Object System.Text.UTF8Encoding($false)
$Sammanfattning = New-Object System.Collections.Generic.List[string]
$Varningar = New-Object System.Collections.Generic.List[string]

# ---------------------------------------------------------------------------
# Hjälpfunktioner
# ---------------------------------------------------------------------------

function Skriv-Rubrik([string]$Text) {
    Write-Host ''
    Write-Host ('=' * 70) -ForegroundColor DarkCyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host ('=' * 70) -ForegroundColor DarkCyan
}

function Skriv-Info([string]$Text)  { Write-Host "  $Text" }
function Skriv-Klart([string]$Text) {
    if ($Provkorning) { Write-Host "  [prov] $Text" -ForegroundColor Yellow; $Sammanfattning.Add("(prov) $Text"); return }
    Write-Host "  [klart] $Text" -ForegroundColor Green
    $Sammanfattning.Add($Text)
}
function Skriv-Prov([string]$Text)  { Write-Host "  [prov] $Text" -ForegroundColor Yellow }
function Skriv-Varning([string]$Text) { Write-Host "  [obs] $Text" -ForegroundColor Yellow; $Varningar.Add($Text) }

function Fraga([string]$Text, [bool]$Standard = $true) {
    if ($Ja -or $Provkorning) { return $Standard }
    $alternativ = if ($Standard) { '[J/n]' } else { '[j/N]' }
    while ($true) {
        $svar = Read-Host "  $Text $alternativ"
        if ([string]::IsNullOrWhiteSpace($svar)) { return $Standard }
        $svar = $svar.Trim().ToLowerInvariant()
        if ($svar -in @('j', 'ja', 'y', 'yes')) { return $true }
        if ($svar -in @('n', 'nej', 'no')) { return $false }
        Write-Host '  Svara j (ja) eller n (nej).'
    }
}

function Normalisera([string]$Sokvag) {
    if ([string]::IsNullOrWhiteSpace($Sokvag)) { return $null }
    # Bara fullständiga sökvägar (C:\...). En relativ sökväg skulle annars tolkas från den mapp skriptet körs i.
    if (-not [System.IO.Path]::IsPathRooted($Sokvag)) { return $null }
    if ($PaWindows -and $Sokvag -notmatch '^([a-zA-Z]:[\\/]|\\\\)') { return $null }
    try { $full = [System.IO.Path]::GetFullPath($Sokvag) } catch { return $null }
    $rot = [System.IO.Path]::GetPathRoot($full)
    if ($full.Length -gt $rot.Length) { $full = $full.TrimEnd('\', '/') }
    return $full
}

function Ar-Samma([string]$A, [string]$B) {
    if (-not $A -or -not $B) { return $false }
    return [string]::Equals($A, $B, [System.StringComparison]::OrdinalIgnoreCase)
}

# Ligger $Barn inuti $Forelder (eller är samma mapp)?
function Ar-Inuti([string]$Barn, [string]$Forelder) {
    if (-not $Barn -or -not $Forelder) { return $false }
    if (Ar-Samma $Barn $Forelder) { return $true }
    $f = $Forelder.TrimEnd('\', '/') + $Sep
    return $Barn.StartsWith($f, [System.StringComparison]::OrdinalIgnoreCase)
}

# Windows egna mappar (Dokument, Skrivbord, Musik ...) – de kan vara flyttade till OneDrive.
function Specialmapp([string]$Namn, [string]$Reserv) {
    $p = $null
    if (Ar-Samma $Hem $env:USERPROFILE) {
        try { $p = [System.Environment]::GetFolderPath($Namn) } catch { $p = $null }
    }
    if (-not $p -or (Ar-Samma $p $Hem)) { $p = Join-Path $Hem $Reserv }
    return $p
}

function Expandera([string]$Sokvag) {
    $oneDrive = $env:OneDrive
    if (-not $oneDrive) { $oneDrive = Join-Path $Hem 'OneDrive' }
    $s = $Sokvag.Replace('%DOKUMENT%', (Specialmapp 'MyDocuments' 'Documents')).Replace('%SKRIVBORD%', (Specialmapp 'Desktop' 'Desktop'))
    $s = $s.Replace('%USERPROFILE%', $Hem).Replace('%OneDrive%', $oneDrive)
    $s = [System.Environment]::ExpandEnvironmentVariables($s)
    if (-not $PaWindows) { $s = $s.Replace('\', '/') }
    return $s
}

# Läser text som UTF-8. Är filen sparad i Windows gamla teckenkodning (ANSI) läses den som det,
# så att å, ä och ö inte förstörs när filen skrivs tillbaka.
function Las-Text([string]$Fil) {
    $byte = [System.IO.File]::ReadAllBytes($Fil)
    try {
        $text = (New-Object System.Text.UTF8Encoding($false, $true)).GetString($byte)
    } catch {
        $text = [System.Text.Encoding]::Default.GetString($byte)
    }
    if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) { $text = $text.Substring(1) }
    return $text
}

function Skriv-Text([string]$Fil, [string]$Text) {
    if ($Provkorning) { Skriv-Prov "skulle skriva $Fil"; return }
    $mapp = Split-Path -Parent $Fil
    if ($mapp -and -not (Test-Path -LiteralPath $mapp)) { New-Item -ItemType Directory -Path $mapp -Force | Out-Null }
    [System.IO.File]::WriteAllText($Fil, $Text, $Utf8UtanBom)
}

# Säkerhetskopior samlas i C:\Donkeystories\verktyg\sakerhetskopior\<tid>\ så att inga lösa
# filer hamnar i projektmapparna. Filnamnet visar var originalet låg.
function Sakerhetskopiera([string]$Fil) {
    if ($Provkorning -or -not (Test-Path -LiteralPath $Fil)) { return }
    $mapp = Join-Path (Join-Path (Join-Path $Mapp 'verktyg') 'sakerhetskopior') $Tidsstampel
    if (-not (Test-Path -LiteralPath $mapp)) { New-Item -ItemType Directory -Path $mapp -Force | Out-Null }
    $namn = ($Fil -replace '[:\\/]+', '_').Trim('_')
    $kopia = Join-Path $mapp $namn
    Copy-Item -LiteralPath $Fil -Destination $kopia -Force
    Skriv-Info "Säkerhetskopia: $kopia"
}

function Skapa-Mapp([string]$Sokvag) {
    if (Test-Path -LiteralPath $Sokvag) { return }
    if ($Provkorning) { Skriv-Prov "skulle skapa mappen $Sokvag"; return }
    New-Item -ItemType Directory -Path $Sokvag -Force | Out-Null
}

# Ersätter C:\Donkeystories i mallarna om skriptet körs med en annan -Mapp.
function Anpassa-Mall([string]$Text) {
    if (Ar-Samma $Mapp 'C:\Donkeystories') { return $Text }
    return $Text.Replace('C:\Donkeystories', $Mapp).Replace('C:/Donkeystories', $Mapp.Replace('\', '/'))
}

$FlyttMarkor = '.donkeystories-flyttas-fran.txt'
$BlockStart = '<!-- donkeystories:start -->'
$BlockSlut = '<!-- donkeystories:slut -->'

# Lägger till (eller ersätter) Donkeystories-blocket i en fil och lämnar resten orört.
function Uppdatera-Block([string]$Fil, [string]$Block, [bool]$ErsattBefintligt) {
    $nyttBlock = "$BlockStart`n$($Block.Trim())`n$BlockSlut"
    if (Test-Path -LiteralPath $Fil) {
        $text = Las-Text $Fil
        $i = $text.IndexOf($BlockStart)
        $j = $text.IndexOf($BlockSlut)
        if ($i -ge 0 -and $j -gt $i) {
            if (-not $ErsattBefintligt) { return $false }
            $nyText = $text.Substring(0, $i) + $nyttBlock + $text.Substring($j + $BlockSlut.Length)
            if ($nyText -eq $text) { return $false }
        } else {
            $nyText = $text.TrimEnd() + "`n`n" + $nyttBlock + "`n"
        }
        Sakerhetskopiera $Fil
        Skriv-Text $Fil $nyText
    } else {
        Skriv-Text $Fil ($nyttBlock + "`n")
    }
    return $true
}

# Målmappar som bara innehåller vår CLAUDE.md (från en tidigare körning) töms innan
# en projektmapp flyttas eller klonas dit. Texten sparas och läggs tillbaka efteråt.
# Texten säkerhetskopieras alltid till disk först, och mappen tas bara bort om den är tom.
function Ta-Undan-Claude([string]$ProjektMapp) {
    if ($Provkorning -or -not (Test-Path -LiteralPath $ProjektMapp)) { return $null }
    if (Ar-Lank $ProjektMapp) { throw "Målmappen $ProjektMapp är en länk och rörs inte." }
    $ovrigt = @(Get-ChildItem -LiteralPath $ProjektMapp -Force | Where-Object { $_.Name -ne 'CLAUDE.md' })
    if ($ovrigt.Count -gt 0) { throw "Målmappen $ProjektMapp är inte tom." }
    $text = $null
    $fil = Join-Path $ProjektMapp 'CLAUDE.md'
    if (Test-Path -LiteralPath $fil) {
        $text = Las-Text $fil
        Sakerhetskopiera $fil
        Remove-Item -LiteralPath $fil -Force
    }
    try {
        [System.IO.Directory]::Delete($ProjektMapp, $false)
    } catch {
        if ($text) { Skriv-Text $fil $text }
        throw "Målmappen $ProjektMapp används av ett program (är Claude eller Utforskaren öppen där?)."
    }
    return $text
}

# Lägger tillbaka texten som Ta-Undan-Claude sparade. Har projektet en egen CLAUDE.md läggs hela
# den sparade texten till sist i den, så att inga anteckningar försvinner.
function Aterstall-Claude([string]$ProjektMapp, [string]$Sparad) {
    if ($Provkorning -or -not $Sparad -or -not $Sparad.Trim()) { return }
    $fil = Join-Path $ProjektMapp 'CLAUDE.md'
    if (-not (Test-Path -LiteralPath $ProjektMapp)) { New-Item -ItemType Directory -Path $ProjektMapp -Force | Out-Null }
    if (-not (Test-Path -LiteralPath $fil)) { Skriv-Text $fil $Sparad; return }
    $nu = Las-Text $fil
    if ($nu.Contains($Sparad.Trim())) { return }
    Sakerhetskopiera $fil
    Skriv-Text $fil ($nu.TrimEnd() + "`n`n## Anteckningar från C:\Donkeystories (skrivna innan projektet flyttades hit)`n`n" + $Sparad.Trim() + "`n")
}

function Beskriv-Storlek([string]$Sokvag) {
    $filer = @(Get-ChildItem -LiteralPath $Sokvag -Recurse -File -Force -ErrorAction SilentlyContinue)
    $byte = ($filer | Measure-Object -Property Length -Sum).Sum
    if (-not $byte) { $byte = 0 }
    $mb = [math]::Round($byte / 1MB, 1)
    return "$($filer.Count) filer, $mb MB"
}

# Claude Code döper sessionsmappar efter arbetsmappen: alla tecken utom a-z, A-Z, 0-9 blir '-'.
# Namn längre än 200 tecken kortas av Claude Code med en kontrollsumma; dem hoppar vi över.
function Koda-Projektmapp([string]$Sokvag) {
    $namn = $Sokvag -replace '[^a-zA-Z0-9]', '-'
    if ($namn.Length -gt 200) { return $null }
    return $namn
}

# Läser arbetsmappen (cwd) ur en Claude Code-sessionsfil (.jsonl) utan att läsa hela filen.
function Las-Cwd([string]$JsonlFil) {
    $strom = $null
    try {
        $strom = [System.IO.File]::Open($JsonlFil, 'Open', 'Read', 'ReadWrite')
        $lasare = New-Object System.IO.StreamReader($strom, [System.Text.Encoding]::UTF8)
        for ($n = 0; $n -lt 200; $n++) {
            $rad = $lasare.ReadLine()
            if ($null -eq $rad) { break }
            $m = [regex]::Match($rad, '"cwd"\s*:\s*"((?:[^"\\]|\\.)*)"')
            if ($m.Success -and $m.Groups[1].Value) { return [regex]::Unescape($m.Groups[1].Value) }
        }
    } catch {
        return $null
    } finally {
        if ($strom) { $strom.Dispose() }
    }
    return $null
}

function Claude-Kor {
    if (-not $PaWindows) { return @() }
    return @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match '^(claude|Claude)$' })
}

# Väntar tills Claude är stängt. Returnerar $false om användaren hoppar över.
function Vanta-Pa-Stangd-Claude([string]$Varfor) {
    if ((Claude-Kor).Count -eq 0) { return $true }
    Skriv-Info "Claude körs just nu. $Varfor"
    Skriv-Info 'Avsluta Claude helt: stäng alla Claude Code-fönster och högerklicka på Claude-ikonen vid klockan -> Avsluta (Quit).'
    if ($Ja -or $Provkorning) { Skriv-Varning "Claude var igång – hoppade över: $Varfor"; return $false }
    while ((Claude-Kor).Count -gt 0) {
        $svar = Read-Host '  Tryck Enter när Claude är avslutat (eller skriv h för att hoppa över det här steget)'
        if ($svar -and $svar.Trim().ToLowerInvariant() -eq 'h') { Skriv-Varning "Hoppade över medan Claude var igång: $Varfor"; return $false }
    }
    return $true
}

# Är sökvägen en länk (junction/symbolisk länk)? OneDrive-mappar räknas inte som länkar.
function Ar-Lank([string]$Sokvag) {
    $objekt = Get-Item -LiteralPath $Sokvag -Force -ErrorAction SilentlyContinue
    if (-not $objekt) { return $false }
    $typ = $null
    if ($objekt.PSObject.Properties['LinkType']) { $typ = $objekt.LinkType }
    return ($typ -eq 'Junction' -or $typ -eq 'SymbolicLink')
}

# Ligger sökvägen i (eller under) en länk? Då är mappen redan flyttad.
function Under-Lank([string]$Sokvag) {
    $d = $Sokvag
    while ($d) {
        if (Ar-Lank $d) { return $true }
        $foralder = Split-Path -Parent $d
        if (-not $foralder -or (Ar-Samma $foralder $d)) { break }
        $d = $foralder
    }
    return $false
}

# Skapar en länk (junction) på $Lank som pekar till $Mal. På Linux (bara vid test) blir det en symbolisk länk.
# På Windows används mklink /J, eftersom New-Item tolkar [ och ] i mappnamn som jokertecken.
function Skapa-Lank([string]$Lank, [string]$Mal) {
    if ($Provkorning) { Skriv-Prov "skulle skapa länken $Lank -> $Mal"; return $true }
    try {
        if ($PaWindows) {
            # Varje sökväg skickas som ett eget argument inom citattecken (klarar mellanslag, & och [ ]).
            $tidigare = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            try { $utdata = & cmd.exe /d /c mklink /J "`"$Lank`"" "`"$Mal`"" 2>&1 } finally { $ErrorActionPreference = $tidigare }
            if ($LASTEXITCODE -ne 0) { throw ((@($utdata) | ForEach-Object { "$_" }) -join ' ') }
        } else {
            New-Item -ItemType SymbolicLink -Path $Lank -Target $Mal | Out-Null
        }
        if (-not (Ar-Lank $Lank)) { throw 'länken skapades inte' }
        return $true
    } catch {
        Skriv-Varning "Kunde inte skapa länken $Lank -> $Mal ($($_.Exception.Message)). Projektet ligger i $Mal."
        return $false
    }
}

# Skapar en vanlig Windows-genväg (.lnk) som öppnar $Mal.
function Skapa-Genvag([string]$Genvag, [string]$Mal) {
    if ($Provkorning) { Skriv-Prov "skulle skapa genvägen $Genvag -> $Mal"; return }
    if (-not $PaWindows -or (Test-Path -LiteralPath $Genvag)) { return }
    try {
        $skal = New-Object -ComObject WScript.Shell
        $g = $skal.CreateShortcut($Genvag)
        $g.TargetPath = $Mal
        $g.Save()
    } catch {
        Skriv-Varning "Kunde inte skapa genvägen $Genvag ($($_.Exception.Message))."
    }
}

# Program som håller projektmappar öppna gör att de inte går att flytta.
# Lokala Python-servrar (Donkey Cowork, God Mode, Lyrics, Ljudbrädan ...) kan stängas automatiskt
# och startas igen med sina genvägar efteråt. Allt annat får användaren stänga själv.
# Returnerar $false om Claude fortfarande körs; då flyttas ingenting.
function Stang-Program-Som-Laser {
    if (-not $PaWindows) { return $true }
    if (-not (Vanta-Pa-Stangd-Claude 'Mappar som Claude arbetar i kan inte flyttas medan Claude är igång.')) { return $false }
    $redigerare = @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match '^(vegas\d*|Cubase.*|Code|Resolve|Premiere.*|Audacity|Reaper)$' })
    if ($redigerare.Count -gt 0 -and -not $Ja) {
        $namn = ($redigerare | ForEach-Object { $_.ProcessName } | Select-Object -Unique) -join ', '
        Skriv-Info "Dessa program är öppna: $namn. Spara och stäng dem om de använder en projektmapp."
        [void](Read-Host '  Tryck Enter för att fortsätta')
    }
    return $true
}

function Python-Program {
    if (-not $PaWindows) { return @() }
    return @(Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -match '^(python|pythonw|py|pyw)\d*(\.\d+)?$' })
}

# Returnerar 'ok', 'upptagen' (mappen används av ett program) eller 'fel'.
function Flytta-Mapp([string]$Fran, [string]$Till) {
    if ($Provkorning) { Skriv-Prov "skulle flytta $Fran -> $Till"; return 'ok' }
    if (-not (I-OneDrive $Fran)) {
        # Samma disk: ett namnbyte, går direkt även för stora mappar.
        try {
            Move-Item -LiteralPath $Fran -Destination $Till
            return 'ok'
        } catch {
            Skriv-Info "Kunde inte flytta $Fran just nu ($($_.Exception.Message))."
            return 'upptagen'
        }
    }
    if (-not $PaWindows) {
        Skriv-Varning "OneDrive-flytt stöds bara på Windows: $Fran"
        return 'fel'
    }
    # Robocopy /MOVE följer länkar och skulle flytta filerna länken pekar på. Mappar med länkar flyttas inte.
    $lankar = @(Get-ChildItem -LiteralPath $Fran -Recurse -Force -Directory -ErrorAction SilentlyContinue | Where-Object { Ar-Lank $_.FullName })
    if ($lankar.Count -gt 0) {
        Skriv-Varning "$Fran innehåller länkar ($($lankar[0].FullName)) och flyttas inte automatiskt. Flytta den för hand."
        return 'fel'
    }
    # OneDrive: kopiera fil för fil och radera originalet efter varje lyckad kopia.
    # Robocopy laddar ner filer som bara finns i molnet innan de kopieras.
    # En markörfil i målmappen gör att en avbruten flytt fortsätter i samma mapp nästa gång.
    if (-not (Test-Path -LiteralPath $Till)) { New-Item -ItemType Directory -Path $Till -Force | Out-Null }
    $markor = Join-Path $Till $FlyttMarkor
    [System.IO.File]::WriteAllText($markor, $Fran, $Utf8UtanBom)
    & robocopy.exe $Fran $Till /E /MOVE /COPY:DAT /DCOPY:T /R:2 /W:2 /XF $FlyttMarkor /NP /NFL /NDL /NJH /NJS | Out-Null
    $kod = $LASTEXITCODE
    $kvar = 0
    if (Test-Path -LiteralPath $Fran) {
        $kvar = @(Get-ChildItem -LiteralPath $Fran -Recurse -Force -File -ErrorAction SilentlyContinue).Count
        if ($kvar -eq 0) { Remove-Item -LiteralPath $Fran -Recurse -Force -ErrorAction SilentlyContinue }
    }
    if ($kod -ge 8 -or $kvar -gt 0) {
        Skriv-Varning "Allt kunde inte flyttas från $Fran ($kvar filer kvar, robocopy-kod $kod). Det som flyttats ligger i $Till. Kör skriptet igen så fortsätter flytten dit."
        return 'fel'
    }
    Remove-Item -LiteralPath $markor -Force -ErrorAction SilentlyContinue
    return 'ok'
}

# ---------------------------------------------------------------------------
# Start
# ---------------------------------------------------------------------------

if (-not $Hem) { throw 'Hittar inte din användarmapp (USERPROFILE). Ange den med -Hem.' }
$Hem = Normalisera $Hem
$Mapp = Normalisera $Mapp
$ClaudeMapp = Join-Path $Hem '.claude'
$ClaudeProjekt = Join-Path $ClaudeMapp 'projects'
$ProjektRot = Join-Path $Mapp 'projekt'
$ArkivRot = Join-Path $Mapp 'arkiv'
# Varje Windows-konto får en egen historikmapp, så att två konton på samma dator inte blandas.
$HistorikMapp = Join-Path (Join-Path (Join-Path $Mapp 'sessioner') 'claude-historik') (Split-Path -Leaf $Hem)
$MallMapp = Join-Path $Kalla 'mall'
$Konfig = (Las-Text (Join-Path $Kalla 'projekt.json')) | ConvertFrom-Json
$Projektlista = @($Konfig.projekt)

Skriv-Rubrik 'Donkeystories – samla allt i en mapp'
Skriv-Info "Samlingsmapp:   $Mapp"
Skriv-Info "Användarmapp:   $Hem"
if ($Provkorning) { Skriv-Varning 'PROVKÖRNING – ingenting ändras, skriptet visar bara vad som skulle hända.' }
if (-not $Provkorning -and -not $Ja) {
    if (-not (Fraga 'Vill du starta?' $true)) { Skriv-Info 'Avbrutet. Ingenting har ändrats.'; return }
}

# ---------------------------------------------------------------------------
# 1. Mappstruktur
# ---------------------------------------------------------------------------
Skriv-Rubrik '1. Skapar mappstrukturen'
foreach ($under in @('', 'projekt', 'sessioner', (Join-Path 'sessioner' 'logg'), 'anteckningar', 'arkiv', 'verktyg')) {
    Skapa-Mapp (Join-Path $Mapp $under)
}
$Logg = Join-Path (Join-Path $Mapp 'sessioner') "installationslogg-$Tidsstampel.txt"
$Transkript = $false
if (-not $Provkorning) {
    try { Start-Transcript -LiteralPath $Logg | Out-Null; $Transkript = $true } catch { }
}
Skriv-Klart "Mappstrukturen finns i $Mapp"

try {

# ---------------------------------------------------------------------------
# 2. Leta efter projektmappar
# ---------------------------------------------------------------------------
Skriv-Rubrik '2. Letar efter projektmappar på datorn'

# Alla OneDrive-konton (privat och jobb) räknas, inte bara det i $env:OneDrive.
$OneDriveRotter = New-Object System.Collections.Generic.List[string]
foreach ($r in @($env:OneDrive, $env:OneDriveConsumer, $env:OneDriveCommercial)) {
    $n = Normalisera $r
    if ($n -and -not ($OneDriveRotter -contains $n)) { $OneDriveRotter.Add($n) }
}
if ($PaWindows -and (Ar-Samma $Hem $env:USERPROFILE)) {
    foreach ($konto in @(Get-ChildItem -Path 'HKCU:\Software\Microsoft\OneDrive\Accounts' -ErrorAction SilentlyContinue)) {
        $n = Normalisera ([string](Get-ItemProperty -Path $konto.PSPath -ErrorAction SilentlyContinue).UserFolder)
        if ($n -and -not ($OneDriveRotter -contains $n)) { $OneDriveRotter.Add($n) }
    }
}
$OneDriveRot = if ($OneDriveRotter.Count -gt 0) { $OneDriveRotter[0] } else { $null }
function I-OneDrive([string]$Sokvag) {
    foreach ($r in $OneDriveRotter) { if (Ar-Inuti $Sokvag $r) { return $true } }
    return $false
}
$Skyddade = New-Object System.Collections.Generic.List[string]
foreach ($s in @(@($Hem, $ClaudeMapp, $Mapp, $Kalla, $env:SystemRoot, $env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:ProgramData, $env:APPDATA, $env:LOCALAPPDATA, $env:TEMP) + @($OneDriveRotter))) {
    $n = Normalisera $s
    if ($n) { $Skyddade.Add($n) }
}
foreach ($bas in @(@($Hem) + @($OneDriveRotter))) {
    if (-not $bas) { continue }
    foreach ($namn in @('Desktop', 'Skrivbord', 'Documents', 'Dokument', 'Downloads', 'Hämtade filer', 'Music', 'Musik', 'Pictures', 'Bilder', 'Videos', 'Videor', 'Filmer', 'source', 'repos', 'Projects', 'Projekt')) {
        $Skyddade.Add((Join-Path $bas $namn))
    }
}
foreach ($namn in @('MyDocuments', 'Desktop', 'MyMusic', 'MyVideos', 'MyPictures')) {
    $n = Normalisera (Specialmapp $namn $namn)
    if ($n) { $Skyddade.Add($n) }
}
# Hämtade filer (Downloads) kan vara flyttad, t.ex. till E:\download. Den skyddas också.
if ($PaWindows -and (Ar-Samma $Hem $env:USERPROFILE)) {
    try {
        $nyckel = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
        $varde = (Get-ItemProperty -Path $nyckel -ErrorAction Stop).'{374DE290-123F-4565-9164-39C4925E467B}'
        $n = Normalisera ([System.Environment]::ExpandEnvironmentVariables([string]$varde))
        if ($n) { $Skyddade.Add($n) }
    } catch { }
}
$SystemMappar = @($env:SystemRoot, $env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:ProgramData, $env:APPDATA, $env:LOCALAPPDATA, $ClaudeMapp) | Where-Object { $_ } | ForEach-Object { Normalisera $_ }

function Far-Flyttas([string]$Sokvag) {
    if (-not $Sokvag -or -not (Test-Path -LiteralPath $Sokvag -PathType Container)) { return $false }
    if (Under-Lank $Sokvag) { return $false }   # redan flyttad (den gamla platsen är en länk)
    if ([System.IO.Path]::GetPathRoot($Sokvag) -eq $Sokvag) { return $false }
    if (Ar-Inuti $Sokvag $Mapp) { return $false }
    foreach ($s in $Skyddade) {
        if (Ar-Samma $Sokvag $s) { return $false }
        if (Ar-Inuti $s $Sokvag) { return $false }   # mappen innehåller en skyddad mapp (t.ex. hela användarmappen)
    }
    foreach ($s in $SystemMappar) { if (Ar-Inuti $Sokvag $s) { return $false } }
    return $true
}

# Om mappen ligger inuti ett git-repo flyttas hela repot, inte bara undermappen.
# Sökningen börjar bara i en mapp som finns och går aldrig upp till en skyddad mapp eller en enhetsrot.
function Hitta-Gitrot([string]$Sokvag) {
    if (-not $Sokvag -or -not (Test-Path -LiteralPath $Sokvag -PathType Container)) { return $Sokvag }
    $d = $Sokvag
    while ($d) {
        if (Test-Path -LiteralPath (Join-Path $d '.git')) { return $d }
        $foralder = Split-Path -Parent $d
        if (-not $foralder -or (Ar-Samma $foralder $d)) { break }
        if (Ar-Samma ([System.IO.Path]::GetPathRoot($foralder)) $foralder) { break }
        foreach ($s in $Skyddade) { if (Ar-Samma $foralder $s) { return $Sokvag } }
        $d = $foralder
    }
    return $Sokvag
}

# Mappar på andra diskar som redan har en länk i samlingsmappen (från en tidigare körning).
$RedanLankade = @{}
foreach ($rot in @($ProjektRot, $ArkivRot)) {
    if (-not (Test-Path -LiteralPath $rot)) { continue }
    foreach ($d in @(Get-ChildItem -LiteralPath $rot -Directory -Force -ErrorAction SilentlyContinue)) {
        foreach ($objekt in @(@($d) + @(Get-ChildItem -LiteralPath $d.FullName -Directory -Force -ErrorAction SilentlyContinue))) {
            if (-not (Ar-Lank $objekt.FullName)) { continue }
            foreach ($t in @($objekt.Target)) {
                $n = Normalisera ([string]$t)
                if ($n) { $RedanLankade[$n.ToLowerInvariant()] = $true }
            }
        }
    }
}

# En mapp som själv inte är ett repo men innehåller flera repon (t.ex. Dokument\GitHub) är ingen
# projektmapp. Repona i den hittas och flyttas var för sig.
function Ar-Samlingsmapp([string]$Sokvag) {
    if (Test-Path -LiteralPath (Join-Path $Sokvag '.git')) { return $false }
    $repon = @(Get-ChildItem -LiteralPath $Sokvag -Directory -Recurse -Depth 2 -Force -Filter '.git' -ErrorAction SilentlyContinue)
    return ($repon.Count -ge 2)
}

$Kandidater = @{}   # sökväg -> objekt
function Lagg-Till-Kandidat([string]$Sokvag, [string]$Kalltyp, [string]$Projektnamn) {
    try { Lagg-Till-Kandidat-Inre $Sokvag $Kalltyp $Projektnamn }
    catch { Skriv-Info "Hoppar över $Sokvag ($($_.Exception.Message))." }
}
function Lagg-Till-Kandidat-Inre([string]$Sokvag, [string]$Kalltyp, [string]$Projektnamn) {
    $n = Normalisera $Sokvag
    if (-not $n -or -not (Test-Path -LiteralPath $n -PathType Container)) { return }
    if (-not $n) { return }
    $n = Hitta-Gitrot $n
    $nyckel = $n.ToLowerInvariant()
    if ($Kandidater.ContainsKey($nyckel)) {
        $k = $Kandidater[$nyckel]
        if ($k.Kallor -notcontains $Kalltyp) { $k.Kallor += $Kalltyp }
        if ($Projektnamn -and -not $k.Projekt) { $k.Projekt = $Projektnamn }
        return
    }
    if (-not (Far-Flyttas $n)) { return }
    if ($RedanLankade.ContainsKey($nyckel)) { return }
    if (Ar-Samlingsmapp $n) { return }
    $Kandidater[$nyckel] = [pscustomobject]@{ Sokvag = $n; Kallor = @($Kalltyp); Projekt = $Projektnamn }
}

# 2a. Kända platser från tidigare sessioner
foreach ($p in $Projektlista) {
    foreach ($plats in @($p.kanda_platser)) {
        if ($plats) { Lagg-Till-Kandidat (Expandera $plats) 'känd plats' $p.namn }
    }
}

# 2b. Mappar där Claude Code har arbetat
$SessionsMappar = @{}   # gammal cwd (lowercase) -> lista med sessionsmappar
if (Test-Path -LiteralPath $ClaudeProjekt) {
    foreach ($d in @(Get-ChildItem -LiteralPath $ClaudeProjekt -Directory -Force -ErrorAction SilentlyContinue)) {
        $filer = @(Get-ChildItem -LiteralPath $d.FullName -Filter '*.jsonl' -File -Force -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending)
        if ($filer.Count -eq 0) { continue }
        $cwd = $null
        foreach ($f in $filer) { $cwd = Las-Cwd $f.FullName; if ($cwd) { break } }
        if (-not $cwd) { continue }
        $cwdN = Normalisera $cwd
        if (-not $cwdN) { continue }
        $nyckel = $cwdN.ToLowerInvariant()
        if (-not $SessionsMappar.ContainsKey($nyckel)) { $SessionsMappar[$nyckel] = @() }
        $SessionsMappar[$nyckel] += [pscustomobject]@{ Cwd = $cwdN; Mapp = $d.FullName }
        Lagg-Till-Kandidat $cwdN 'Claude-session' $null
    }
}

# 2c. Git-repon som hör till Donkey229 på GitHub
$RepoTillProjekt = @{}
foreach ($p in $Projektlista) {
    if ($p.repo) {
        $kort = ($p.repo -replace '\.git$', '').TrimEnd('/').Split('/')[-1].ToLowerInvariant()
        $RepoTillProjekt[$kort] = $p.namn
    }
}
$SokRotter = New-Object System.Collections.Generic.List[string]
foreach ($bas in @(@($Hem) + @($OneDriveRotter))) {
    if (-not $bas) { continue }
    foreach ($namn in @('Desktop', 'Skrivbord', 'Documents', 'Dokument', 'source', 'repos', 'Projects', 'Projekt', 'GitHub')) {
        $r = Join-Path $bas $namn
        if (Test-Path -LiteralPath $r) { $SokRotter.Add($r) }
    }
}
foreach ($r in @((Specialmapp 'MyDocuments' 'Documents'), (Specialmapp 'Desktop' 'Desktop'))) {
    if ((Test-Path -LiteralPath $r) -and -not ($SokRotter -contains $r)) { $SokRotter.Add($r) }
}
$GitTraffar = New-Object System.Collections.Generic.List[string]
$RepoPaDatorn = @{}   # reponamn -> mapp där det redan finns på datorn
foreach ($rot in $SokRotter) {
    foreach ($g in @(Get-ChildItem -LiteralPath $rot -Directory -Recurse -Depth 3 -Force -Filter '.git' -ErrorAction SilentlyContinue)) { $GitTraffar.Add($g.FullName) }
}
foreach ($g in @(Get-ChildItem -LiteralPath $Hem -Directory -Force -ErrorAction SilentlyContinue)) {
    $gd = Join-Path $g.FullName '.git'
    if (Test-Path -LiteralPath $gd -PathType Container) { $GitTraffar.Add($gd) }
}
foreach ($gd in $GitTraffar) {
    $config = Join-Path $gd 'config'
    if (-not (Test-Path -LiteralPath $config)) { continue }
    $text = ''
    try { $text = Las-Text $config } catch { continue }
    $m = [regex]::Match($text, 'url\s*=\s*\S*github\.com[:/]+Donkey229/([^\s/]+?)(\.git)?\s*$', 'IgnoreCase, Multiline')
    if ($m.Success) {
        $repoNamn = $m.Groups[1].Value.ToLowerInvariant()
        $projektNamn = $null
        if ($RepoTillProjekt.ContainsKey($repoNamn)) { $projektNamn = $RepoTillProjekt[$repoNamn] }
        $RepoPaDatorn[$repoNamn] = (Split-Path -Parent $gd)
        Lagg-Till-Kandidat (Split-Path -Parent $gd) "git-repo Donkey229/$repoNamn" $projektNamn
    }
}

# ---------------------------------------------------------------------------
# 3. Flytta projektmappar
# ---------------------------------------------------------------------------
Skriv-Rubrik '3. Flyttar projektmappar till C:\Donkeystories\projekt'

$Flyttade = New-Object System.Collections.Generic.List[object]   # Fran, Till
$ArkivNamn = @{}
foreach ($p in $Projektlista) { if ($p.arkiv) { $ArkivNamn[$p.namn.ToLowerInvariant()] = $true } }
function Ny-Plats([string]$Gammal) {
    foreach ($f in $Flyttade) {
        if (Ar-Inuti $Gammal $f.Fran) { return $f.Till + $Gammal.Substring($f.Fran.Length) }
    }
    return $null
}

# Undermappar till en annan kandidat flyttas aldrig för sig – de följer med sin överordnade mapp.
$AllaKandidater = @($Kandidater.Values | Sort-Object { $_.Sokvag.Length })
$Sorterade = @($AllaKandidater | Where-Object {
    $barn = $_
    -not ($AllaKandidater | Where-Object { $_ -ne $barn -and (Ar-Inuti $barn.Sokvag $_.Sokvag) })
})

# Flyttar (eller länkar) en kandidat. Returnerar 'ok', 'hoppad', 'upptagen' eller 'fel'.
function Hantera-Kandidat($k, [bool]$RedanGodkand) {
    if (-not (Test-Path -LiteralPath $k.Sokvag)) { return 'hoppad' }
    $namn = if ($k.Projekt) { $k.Projekt } else { Split-Path -Leaf $k.Sokvag }
    $malRot = $ProjektRot
    if ($k.Projekt -and $ArkivNamn.ContainsKey($k.Projekt.ToLowerInvariant())) { $malRot = $ArkivRot }
    $mal = Join-Path $malRot $namn
    $nr = 2
    $fortsatter = $false
    while ((Test-Path -LiteralPath $mal) -and @(Get-ChildItem -LiteralPath $mal -Force -ErrorAction SilentlyContinue).Count -gt 0) {
        # En avbruten flytt av just den här mappen fortsätter i samma målmapp.
        $markor = Join-Path $mal $FlyttMarkor
        if ((Test-Path -LiteralPath $markor) -and (Ar-Samma (Las-Text $markor).Trim() $k.Sokvag)) { $fortsatter = $true; break }
        # En mapp med bara vår CLAUDE.md (från en tidigare körning) räknas inte som upptagen.
        $ovrigt = @(Get-ChildItem -LiteralPath $mal -Force) | Where-Object { $_.Name -ne 'CLAUDE.md' }
        if (@($ovrigt).Count -eq 0 -and -not (Ar-Lank $mal)) { break }
        $mal = Join-Path $malRot "$namn-$nr"; $nr++
    }
    $iOneDrive = I-OneDrive $k.Sokvag
    $annanDisk = -not (Ar-Samma ([System.IO.Path]::GetPathRoot($k.Sokvag)) ([System.IO.Path]::GetPathRoot($Mapp)))
    if (-not $RedanGodkand) {
        Write-Host ''
        Skriv-Info "$($k.Sokvag)  –  $(Beskriv-Storlek $k.Sokvag)"
    }
    if ($annanDisk) {
        # Filerna ligger kvar och skrivs aldrig till. Projektmappen i C:\Donkeystories blir en vanlig
        # mapp (för CLAUDE.md) med en länk inuti som pekar till den andra disken.
        $lank = Join-Path $mal (Split-Path -Leaf $k.Sokvag)
        # Bara kända projekt (t.ex. E:\Musik) föreslås. Andra mappar på andra diskar kan vara privata.
        $kand = $k.Kallor -contains 'känd plats'
        if (-not (Fraga "Ligger på en annan disk. Lägga en länk till den i $lank (filerna ligger kvar där de är)?" $kand)) { return 'hoppad' }
        Skapa-Mapp $mal
        if (-not (Skapa-Lank $lank $k.Sokvag)) { return 'fel' }
        $Flyttade.Add([pscustomobject]@{ Fran = $k.Sokvag; Till = $lank; Projektmapp = $mal })
        Skriv-Klart "Länkade $lank -> $($k.Sokvag)"
        return 'ok'
    }
    if (-not $RedanGodkand) {
        if ($iOneDrive) { Skriv-Info 'Mappen ligger i OneDrive. Efter flytten säkerhetskopieras den inte längre av OneDrive.' }
        if ($fortsatter) { Skriv-Info "En tidigare flytt hit avbröts. Den fortsätter nu i $mal." }
        if (-not (Fraga "Flytta till $mal ?" $true)) { return 'hoppad' }
    }
    # Finns bara vår CLAUDE.md från en tidigare körning i målmappen sparas den och läggs tillbaka efter flytten.
    $sparadClaude = $null
    if (-not $fortsatter) {
        try { $sparadClaude = Ta-Undan-Claude $mal } catch { Skriv-Varning "$($_.Exception.Message) Hoppar över $($k.Sokvag)."; return 'fel' }
    }
    $status = Flytta-Mapp $k.Sokvag $mal
    if ($status -eq 'ok') {
        $Flyttade.Add([pscustomobject]@{ Fran = $k.Sokvag; Till = $mal; Projektmapp = $mal })
        Skriv-Klart "Flyttade $($k.Sokvag) -> $mal"
        if (-not (Test-Path -LiteralPath $k.Sokvag)) {
            if ($iOneDrive) {
                Skapa-Genvag "$($k.Sokvag).lnk" $mal
            } elseif (Skapa-Lank $k.Sokvag $mal) {
                Skriv-Info "Den gamla platsen $($k.Sokvag) pekar nu till $mal"
            }
        }
    }
    Aterstall-Claude $mal $sparadClaude
    return $status
}

if ($Sorterade.Count -eq 0) {
    Skriv-Info 'Hittade inga projektmappar utanför C:\Donkeystories.'
} else {
    Skriv-Info "Hittade $($Sorterade.Count) möjliga projektmappar:"
    $i = 0
    foreach ($k in $Sorterade) {
        $i++
        $etikett = if ($k.Projekt) { " -> projekt\$($k.Projekt)" } else { '' }
        Skriv-Info ("  {0,2}. {1}{2}   ({3})" -f $i, $k.Sokvag, $etikett, ($k.Kallor -join ', '))
    }
    Write-Host ''
    Skriv-Info 'Samma disk som C:\Donkeystories: mappen flyttas, och en länk lämnas på den gamla platsen så att'
    Skriv-Info 'genvägar, schemalagda uppgifter och program (t.ex. Donkey Cowork) fortsätter hitta den.'
    Skriv-Info 'OneDrive: mappen flyttas ut ur OneDrive, och en genväg lämnas där den låg.'
    Skriv-Info 'Annan disk (t.ex. E:): filerna ligger kvar där. En länk läggs i C:\Donkeystories\projekt.'
    $KanFlytta = $true
    if (-not $Provkorning) { $KanFlytta = Stang-Program-Som-Laser }
    if (-not $KanFlytta) {
        Skriv-Varning 'Claude körs fortfarande, så inga mappar flyttades. Avsluta Claude helt och kör skriptet igen.'
    } else {
        $Upptagna = New-Object System.Collections.Generic.List[object]
        foreach ($k in $Sorterade) {
            if ((Hantera-Kandidat $k $false) -eq 'upptagen') { $Upptagna.Add($k) }
        }
        if ($Upptagna.Count -gt 0) {
            Write-Host ''
            Skriv-Info "$($Upptagna.Count) mappar används just nu av ett program och kunde inte flyttas."
            $python = @(Python-Program)
            if ($python.Count -gt 0 -and (Fraga "$($python.Count) Python-program körs (troligen lokala Donkey-servrar som Cowork, God Mode och Lyrics). Stänga dem och försöka igen? (starta dem sedan med genvägarna)" (-not $Ja))) {
                foreach ($pr in $python) { try { Stop-Process -Id $pr.Id -Force -ErrorAction Stop } catch { } }
                Start-Sleep -Seconds 2
                Skriv-Klart 'Stängde lokala Python-servrar. Starta dem igen med genvägarna när skriptet är klart.'
                $kvarUpptagna = New-Object System.Collections.Generic.List[object]
                foreach ($k in $Upptagna) {
                    if ((Hantera-Kandidat $k $true) -eq 'upptagen') { $kvarUpptagna.Add($k) }
                }
                $Upptagna = $kvarUpptagna
            }
            foreach ($k in $Upptagna) {
                Skriv-Varning "Kunde inte flytta $($k.Sokvag): mappen används av ett program (t.ex. Cubase, VEGAS, Utforskaren eller en server). Stäng det och kör skriptet igen."
            }
        }
    }
}

# ---------------------------------------------------------------------------
# 4. Hämta GitHub-repon som saknas
# ---------------------------------------------------------------------------
Skriv-Rubrik '4. Hämtar GitHub-repon som inte finns på datorn'
$Git = Get-Command git -ErrorAction SilentlyContinue
if (-not $Git) {
    Skriv-Varning 'Git är inte installerat, så repon kan inte hämtas. Installera Git (https://git-scm.com) och kör skriptet igen.'
} else {
    # Repon som redan finns någonstans i samlingsmappen (t.ex. inuti en flyttad mapp) klonas inte igen.
    $FinnsRedan = @{}
    foreach ($rot in @($ProjektRot, $ArkivRot)) {
        if (-not (Test-Path -LiteralPath $rot)) { continue }
        foreach ($g in @(Get-ChildItem -LiteralPath $rot -Directory -Recurse -Depth 3 -Force -Filter '.git' -ErrorAction SilentlyContinue)) {
            $config = Join-Path $g.FullName 'config'
            if (-not (Test-Path -LiteralPath $config)) { continue }
            $m = [regex]::Match((Las-Text $config), 'url\s*=\s*\S*github\.com[:/]+Donkey229/([^\s/]+?)(\.git)?\s*$', 'IgnoreCase, Multiline')
            if ($m.Success) { $FinnsRedan[$m.Groups[1].Value.ToLowerInvariant()] = (Split-Path -Parent $g.FullName) }
        }
    }
    $hamtaArkiv = $null
    foreach ($p in $Projektlista) {
        if (-not $p.repo) { continue }
        $kort = ($p.repo -replace '\.git$', '').TrimEnd('/').Split('/')[-1].ToLowerInvariant()
        if ($FinnsRedan.ContainsKey($kort)) { Skriv-Info "$($p.namn) finns redan ($($FinnsRedan[$kort]))."; continue }
        if ($RepoPaDatorn.ContainsKey($kort) -and (Test-Path -LiteralPath $RepoPaDatorn[$kort]) -and -not (Ar-Inuti $RepoPaDatorn[$kort] $Mapp)) {
            Skriv-Info "$($p.namn) finns redan på datorn ($($RepoPaDatorn[$kort])) och hämtas inte en gång till."
            continue
        }
        $rot = if ($p.arkiv) { $ArkivRot } else { $ProjektRot }
        $mal = Join-Path $rot $p.namn
        if (Test-Path -LiteralPath (Join-Path $mal '.git')) { Skriv-Info "$($p.namn) finns redan ($mal)."; continue }
        if ((Test-Path -LiteralPath $mal) -and @(Get-ChildItem -LiteralPath $mal -Force | Where-Object { $_.Name -ne 'CLAUDE.md' }).Count -gt 0) {
            Skriv-Varning "$mal finns redan men är inget git-repo – hoppar över kloning av $($p.repo)."
            continue
        }
        if ($p.arkiv) {
            if ($null -eq $hamtaArkiv) { $hamtaArkiv = Fraga 'Vill du även hämta de gamla, arkiverade repona till arkiv\?' $false }
            if (-not $hamtaArkiv) { continue }
        } elseif (-not (Fraga "Hämta $($p.repo) till ${mal}?" $true)) { continue }
        if ($Provkorning) { Skriv-Prov "skulle köra: git clone $($p.repo) $mal"; continue }
        try { $sparadClaude = Ta-Undan-Claude $mal } catch { Skriv-Varning "$($_.Exception.Message) Hoppar över $($p.repo)."; continue }
        & git clone --quiet $p.repo $mal
        if ($LASTEXITCODE -eq 0) {
            Skriv-Klart "Hämtade $($p.repo) -> $mal"
        } else {
            Skriv-Varning "Kunde inte hämta $($p.repo) (är du inloggad på GitHub i Git?)."
        }
        Aterstall-Claude $mal $sparadClaude
    }
}

# ---------------------------------------------------------------------------
# 5. CLAUDE.md, PROJEKT.md och sessionsloggar
# ---------------------------------------------------------------------------
Skriv-Rubrik '5. Skriver CLAUDE.md, PROJEKT.md och sessionsloggar'

# 5a. Filer i samlingsmappen (skrivs bara om de saknas – Claude uppdaterar dem sedan själv)
$MallFiler = @(Get-ChildItem -LiteralPath $MallMapp -Recurse -File -Force)
foreach ($f in $MallFiler) {
    $relativ = $f.FullName.Substring($MallMapp.Length).TrimStart('\', '/')
    # Projektmallarna (mall\projekt\...) och det globala blocket hanteras längre ner.
    if ($relativ -match '^projekt[\\/]' -or $relativ -eq 'global-CLAUDE.md') { continue }
    # Mallen heter gitignore-mall i repot (annars skulle den gälla för repot självt).
    if ($relativ -eq 'gitignore-mall') { $relativ = '.gitignore' }
    $mal = Join-Path $Mapp $relativ
    if (Test-Path -LiteralPath $mal) { Skriv-Info "Finns redan, rör inte: $mal"; continue }
    Skriv-Text $mal (Anpassa-Mall (Las-Text $f.FullName))
}
Skriv-Klart 'CLAUDE.md, PROJEKT.md, anteckningar och sessionsloggar finns i samlingsmappen'

# 5b. CLAUDE.md i varje projekt som finns på den här datorn.
#     Saknar projektet CLAUDE.md skrivs hela projektbeskrivningen. Har det redan en egen
#     (t.ex. Donkey Studio, Cowork, Film) läggs bara en kort hänvisning till sist, så att
#     projektets egna regler inte krockar eller dubbleras.
$Projektmallar = Join-Path $MallMapp 'projekt'
$Generell = Las-Text (Join-Path (Join-Path $Projektmallar '_ny') 'CLAUDE.md')
$Pekare = Las-Text (Join-Path (Join-Path $Projektmallar '_pekare') 'CLAUDE.md')

function Skriv-Projekt-Claude([string]$ProjektMapp, [string]$Namn, [string]$FullText) {
    $fil = Join-Path $ProjektMapp 'CLAUDE.md'
    if (-not (Test-Path -LiteralPath $fil)) {
        [void](Uppdatera-Block $fil $FullText $false)
        Skriv-Klart "CLAUDE.md för $Namn"
        # Håll anteckningarna lokala: lägg CLAUDE.md i .git/info/exclude så att den inte råkar publiceras.
        $gitMapp = Join-Path $ProjektMapp '.git'
        if ((Test-Path -LiteralPath $gitMapp -PathType Container) -and -not $Provkorning) {
            $exclude = Join-Path (Join-Path $gitMapp 'info') 'exclude'
            $ex = if (Test-Path -LiteralPath $exclude) { Las-Text $exclude } else { '' }
            if ($ex -notmatch '(?m)^/?CLAUDE\.md\s*$') {
                Skriv-Text $exclude ($ex.TrimEnd() + "`n# Donkeystories: lokala Claude-anteckningar ska inte publiceras`n/CLAUDE.md`n")
            }
        }
        return
    }
    $kort = (Anpassa-Mall $Pekare).Replace('{{NAMN}}', $Namn)
    if (Uppdatera-Block $fil $kort $false) { Skriv-Klart "Hänvisning till C:\Donkeystories i projektets egen CLAUDE.md ($Namn)" }
}

$KandaNamn = @{}
foreach ($p in $Projektlista) {
    $KandaNamn[$p.namn.ToLowerInvariant()] = $true
    $rot = if ($p.arkiv) { $ArkivRot } else { $ProjektRot }
    $projektMapp = Join-Path $rot $p.namn
    if (-not (Test-Path -LiteralPath $projektMapp)) { continue }   # projektet finns inte på den här datorn
    $mallFil = Join-Path (Join-Path $Projektmallar $p.namn) 'CLAUDE.md'
    if (Test-Path -LiteralPath $mallFil) {
        $full = Anpassa-Mall (Las-Text $mallFil)
    } else {
        $full = (Anpassa-Mall $Generell).Replace('{{NAMN}}', $p.namn).Replace('{{GAMMAL_PLATS}}', '–').Replace('{{DATUM}}', $Idag)
    }
    Skriv-Projekt-Claude $projektMapp $p.namn $full
}

# 5c. Projekt som hittades men inte fanns i listan får en enkel CLAUDE.md och en rad i PROJEKT.md
$NyaRader = New-Object System.Collections.Generic.List[string]
foreach ($f in $Flyttade) {
    $namn = Split-Path -Leaf $f.Projektmapp
    if ($KandaNamn.ContainsKey($namn.ToLowerInvariant())) { continue }
    if (-not (Test-Path -LiteralPath $f.Projektmapp)) { continue }
    $text = (Anpassa-Mall $Generell).Replace('{{NAMN}}', $namn).Replace('{{GAMMAL_PLATS}}', $f.Fran).Replace('{{DATUM}}', $Idag)
    Skriv-Projekt-Claude $f.Projektmapp $namn $text
    $relativ = $f.Projektmapp.Substring($Mapp.Length).TrimStart('\', '/')
    $NyaRader.Add("| $namn | ``$relativ`` | – | – | Flyttad hit $Idag från ``$($f.Fran)``. Fyll i beskrivning. |")
}
if ($NyaRader.Count -gt 0) {
    $projektFil = Join-Path $Mapp 'PROJEKT.md'
    if (Test-Path -LiteralPath $projektFil) {
        $text = Las-Text $projektFil
        $tillagg = "`n## Hittade på datorn vid installationen $Idag`n`n| Projekt | Mapp | GitHub | Live | Anteckning |`n|---|---|---|---|---|`n" + ($NyaRader -join "`n") + "`n"
        Sakerhetskopiera $projektFil
        Skriv-Text $projektFil ($text.TrimEnd() + "`n" + $tillagg)
    }
}

# ---------------------------------------------------------------------------
# 6. Sessionshistorik
# ---------------------------------------------------------------------------
Skriv-Rubrik '6. Flyttar med sessionshistoriken'

# 6a. Kopiera sessioner för flyttade projekt så att de går att återuppta från den nya platsen.
foreach ($nyckel in @($SessionsMappar.Keys)) {
    foreach ($s in $SessionsMappar[$nyckel]) {
        $ny = Ny-Plats $s.Cwd
        if (-not $ny) { continue }
        $kodad = Koda-Projektmapp $ny
        if (-not $kodad) { continue }
        $malMapp = Join-Path $ClaudeProjekt $kodad
        if (Ar-Samma $malMapp $s.Mapp) { continue }
        if ($Provkorning) { Skriv-Prov "skulle kopiera sessioner $($s.Mapp) -> $malMapp"; continue }
        Skapa-Mapp $malMapp
        foreach ($objekt in @(Get-ChildItem -LiteralPath $s.Mapp -Force)) {
            $malObjekt = Join-Path $malMapp $objekt.Name
            if (-not (Test-Path -LiteralPath $malObjekt)) { Copy-Item -LiteralPath $objekt.FullName -Destination $malObjekt -Recurse -Force }
        }
        Skriv-Klart "Sessioner från $($s.Cwd) går nu att återuppta i $ny (originalen finns kvar)"
    }
}

# 6b. Flytta hela historikmappen till C:\Donkeystories och lämna en länk (junction) på gamla platsen.
$arLank = $false
if (Test-Path -LiteralPath $ClaudeProjekt) {
    $arLank = Ar-Lank $ClaudeProjekt
}
if ($arLank) {
    Skriv-Info "$ClaudeProjekt pekar redan till en annan plats – inget att göra."
} elseif (-not $PaWindows) {
    Skriv-Info 'Hoppar över länken för sessionshistoriken (fungerar bara på Windows).'
} elseif (Fraga "Spara alla Claude Code-chattar i $HistorikMapp från och med nu? (historiken flyttas dit och en länk lämnas kvar)" $true) {
    if ($Provkorning) {
        Skriv-Prov "skulle flytta $ClaudeProjekt -> $HistorikMapp och skapa en länk"
    } elseif (Vanta-Pa-Stangd-Claude 'Historiken kan inte flyttas medan Claude skriver i den.') {
        $flyttadHela = $false
        try {
            Skapa-Mapp (Split-Path -Parent (Split-Path -Parent $HistorikMapp))
            Skapa-Mapp (Split-Path -Parent $HistorikMapp)
            if (-not (Test-Path -LiteralPath $ClaudeProjekt)) {
                Skapa-Mapp $HistorikMapp
            } elseif (-not (Test-Path -LiteralPath $HistorikMapp) -and (Ar-Samma ([System.IO.Path]::GetPathRoot($ClaudeProjekt)) ([System.IO.Path]::GetPathRoot($HistorikMapp)))) {
                # Vanligaste fallet: ett namnbyte på samma disk.
                Move-Item -LiteralPath $ClaudeProjekt -Destination $HistorikMapp
                $flyttadHela = $true
            } else {
                # Historikmappen finns redan (en tidigare körning) eller ligger på en annan disk:
                # flytta fil för fil. Finns en fil redan med annat innehåll sparas den nya med ett eget namn.
                Skapa-Mapp $HistorikMapp
                foreach ($fil in @(Get-ChildItem -LiteralPath $ClaudeProjekt -Recurse -Force -File -ErrorAction Stop)) {
                    $relativ = $fil.FullName.Substring($ClaudeProjekt.Length).TrimStart('\', '/')
                    $malFil = Join-Path $HistorikMapp $relativ
                    $malMapp = Split-Path -Parent $malFil
                    if (-not (Test-Path -LiteralPath $malMapp)) { New-Item -ItemType Directory -Path $malMapp -Force | Out-Null }
                    if (Test-Path -LiteralPath $malFil) {
                        $samma = ((Get-Item -LiteralPath $malFil -Force).Length -eq $fil.Length) -and ((Get-FileHash -LiteralPath $malFil).Hash -eq (Get-FileHash -LiteralPath $fil.FullName).Hash)
                        if (-not $samma) { $malFil = "$malFil.fran-$Tidsstampel" }
                        else { Remove-Item -LiteralPath $fil.FullName -Force; continue }
                    }
                    Move-Item -LiteralPath $fil.FullName -Destination $malFil
                }
                $kvar = @(Get-ChildItem -LiteralPath $ClaudeProjekt -Recurse -Force -File -ErrorAction SilentlyContinue).Count
                if ($kvar -gt 0) { throw "$kvar filer finns kvar i $ClaudeProjekt" }
                # Ta bort de nu tomma mapparna, djupast först, utan att följa länkar.
                foreach ($d in @(Get-ChildItem -LiteralPath $ClaudeProjekt -Recurse -Force -Directory -ErrorAction SilentlyContinue | Sort-Object { $_.FullName.Length } -Descending)) {
                    [System.IO.Directory]::Delete($d.FullName, $false)
                }
                [System.IO.Directory]::Delete($ClaudeProjekt, $false)
            }
            if (-not (Skapa-Lank $ClaudeProjekt $HistorikMapp)) {
                # Kunde länken inte skapas läggs historiken tillbaka direkt, så att Claude hittar den som förut.
                if ($flyttadHela -and -not (Test-Path -LiteralPath $ClaudeProjekt)) { Move-Item -LiteralPath $HistorikMapp -Destination $ClaudeProjekt }
                throw 'länken till historiken kunde inte skapas'
            }
            Skriv-Klart "Alla Claude Code-chattar sparas nu i $HistorikMapp"
        } catch {
            Skriv-Varning "Kunde inte flytta sessionshistoriken: $($_.Exception.Message). Inget är förlorat – kör skriptet igen när Claude är stängt."
        }
    } else {
        Skriv-Varning 'Hoppade över flytten av sessionshistoriken. Kör skriptet igen när Claude är stängt.'
    }
}

# ---------------------------------------------------------------------------
# 7. Claude Code-inställningar
# ---------------------------------------------------------------------------
Skriv-Rubrik '7. Ställer in Claude Code'
Skapa-Mapp $ClaudeMapp

# 7a. Global CLAUDE.md: Claude ska alltid läsa C:\Donkeystories först.
$globalFil = Join-Path $ClaudeMapp 'CLAUDE.md'
$globalBlock = Anpassa-Mall (Las-Text (Join-Path $MallMapp 'global-CLAUDE.md'))
if (Uppdatera-Block $globalFil $globalBlock $true) {
    Skriv-Klart "Claude läser nu $Mapp först i varje session ($globalFil)"
} else {
    Skriv-Info "$globalFil är redan uppdaterad."
}

# 7b. settings.json: spara chattar längre och ge Claude tillgång till C:\Donkeystories.
$installningar = Join-Path $ClaudeMapp 'settings.json'
try {
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        # Windows PowerShell 5.1 skriver annars arrayer som {"value": [...], "Count": n}.
        Remove-TypeData -TypeName System.Array -ErrorAction SilentlyContinue
    }
    $obj = $null
    if (Test-Path -LiteralPath $installningar) {
        $json = Las-Text $installningar
        if ($json.Trim()) { $obj = $json | ConvertFrom-Json }
    }
    if ($null -eq $obj) { $obj = New-Object PSObject }
    $andrad = $false

    # Dokumentationen: standard 30, minst 1 (0 är ogiltigt), 3650 rekommenderas för lång lagring.
    $dagar = 3650
    $finns = $obj.PSObject.Properties['cleanupPeriodDays']
    if (-not $finns) {
        $obj | Add-Member -NotePropertyName 'cleanupPeriodDays' -NotePropertyValue $dagar; $andrad = $true
    } elseif ([int]$finns.Value -lt $dagar) {
        $obj.cleanupPeriodDays = $dagar; $andrad = $true
    }

    if (-not $obj.PSObject.Properties['permissions']) {
        $obj | Add-Member -NotePropertyName 'permissions' -NotePropertyValue (New-Object PSObject); $andrad = $true
    }
    $perm = $obj.permissions
    $kataloger = @()
    if ($perm.PSObject.Properties['additionalDirectories']) { $kataloger = @($perm.additionalDirectories) }
    $harMapp = $false
    foreach ($k in $kataloger) { if (Ar-Samma ([string]$k).TrimEnd('\', '/').Replace('/', '\') $Mapp.Replace('/', '\')) { $harMapp = $true } }
    if (-not $harMapp) {
        $nyLista = [object[]]($kataloger + @($Mapp))
        if ($perm.PSObject.Properties['additionalDirectories']) { $perm.additionalDirectories = $nyLista }
        else { $perm | Add-Member -NotePropertyName 'additionalDirectories' -NotePropertyValue $nyLista }
        $andrad = $true
    }

    if ($andrad) {
        Sakerhetskopiera $installningar
        Skriv-Text $installningar ($obj | ConvertTo-Json -Depth 32)
        Skriv-Klart "Claude Code sparar chattar i 10 år och får läsa och arbeta i $Mapp från alla projekt ($installningar)"
    } else {
        Skriv-Info "$installningar är redan inställd."
    }
} catch {
    Skriv-Varning "Kunde inte uppdatera $installningar ($($_.Exception.Message)). Lägg till ""cleanupPeriodDays"": 3650 och ""permissions"": { ""additionalDirectories"": [""$($Mapp.Replace('\', '\\'))""] } för hand."
}

# ---------------------------------------------------------------------------
# 8. Spara installationsfilerna i verktyg\ så att skriptet kan köras igen
# ---------------------------------------------------------------------------
$verktyg = Join-Path (Join-Path $Mapp 'verktyg') 'installation'
if (-not (Ar-Inuti $Kalla $verktyg)) {
    if ($Provkorning) {
        Skriv-Prov "skulle kopiera installationsfilerna till $verktyg"
    } else {
        if (Test-Path -LiteralPath $verktyg) {
            # Den gamla kopian (som kan vara ändrad, t.ex. projekt.json) sparas innan den ersätts.
            $gammal = Join-Path (Join-Path (Join-Path $Mapp 'verktyg') 'sakerhetskopior') (Join-Path $Tidsstampel 'installation')
            New-Item -ItemType Directory -Path (Split-Path -Parent $gammal) -Force | Out-Null
            Copy-Item -LiteralPath $verktyg -Destination $gammal -Recurse -Force
        }
        Skapa-Mapp $verktyg
        foreach ($namn in @('installera.ps1', 'installera.cmd', 'projekt.json', 'README.md', 'mall')) {
            $kallFil = Join-Path $Kalla $namn
            if (Test-Path -LiteralPath $kallFil) { Copy-Item -LiteralPath $kallFil -Destination $verktyg -Recurse -Force }
        }
        Skriv-Klart "Installationsfilerna sparades i $verktyg"
    }
}

} catch {
    Skriv-Varning "Skriptet stoppade oväntat: $($_.Exception.Message) (rad $($_.InvocationInfo.ScriptLineNumber)). Inget är raderat. Det som redan gjorts ligger kvar, och det går bra att köra skriptet igen."
} finally {
    # -----------------------------------------------------------------------
    # Sammanfattning
    # -----------------------------------------------------------------------
    Skriv-Rubrik 'Klart!'
    if ($Provkorning) { Skriv-Info 'Det här var en provkörning. Kör utan -Provkorning för att göra ändringarna.' }
    foreach ($rad in $Sammanfattning) { Write-Host "  - $rad" -ForegroundColor Green }
    if ($Varningar.Count -gt 0) {
        Write-Host ''
        Write-Host '  Att titta på:' -ForegroundColor Yellow
        foreach ($rad in $Varningar) { Write-Host "  - $rad" -ForegroundColor Yellow }
    }
    Write-Host ''
    Skriv-Info "Öppna $Mapp och starta Claude där (eller i en projektmapp). Claude läser CLAUDE.md och PROJEKT.md först."
    if ($Transkript) { try { Stop-Transcript | Out-Null } catch { } ; Skriv-Info "Logg: $Logg" }
    if ($PaWindows -and -not $Provkorning -and -not $Ja -and (Test-Path -LiteralPath $Mapp)) { Start-Process explorer.exe $Mapp }
}
