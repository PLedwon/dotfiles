#NoEnv
#SingleInstance Force
#Persistent
SetBatchLines, -1

; Adjust USER here
Global IconDir := "C:\Users\paull\komorebi_icons"

; Set initial icon immediately
UpdateWorkspaceIcon(1)

SetTimer, CheckWorkspace, 400
return

CheckWorkspace:
    tempFile := A_Temp . "\komo_ws_idx.txt"
    cmd := "powershell -NoProfile -WindowStyle Hidden -Command ""$s = komorebic state | ConvertFrom-Json; $m = $s.monitors.elements[$s.monitors.focused]; Write-Output ($m.workspaces.focused + 1)"""
    RunWait, %ComSpec% /c %cmd% > "%tempFile%", , Hide

    if FileExist(tempFile) {
        FileRead, wsStr, %tempFile%
        activeWs := Trim(wsStr, " `t`r`n")
        if activeWs is integer
        {
            if (activeWs >= 1 && activeWs <= 5) {
                UpdateWorkspaceIcon(activeWs)
            }
        }
    }
return

UpdateWorkspaceIcon(num) {
    static lastNum := 0
    if (num = lastNum)
        return

    iconPath := IconDir "\" num ".ico"
    if FileExist(iconPath) {
        lastNum := num
        Menu, Tray, Icon, %iconPath%, 1, 1
    }
    Menu, Tray, Tip, Komorebi Workspace %num%
}

; Maps CapsLock to Esc everywhere EXCEPT inside StarCraft II
#IfWinNotActive ahk_exe SC2_x64.exe
CapsLock::Esc
#IfWinNotActive