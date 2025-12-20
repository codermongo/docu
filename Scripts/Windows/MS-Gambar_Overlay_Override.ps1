<#
.SYNOPSIS
MS-Gambar Overlay Override
Disables GameDVR, Game Bar, and associated protocols.
#>

# ALS ADMIN AUSFÜHREN 

# 1) GameDVR & Aufnahmen deaktivieren 

$regPath1 = "HKCU:\System\GameConfigStore"
if (!(Test-Path $regPath1)) { New-Item -Path $regPath1 -Force | Out-Null }
Set-ItemProperty -Path $regPath1 -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force  

$regPath2 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
if (!(Test-Path $regPath2)) { New-Item -Path $regPath2 -Force | Out-Null }
Set-ItemProperty -Path $regPath2 -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force

# 2) Game Bar / Game Mode / Controller-Button komplett aus 

$regPath3 = "HKCU:\SOFTWARE\Microsoft\GameBar"
if (!(Test-Path $regPath3)) { New-Item -Path $regPath3 -Force | Out-Null }
New-ItemProperty -Path $regPath3 -Name "AllowAutoGameMode"       -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $regPath3 -Name "AutoGameModeEnabled"     -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $regPath3 -Name "UseNexusForGameBarEnabled" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $regPath3 -Name "ShowGameModeNotifications" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $regPath3 -Name "ShowStartupPanel"          -Value 0 -PropertyType DWord -Force | Out-Null

# 3) Protokolle ms-gamebar / ms-gamebarservices / ms-gamingoverlay stumm schalten      

$sysRoot = $env:SystemRoot

$protocols = @("ms-gamebar","ms-gamebarservices","ms-gamingoverlay")
foreach ($p in $protocols) {
    $base = "HKCR\$p"
    reg add "$base" /f /ve /t REG_SZ /d "Dummy $p Handler" | Out-Null
    reg add "$base" /f /v "URL Protocol" /t REG_SZ /d ""   | Out-Null
    reg add "$base" /f /v "NoOpenWith"   /t REG_SZ /d ""   | Out-Null
    reg add "$base\shell" /f | Out-Null
    reg add "$base\shell\open" /f | Out-Null
    reg add "$base\shell\open\command" /f /ve /t REG_SZ /d "$sysRoot\System32\systray.exe" | Out-Null
}

# 4) Explorer neu starten, damit alles greift 

Stop-Process -Name explorer -Force

Write-Host "Xbox Game Bar, GameDVR und ms-gamebar/ms-gamingoverlay-Popups wurden deaktiviert." -ForegroundColor Green
