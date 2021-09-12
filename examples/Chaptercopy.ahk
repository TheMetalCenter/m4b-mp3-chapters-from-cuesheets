; This script was created using Pulover's Macro Creator
; www.macrocreator.com

#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window
SendMode Input
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1


F9::
Chaptercopy:
Loop
{
    WinActivate, *cuesheet.cue - Notepad++ ahk_class Notepad++
    Sleep, 200
    Sleep, 200
    Send, {LAlt Down}
    Sleep, 40
    Send, {Tab}
    Sleep, 40
    Send, {LAlt Up}
    Sleep, 200
    WinActivate, Edit the ToC [EPUB] ahk_class Qt5152QWindowIcon
    Send, {LControl Down}
    Sleep, 80
    Send, {c}
    Sleep, 100
    Send, {LControl Up}
    Sleep, 200
    Send, {Down}
    Sleep, 200
    Send, {LAlt Down}
    Sleep, 60
    Send, {Tab}
    Sleep, 70
    WinActivate, Task Switching ahk_class MultitaskingViewFrame
    Send, {LAlt Up}
    Sleep, 200
    WinActivate, *cuesheet.cue - Notepad++ ahk_class Notepad++
    Send, {LControl Down}
    Sleep, 70
    Send, {v}
    Sleep, 200
    Send, {LControl Up}{Down}
    Sleep, 100
    Send, {Down}
    Sleep, 200
    Send, {Down}
    Sleep, 150
    Send, {Left}
}
Return

Esc::Pause    ; Pause script with Escape Key
F10::Pause  ; Pause script with F10
