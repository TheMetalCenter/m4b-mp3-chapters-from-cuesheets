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
    Sleep, 50
    Sleep, 50
    Send, {LAlt Down}
    Sleep, 50
    Send, {Tab}
    Sleep, 50
    Send, {LAlt Up}
    Sleep, 50
    WinActivate, Edit the ToC [EPUB] ahk_class Qt5152QWindowIcon
    Send, {LControl Down}
    Sleep, 50
    Send, {c}
    Sleep, 100
    Send, {LControl Up}
    Sleep, 50
    Send, {Down}
    Sleep, 50
    Send, {LAlt Down}
    Sleep, 50
    Send, {Tab}
    Sleep, 50
    WinActivate, Task Switching ahk_class MultitaskingViewFrame
    Send, {LAlt Up}
    Sleep, 50
    WinActivate, *cuesheet.cue - Notepad++ ahk_class Notepad++
    Send, {LControl Down}
    Sleep, 50
    Send, {v}
    Sleep, 50
    Send, {LControl Up}{Down}
    Sleep, 50
    Send, {Down}
    Sleep, 50
    Send, {Down}
    Sleep, 50
    Send, {Left}
}
Return

Esc::Pause    ; Pause script with Escape Key
F10::Pause  ; Pause script with F10
