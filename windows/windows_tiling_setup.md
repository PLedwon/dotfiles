# Windows Tiling Setup (Komorebi + whkd + Workspace Tray)

Automated dotfiles and bootstrap setup for **Komorebi** (tiling window manager), **whkd** (hotkey daemon), and a custom **AutoHotkey v1** system tray workspace indicator.

---

## Repository Contents

* `komorebi.json` — Main Komorebi window manager configuration.
* `whkdrc` — Hotkey definitions for `whkd`.
* `komorebi_ws_tray.ahk` — AutoHotkey v1 script that displays the active workspace icon in the system tray and remaps `CapsLock` to `Esc` (excluding `SC2_x64.exe`).
* `komorebi_icons/` — Numbered `.ico` files (`1.ico`–`5.ico`) used by the tray script.
* `install.ps1` — PowerShell bootstrap script that installs dependencies, copies configurations, and launches the environment.

---

## Prerequisites (Before Running `install.ps1`)

Complete these steps on a fresh Windows 10/11 installation before executing the setup script:

### 1. Verify `winget` (Windows Package Manager)
`winget` is pre-installed on modern versions of Windows 10 and Windows 11. Open **PowerShell** and verify it works:
```powershell
winget --version
```
*If `winget` is missing or outdated:* Open the **Microsoft Store**, search for **App Installer**, and click **Install** or **Update**.

### 2. Install Git
Install Git via `winget` so you can clone this repository:
```powershell
winget install -e --id Git.Git
```
Restart your PowerShell window after installing so `git` is added to your `PATH`.

### 3. AutoHotkey v1.1 Requirement
Your `komorebi_ws_tray.ahk` script uses **AutoHotkey v1 syntax** (`#NoEnv`, `SetBatchLines`, `#IfWinNotActive`). 
* Note that `winget install AutoHotkey.AutoHotkey` installs **AutoHotkey v2** by default on newer systems, which may prompt you to download v1.1 when launching a v1 script—or fail to run it directly.
* Ensure **AutoHotkey v1.1** is installed (either alongside v2 via the AutoHotkey launcher or specifically via `winget install -e --id AutoHotkey.AutoHotkey --version 1.1.37.02`).

### 4. Windhawk for vertical winbar
* **Vertical taskbar for windows 11** 
* **Dynamic Taskbar Transparency** 
* **Separate System Tray Icons** 
* **Windows 11 Taskbar Styler** 

### 5. Recommended Windows Settings
* **Disable Windows Animations (Recommended):** Open **Settings > Accessibility > Visual effects** and turn **Animation effects** **Off** so window tiling transitions happen instantaneously without lag.
* **System Tray Overflow:** After first launch, open **Settings > Personalization > Taskbar > Other system tray icons** and toggle the AutoHotkey workspace icon **On** so the active workspace number stays visible at all times.

---

## Installation Steps

1. **Open PowerShell as Administrator**
   Press `Win + X` and select **Terminal (Admin)** or **Windows PowerShell (Admin)**.

2. **Clone this Repository**
   ```powershell
   git clone <YOUR_REPO_URL> C:\Users\$env:USERNAME\dotfiles
   cd C:\Users\$env:USERNAME\dotfiles
   ```

3. **Verify Username Paths (If Needed)**
   Check `komorebi.json` and `komorebi_ws_tray.ahk` to ensure no hardcoded paths point to an old username (e.g., use `A_UserName` in `.ahk` and `$Env:USERPROFILE` in `.json`).

4. **Run the Bootstrap Script**
   Temporarily allow local script execution for the current session and run `install.ps1`:
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\install.ps1
   ```

---

## Common Commands

| Action | Command |
| :--- | :--- |
| **Start Komorebi + whkd** | `komorebic start --whkd` |
| **Stop Komorebi + whkd** | `komorebic stop --whkd` |
| **Reload Komorebi config** | `komorebic reload-configuration` |
| **Update app-specific rules** | `komorebic fetch-asc` |