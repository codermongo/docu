# CheckPCScript

This script is a comprehensive system diagnosis tool. It can be used to find out detailed information about your system hardware and connectivity.

## Location

[Github[Check1.ps1]](https://github.com/codermongo/docu/blob/main/Scripts/Windows/Check1.ps1)

## Features

The script checks and displays the following information:
*   **CPU:** Processor model and details.
*   **GPU:** Graphics card information and VRAM size.
*   **RAM:** Total installed physical memory and currently free memory.
*   **Storage:** List of local drives (HDD/SSD) with total size and free space.
*   **Network:** Performs a ping check to `google.co.uk` to verify internet connectivity.
*   **Keyboard Tester:** Opens a new window with an interactive keyboard tester to verify key presses.

## The Script

```powershell
<#
.SYNOPSIS
PC Diagnose & Keyboard Tester (V7.0 - Final)
- Fix: Speicher-Anzeige (HDD/SSD) wieder eingebaut und robuster gemacht.
#>

# --- TEIL 1: SYSTEM DIAGNOSE ---

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Clear-Host
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "      SYSTEM DIAGNOSE & STATUS      " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. UPTIME
$os = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
Write-Host "[1] UPTIME:   $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor Yellow

# 2. CPU
$cpu = Get-CimInstance Win32_Processor
Write-Host "[2] CPU:      $($cpu.Name)" -ForegroundColor Yellow

# 3. GPU
Write-Host "[3] GPU & VRAM" -ForegroundColor Yellow
$videoPath = "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
$gpusFound = $false
try {
    $gpuKeys = Get-ChildItem -Path $videoPath -ErrorAction SilentlyContinue
    foreach ($key in $gpuKeys) {
        $props = Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue
        if ($props.DriverDesc -and $props."HardwareInformation.qwMemorySize") {
            $vramGB = [math]::Round($props."HardwareInformation.qwMemorySize" / 1GB, 2)
            if ($vramGB -gt 0.1) {
                Write-Host "    $($props.DriverDesc) | VRAM: $vramGB GB"
                $gpusFound = $true
            }
        }
    }
} catch {}
if (-not $gpusFound) {
    Get-CimInstance Win32_VideoController | ForEach-Object {
        Write-Host "    $($_.Name) | VRAM: $([math]::Round($_.AdapterRAM / 1GB, 2)) GB (WMI)"
    }
}

# 4. RAM
$compSys = Get-CimInstance Win32_ComputerSystem
$totalRam = [math]::Round($compSys.TotalPhysicalMemory / 1GB, 2)
$freeRam = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
Write-Host "[4] RAM:      Gesamt: $totalRam GB | Frei: $freeRam GB" -ForegroundColor Yellow

# 5. SPEICHER
Write-Host "[5] SPEICHER:" -ForegroundColor Yellow
$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" # Typ 3 = Lokale Festplatte
foreach ($disk in $disks) {
    $sizeGB = [math]::Round($disk.Size / 1GB, 2)
    $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    Write-Host "    Laufwerk $($disk.DeviceID) | Gesamt: $sizeGB GB | Frei: $freeGB GB"
}

# 6. NETZWERK
if (Test-Connection "google.co.uk" -Count 1 -Quiet) {
    Write-Host "[6] NETZWERK: Online" -ForegroundColor Green
} else {
    Write-Host "[6] NETZWERK: Offline" -ForegroundColor Red
}

Write-Host "`n[Druecken Sie ENTER fuer den Tastatur-Test...]" -ForegroundColor Cyan
$null = Read-Host

# --- TEIL 2: NEUES FENSTER MIT CODE-LOGIK ---

$scriptBlock = {
    $Host.UI.RawUI.WindowTitle = "Keyboard Tester - V7"
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    $rows = @(
        "1234567890ss",
        "qwertzuiopue+",
        "asdfghjkloeae#",
        "yxcvbnm,.-"
    )

    $pressedKeys = New-Object System.Collections.ArrayList
    $lastPressed = ""

    function Draw-Keyboard {
        Clear-Host
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host "      TASTATUR TEST (ESC = Beenden)      " -ForegroundColor Cyan
        Write-Host "=========================================" -ForegroundColor Cyan
        Write-Host ""

        foreach ($row in $rows) {
            Write-Host "   " -NoNewline
            $tokens = [regex]::Matches($row, 'ae|oe|ue|ss|.') | ForEach-Object { $_.Value }
            foreach ($token in $tokens) {
                if ($pressedKeys.Contains($token)) {
                    Write-Host " $token " -NoNewline -ForegroundColor Black -BackgroundColor Green
                } else {
                    Write-Host " $token " -NoNewline -ForegroundColor Gray
                }
            }
            Write-Host "`n`n"
        }
        Write-Host "-----------------------------------------" -ForegroundColor DarkGray
        Write-Host "Letzte Eingabe: $lastPressed" -ForegroundColor Yellow
    }

    while ($true) {
        Draw-Keyboard

        try {
            $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        } catch { break }

        if ([int]$keyInfo.Character -eq 27) { break }

        $charInt = [int]$keyInfo.Character
        $mappedChar = "$($keyInfo.Character)".ToLower()

        # Mapping über Zahlencodes
        if ($charInt -eq 228 -or $charInt -eq 196) { $mappedChar = "ae" } # ä / Ä
        elseif ($charInt -eq 246 -or $charInt -eq 214) { $mappedChar = "oe" } # ö / Ö
        elseif ($charInt -eq 252 -or $charInt -eq 220) { $mappedChar = "ue" } # ü / Ü
        elseif ($charInt -eq 223) { $mappedChar = "ss" } # ß

        $lastPressed = "$mappedChar"

        if (-not $pressedKeys.Contains($mappedChar)) {
            $isValid = $false
            foreach ($r in $rows) { if ($r -match $mappedChar) { $isValid = $true } }
            if ($isValid) { [void]$pressedKeys.Add($mappedChar) }
        }
    }
}

$encodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptBlock.ToString()))
Start-Process powershell -ArgumentList "-NoProfile -EncodedCommand $encodedCommand"
```
