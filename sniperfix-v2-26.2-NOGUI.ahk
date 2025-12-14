#Requires AutoHotkey v2.0
#SingleInstance Force

; ______________________________________________________________________________________________________________
;                         __ _       
;                       / _(_)      
;        ___ ___  _ __ | |_ _  __ _ 
;      / __/ _ \| '_ \|  _| |/ _` |       Made with <3 by Mythic
;     | (_| (_) | | | | | | | (_| |       https://github.com/SillyMythic/sniperfix-v2-wartycoon
;     \___\___/|_| |_|_| |_|\__, |        v26.2-NOGUI
;                            _/ |
;                          |___/    

; Consult the keylist for correct syntax: https://www.autohotkey.com/docs/v2/KeyList.htm


; Config:                                Description:                                               Example:

macroBind := "RButton"                   ; Keybind for macro                                        "key"
exitBind := "Home"                       ; Exit hotkey                                              "key"

whitelistedKeys := [4, 6]                ; Keys your snipers are on                                 [1, 2, ...]
requireCenteredCursor := true            ; Only works in first person (requires fullscreen)         true/false

pullOutDelay := 1150                     ; Prevents accidental clicks when pulling out weapon       (ms)
chamberDelay := 100                      ; Prevents double clicks between shots                     (ms)
; ______________________________________________________________________________________________________________




; Global state variables
lastNumber := ""
lastNumberPressTime := 0
lastMacroTime := 0

; Track last number pressed
~*0::setLastNumber(0)
~*1::setLastNumber(1)
~*2::setLastNumber(2)
~*3::setLastNumber(3)
~*4::setLastNumber(4)
~*5::setLastNumber(5)
~*6::setLastNumber(6)
~*7::setLastNumber(7)
~*8::setLastNumber(8)
~*9::setLastNumber(9)

setLastNumber(num) {
    global lastNumber, lastNumberPressTime
    lastNumber := num
    lastNumberPressTime := A_TickCount
}

isWhitelisted(key) {
    global whitelistedKeys
    for k in whitelistedKeys
        if (k = key)
            return true
    return false
}

#HotIf WinActive("Roblox")
Hotkey("~*" . macroBind, (*) => Macro())
#HotIf
Hotkey(exitBind, (*) => ExitApp())

Macro() {
    global lastNumberPressTime, lastMacroTime, lastNumber
    global requireCenteredCursor, isWhitelisted, pullOutDelay, chamberDelay, macroBind

    ; Early return if conditions aren't met
    if (A_TickCount - lastNumberPressTime < pullOutDelay
        || A_TickCount - lastMacroTime < chamberDelay
        || !isWhitelisted(lastNumber))
        return

    ; Check cursor position
    if (requireCenteredCursor) {
        MouseGetPos &x, &y
        if (x != A_ScreenWidth / 2 || y != A_ScreenHeight / 2)
            return
    }

    ; Execute macro
    if (macroBind != "RButton")
        SendInput "{RButton}"

    SendInput "{LButton}"
    Sleep(1)
    SendInput lastNumber
    SendInput lastNumber

    lastMacroTime := A_TickCount
}



