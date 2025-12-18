---
sidebar_position: 1
---

# Flipper Windows Enrolment

This script is used to enrol Windows PCs in the internal company domain and Intune.

## Requirements

*   Flipper Zero with Bad USB capability (Momentum is used in the script)
*   Access to Intune Enrolment
*   A service account

## Instructions

1.  Copy the script to your Flipper Zero. To do this, you can use the [Flipper app](https://flipper.net/pages/downloads) or [QFlipper](https://flipper.net/pages/downloads) and save it as `script.txt`.
2.  Start the Windows PC. It must be in the First Install Iso screen.
3.  Press `Shift + F10` to open a Powershell. Click on the window to bring it into focus.
4.  Run the script.
5.  Done.

## Code

```text
DELAY 2000
STRING powershell.exe
ENTER
DELAY 2000
STRING Install-Script -Name Get-WindowsAutopilotInfo
ENTER
DELAY 3000
STRING J
ENTER
DELAY 15000
STRING j
ENTER
DELAY 3000
STRING a
ENTER
DELAY 15000
STRING Set-ExecutionPolicy Bypass
ENTER
DELAY 3000
STRING Get-WindowsAutoPilotInfo.ps1 -online -Assign
ENTER
DELAY 60000
STRING your_intune_mail@mail.com mailto:your_intune_mail@mail.com
ENTER
DELAY 5000
STRING passowrd_intine_account
ENTER
DELAY 5000
ENTER
DELAY 480000
STRING shutdown -r -t 0
ENTER
DELAY 480000
STRING your_servcice_account@mail.com mailto:your_servcice_account@mail.com
ENTER
DELAY 2000
STRING Passwort_servcieaccpunt
ENTER
```

### After Restart

In some cases, you will need to log in again with your service account email and password.

```text
STRING service@mail.com
TAB
STRING service_pw
ENTER
```
