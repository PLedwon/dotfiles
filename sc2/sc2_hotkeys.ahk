; Auto-elevate script to Administrator
if not A_IsAdmin {
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Client

; ==============================================================================
; CONFIGURATION
; ==============================================================================
; Delay before standard rapid fire starts (in milliseconds)
InitialDelayMs := 120

; Standard rapid fire repeat interval (in milliseconds)
RapidFireSleep := 5

; In-game hotkey bound to "Chrono Boost" on Nexus
ChronoKey := "w"

; Camera hotkeys (with Alt) used for Protoss Chrono Boost base cycling
ProtossChronoCams := ["q", "w", "e"]

; Default race on startup: "Z" (Zerg), "P" (Protoss), or "T" (Terran)
Race := "Z"

; Convert InitialDelayMs to seconds for KeyWait
InitialDelaySec := InitialDelayMs / 1000


; ==============================================================================
; RACE SELECTION (Zerg / Protoss / Terran) and Chat Makros
; ==============================================================================
#IfWinActive ahk_exe SC2_x64.exe

^z::
    Race := "Z"
    ; Zerg: Low, organic Overlord/Zergling-style warble
    SoundBeep, 220, 65
    SoundBeep, 330, 65
    SoundBeep, 260, 110
return

^p::
    Race := "P"
    ; Protoss: High, crystalline Probe-selection double chirp
    SoundBeep, 1100, 65
    Sleep 35
    SoundBeep, 1450, 95
return

^t::
    Race := "T"
    ; Terran: Crisp military radio/comm-link triple pip
    SoundBeep, 750, 50
    Sleep 30
    SoundBeep, 750, 50
    Sleep 30
    SoundBeep, 1000, 90
return

^h::
    KeyWait, Ctrl               ; Wait until Ctrl is released so Shift+Enter registers cleanly
    Send +{Enter}               ; Open All Chat
    Sleep 30                    ; Brief pause for chat input box to focus
    SendRaw (glhf)              ; Type literal "(glhf)"
    Sleep 15
    Send {Enter}                ; Send message
return

^g::
    KeyWait, Ctrl               ; Wait until Ctrl is released so Shift+Enter registers cleanly
    Send +{Enter}               ; Open All Chat
    Sleep 30                    ; Brief pause for chat input box to focus
    SendRaw (gg)                ; Type literal "(gg)"
    Sleep 15
    Send {Enter}                ; Send message
return


; ==============================================================================
; SPACEBAR CAMERA & RACE MACRO HOTKEYS (Space + 4)
; ==============================================================================

; Intercept Spacebar completely when held with QWER/ASD or 4 to block native SC2 Space activation
#If WinActive("ahk_exe SC2_x64.exe") && GetKeyState("Space", "P")

q::Send !q
w::Send !w
e::Send !e
r::Send !r
a::Send !a
s::Send !s
d::Send !d

4::
    VarSetCapacity(rect, 16, 0)
    DllCall("GetClientRect", "Ptr", WinExist("ahk_exe SC2_x64.exe"), "Ptr", &rect)
    winW := NumGet(rect, 8, "Int")
    winH := NumGet(rect, 12, "Int")
    baseX := winW // 2
    baseY := Round((winH / 2) - (0.04 * winH))

    if (Race = "Z") {
        ; Zerg: Box-select rapid Queen inject across bases
        boxHalfW := Round(winH * 0.2)
        boxHalfH := Round(winH * 0.2)
        boxX1 := baseX - boxHalfW
        boxY1 := baseY - boxHalfH
        boxX2 := baseX + boxHalfW
        boxY2 := baseY + boxHalfH

        While GetKeyState("4", "P") && GetKeyState("Space", "P") {
            Send {Tab}                          ; Jump to next base camera
            MouseMove, %boxX1%, %boxY1%, 0      ; Top-left corner around Hatchery
            Click, Down                         ; Start drag-box
            MouseMove, %boxX2%, %boxY2%, 0      ; Bottom-right corner around Hatchery
            Click, Up                           ; Finish drag-box (selects local Queen)
            Send {q}                            ; Cast Spawn Larva
            Click %baseX%, %baseY%              ; Click center of Hatchery
            Sleep 1                             ; Engine buffer before next base
        }
    } else if (Race = "P") {
        ; Protoss: Rapid Worker Chronoboost across Camera Locations Q, W, E
        For index, camKey in ProtossChronoCams {
            if !(GetKeyState("4", "P") && GetKeyState("Space", "P"))
                break
            Send !%camKey%                      ; Jump to Camera Location (Alt+Q, Alt+W, Alt+E)
            Sleep 10                            ; Brief buffer for camera snap before clicking Nexus
            Click %baseX%, %baseY%              ; Select centered Nexus
            Send {%ChronoKey%}                  ; Activate Chrono Boost ('w')
            Click %baseX%, %baseY%              ; Cast Chrono Boost on the Nexus
            Sleep 1                             ; Engine buffer before next camera
        }
        KeyWait, 4                              ; Wait for '4' release so holding longer doesn't re-trigger
    } else {
        ; Terran: Pass through normal 4 if pressed while holding Space
        Send {4}
    }
return

#If


#IfWinActive ahk_exe SC2_x64.exe

; Pass-through regular Spacebar press only on release if no other key was hit
~Space Up::
    if (A_PriorKey = "Space") {
        Send {Space}
    }
return


; ==============================================================================
; RAPID FIRE KEYS (Guarded against Spacebar collision)
; ==============================================================================

#If WinActive("ahk_exe SC2_x64.exe") && !GetKeyState("Space", "P")

$q::
    if GetKeyState("Space", "P")
        return
    Send {q}
    KeyWait, q, T%InitialDelaySec%
    if ErrorLevel {
        While GetKeyState("q", "P") && !GetKeyState("Space", "P") {
            Send {q}
            Sleep %RapidFireSleep%
        }
    }
return

$w::
    if GetKeyState("Space", "P")
        return
    Send {w}
    KeyWait, w, T%InitialDelaySec%
    if ErrorLevel {
        While GetKeyState("w", "P") && !GetKeyState("Space", "P") {
            Send {w}
            Sleep %RapidFireSleep%
        }
    }
return

$e::
    if GetKeyState("Space", "P")
        return
    Send {e}
    KeyWait, e, T%InitialDelaySec%
    if ErrorLevel {
        While GetKeyState("e", "P") && !GetKeyState("Space", "P") {
            Send {e}
            Sleep %RapidFireSleep%
        }
    }
return

$r::
    if GetKeyState("Space", "P")
        return
    Send {r}
    KeyWait, r, T%InitialDelaySec%
    if ErrorLevel {
        While GetKeyState("r", "P") && !GetKeyState("Space", "P") {
            Send {r}
            Sleep %RapidFireSleep%
        }
    }
return

$a::
    if GetKeyState("Space", "P")
        return
    Send {a}
    KeyWait, a, T%InitialDelaySec%
    if ErrorLevel {
        While GetKeyState("a", "P") && !GetKeyState("Space", "P") {
            Send {a}
            Sleep %RapidFireSleep%
        }
    }
return

$s::
    if GetKeyState("Space", "P")
        return
    Send {s}
    KeyWait, s, T%InitialDelaySec%
    if ErrorLevel {
        While GetKeyState("s", "P") && !GetKeyState("Space", "P") {
            Send {s}
            Sleep %RapidFireSleep%
        }
    }
return

$d::
    if GetKeyState("Space", "P")
        return
    Send {d}
    KeyWait, d, T%InitialDelaySec%
    if ErrorLevel {
        While GetKeyState("d", "P") && !GetKeyState("Space", "P") {
            Send {d}
            Sleep %RapidFireSleep%
        }
    }
return

$f::
    if GetKeyState("Space", "P")
        return
    Send {f}
    KeyWait, f, T%InitialDelaySec%
    if ErrorLevel {
        While GetKeyState("f", "P") && !GetKeyState("Space", "P") {
            Send {f}
            Sleep %RapidFireSleep%
        }
    }
return

$z::
    if GetKeyState("Space", "P")
        return
    Send {z}
    KeyWait, z, T%InitialDelaySec%
    if ErrorLevel {
        While GetKeyState("z", "P") && !GetKeyState("Space", "P") {
            Send {z}
            Sleep %RapidFireSleep%
        }
    }
return

$x::
    if GetKeyState("Space", "P")
        return
    Send {x}
    KeyWait, x, T%InitialDelaySec%
    if ErrorLevel {
        While GetKeyState("x", "P") && !GetKeyState("Space", "P") {
            Send {x}
            Sleep %RapidFireSleep%
        }
    }
return

$c::
    if GetKeyState("Space", "P")
        return
    Send {c}
    KeyWait, c, T%InitialDelaySec%
    if ErrorLevel {
        While GetKeyState("c", "P") && !GetKeyState("Space", "P") {
            Send {c}
            Sleep %RapidFireSleep%
        }
    }
return

#If

; ==============================================================================
; GLOBAL WINDOWS REMAPPING (Disabled inside SC2 so SubgroupNext=CapsLock works)
; ==============================================================================
#IfWinNotActive ahk_exe SC2_x64.exe
CapsLock::Esc
#IfWinNotActive