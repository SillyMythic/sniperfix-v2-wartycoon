#Requires AutoHotkey v2.0
#SingleInstance Force

;##############################################
;               _   _   _                 
;              | | | | (_)                
;      ___  ___| |_| |_ _ _ __   __ _ ___ 
;     / __|/ _ \ __| __| | '_ \ / _` / __|
;     \__ \  __/ |_| |_| | | | | (_| \__ \
;     |___/\___|\__|\__|_|_| |_|\__, |___/
;                               __/ |    
;                              |___/       
; Configuration
whitelisted := [4, 6]                    ; Keys your snipers are on
requireCenteredCursor := true            ; Only works in first person (requires fullscreen)
rightMode := true                        ; Removes extra input if macro is bound to right click
numberPressDelay := 1150                 ; Prevents accidental clicks when pulling out weapon
macroCooldown := 100                     ; Prevents double clicks between shots
;##############################################

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
    global whitelisted
    for k in whitelisted
        if (k = key)
            return true
    return false
}

; Main macro - only active in Roblox
#HotIf WinActive("Roblox")
~*RButton::Sniper()

Sniper() {
    global lastNumberPressTime, lastMacroTime, lastNumber
    global requireCenteredCursor, rightMode, isWhitelisted, numberPressDelay, macroCooldown

    ; Early return if conditions aren't met
    if (A_TickCount - lastNumberPressTime < numberPressDelay
        || A_TickCount - lastMacroTime < macroCooldown
        || !isWhitelisted(lastNumber))
        return

    ; Check cursor position if required
    if (requireCenteredCursor) {
        MouseGetPos &x, &y
        if (x != A_ScreenWidth / 2 || y != A_ScreenHeight / 2)
            return
    }

    ; Execute macro
    if (!rightMode)
        SendInput "{RButton}"

    SendInput "{LButton}"
    SendInput lastNumber
    SendInput lastNumber

    lastMacroTime := A_TickCount
}
#HotIf

; Exit hotkey
Home::ExitApp