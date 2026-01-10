#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreads 255
#MaxThreadsPerHotkey 1

; ______________________________________________________________________________________________________________
;                         __ _       
;                       / _(_)      
;        ___ ___  _ __ | |_ _  __ _ 
;      / __/ _ \| '_ \|  _| |/ _` |       Made with <3 by Mythic
;     | (_| (_) | | | | | | | (_| |       https://github.com/SillyMythic/sniperfix-v2-wartycoon
;     \___\___/|_| |_|_| |_|\__, |        
;                            _/ |
;                          |___/    
version := "26.3"
; Consult the keylist for correct syntax: https://www.autohotkey.com/docs/v2/KeyList.htm


; Config:                                Description:                                               Example:

whitelistedKeys := [3, 4, 6]             ; Number keys corresponding to the slots of your snipers   [1, 2, ...]
shieldKey := 5                           ; Needed for autoShield                                    (5)
requireCenteredCursor := true            ; Only works in first person (requires fullscreen)         (true/false)

sniperBind := "RButton"                  ; Keybind for sniper macro                                 "key"
autoShield := false                      ; Automatically shield after shooting                      (true/false)
grenadeBind := ""                       ; Keybind for grenade dropping macro                       "key"
exitBind := "Home"                       ; Keybind to exit the script                               "key"

quickReset := false                      ; Automatically reset when conditions are met              (true/false)

updateCheck := true                      ; Check for updates on startup                             (true/false)
archiveNotification := true              ; Show archive notification on startup                     (true/false)

bufferDelay := 1                         ; Increment by 1ms if experiencing issues with macro       (ms)
equipDelay := 1150                       ; Prevents accidental clicks when equipping weapon         (ms)
chamberDelay := 200                      ; Prevents double clicks between shots                     (ms)

windowName := "Roblox"                   ; Macro will only execute in this application(s)           "Roblox, Roblox Studio, ..."
; ______________________________________________________________________________________________________________


global font := "cascadia code"
global accent := "B29fc9"
global text := "f1eef6"
global danger := "c97d7d"
global bg := "08060a"

tride.notify("Sniperfix Initialized.", 1500)

CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

lastNumber := ""
lastNumberTime := 0
lastMacroTime := 0
lastGrenade := 0
lastZTime := 0
centerWidth := A_ScreenWidth / 2
centerHeight := A_ScreenHeight / 2
latestChangelog := ""

RoundCorners(Hwnd)
{
    WinGetClientPos(&gX, &gY, &gWidth, &gHeight, Hwnd)
    WinSetRegion(Format("0-0 w{1} h{2} r0-0", gWidth, gHeight), Hwnd)
}

checkForUpdates() {
    global version, updater, versionText, changelogText, downloadUrl, latestVersion, latestChangelog
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", "https://api.github.com/repos/SillyMythic/sniperfix-v2-wartycoon/releases/latest", false)
        whr.SetRequestHeader("User-Agent", "AHK-Updater")
        whr.Send()
        if (whr.Status = 200) {
            if RegExMatch(whr.ResponseText, '"tag_name":\s*"v?([\d\.]+)"', &match) {
                latestVersion := match[1]
                if RegExMatch(whr.ResponseText, '"browser_download_url":\s*"(https://[^"]+\.ahk)"', &matchUrl) {
                    downloadUrl := matchUrl[1]
                }
                changelog := ""
                if RegExMatch(whr.ResponseText, '"body":\s*"(((\\"|[^"])*))"', &matchBody) {
                    changelog := matchBody[1]
                    changelog := StrReplace(changelog, "\r\n", "`n")
                    changelog := StrReplace(changelog, "\n", "`n")
                    changelog := StrReplace(changelog, "\t", "    ")
                    changelog := StrReplace(changelog, '\"', '"')
                    changelog := StrReplace(changelog, '\\', '\')
                    latestChangelog := changelog
                }

                
                if IsSet(changelogText) && latestChangelog != ""
                    changelogText.Value := latestChangelog
                
                isNewer := false
                l := StrSplit(latestVersion, "."), c := StrSplit(version, ".")
                loop Max(l.Length, c.Length) {
                    lv := A_Index <= l.Length ? (IsNumber(l[A_Index]) ? Integer(l[A_Index]) : 0) : 0
                    cv := A_Index <= c.Length ? (IsNumber(c[A_Index]) ? Integer(c[A_Index]) : 0) : 0
                    if (lv > cv) {
                        isNewer := true
                        break
                    } else if (lv < cv) {
                        break
                    }
                }

                if (isNewer) {
                    tride.notify("Update available! (v" latestVersion ")`nClick to download", 15000, (*) => (
                        updater.Show("w400 h250"),
                        RoundCorners(updater.Hwnd),
                        StartDownload()
                    ))
                }
            }
        }
    }
}

StartDownload() {
    global downloadUrl, latestVersion, updater, progress, versionText, changelogText, starText, titleText, watermarkText, font
    if !IsSet(downloadUrl) || downloadUrl = "" {
        tride.Show("Error", "Couldn't find download URL for update.", {onlyOk: true})
        return
    }

    filename := "sniperfix-v2-" . latestVersion . "-NOGUI.ahk"
    
    try {
        progress.Value := 20
        Download(downloadUrl, filename)
        
        progress.Value := 100
        titleText.Visible := true
        watermarkText.Visible := true
        versionText.Visible := false
        changelogText.Visible := false
        starText.Visible := true

        updater.SetFont("s16 c" accent " Bold", font)
        updater.Add("Text", " x10 y90", "Finished!")
        updater.SetFont("s12 c" text " Bold", font)
        finishMsg := updater.Add("Text", " x12 y120", "The updated script has been downloaded`nto this directory.`nClosing in 5...")
        
        loop 5 {
            Sleep(1000)
            finishMsg.Value := "The updated script has been downloaded`nto this directory.`nClosing in " . (5 - A_Index) . "..."
        }
        Run(filename . " /firstrun")
        ExitApp()
    } catch as e {
        tride.Show("Error", "Failed to download update.", {onlyOk: true})
    }
}

updater := Gui(, "Updater")
updater.Opt("-MAXIMIZEBOX -Caption")
updater.BackColor := bg
updater.SetFont("s24 c" accent " Bold", font)
titleText := updater.Add("Text", "Center x10 y0","Sniperfix Updater")

updater.SetFont("s8 c" text " Bold", font)
watermarkText := updater.Add("Text", "Center x12 y35","Made with <3 by Mythic")

updater.SetFont("s8 c" accent "", font)
versionText := updater.Add("Text", "x10 y80","Changelog")

updater.SetFont("s8 c" text " Bold", font)
changelogText := updater.Add("Text", "x12 y95 w375 h110","Fetching changelogs...")

updater.SetFont("s8 c" text " Bold", font)
starText := updater.Add("Text", "x10 y215","Would appreciate a star on github!")
progress := updater.Add("Progress", "x-1 y233 w401 h17 +Smooth c" accent " Background" bg, 0)


isFirstTimeOpening := false
for arg in A_Args {
    if (arg = "/firstrun") {
        isFirstTimeOpening := true
        break
    }
}

if (isFirstTimeOpening) {
    tride.notify("Sniperfix has been updated to v" version "! Click to view changelog!", 10000, (*) => (
        Run("https://github.com/SillyMythic/sniperfix-v2-wartycoon/releases")
    ))
}

if (archiveNotification) {
    tride.notify("⚠️ Sniperfix has been archived and discontinued. This is due to recent ROBLOX updates that have demotivated me from maintaining this script.`n`nClick to view other projects I work on.", 10000, (*) => (
        Run("https://github.com/SillyMythic")
    ))
}

if updateCheck {
    checkForUpdates()
}

if quickReset {
    SetTimer(doQuickReset, 100)
}



#HotIf WinActive(windowName)
~*1::setLastNumber(1)
~*2::setLastNumber(2)
~*3::setLastNumber(3)
~*4::setLastNumber(4)
~*5::setLastNumber(5)
~*6::setLastNumber(6)
~*7::setLastNumber(7)
~*8::setLastNumber(8)
~*9::setLastNumber(9)
~*0::setLastNumber(0)

setLastNumber(num) {
    global lastNumber, lastNumberTime
    lastNumber := num
    lastNumberTime := A_TickCount
}

#HotIf
isWhitelisted(key) {
    global whitelistedKeys
    for k in whitelistedKeys
        if (k = key)
            return true
    return false
}

HotIfWinActive windowName
Hotkey("~" . sniperBind, (*) => Sniper())
Hotkey("*~" . grenadeBind, (*) => Grenade())
HotIf

Hotkey(exitBind, exit)
exit(*) {
    tride.notify("Exiting Sniperfix.", 1000)
    Sleep(1500)
    ExitApp()
}

if (autoShield) {
    tride.notify("Autoshield is enabled. this feature is still incomplete, expect issues.", 10000)
}
Sniper() {
    global lastNumberTime, lastMacroTime, lastNumber, requireCenteredCursor, isWhitelisted, equipDelay, chamberDelay, sniperBind, centerWidth, centerHeight
    if (A_TickCount - lastNumberTime < equipDelay
        || A_TickCount - lastMacroTime < chamberDelay
        || !isWhitelisted(lastNumber))
        return

    if (requireCenteredCursor) {
        MouseGetPos &x, &y
        if (x != centerWidth || y != centerHeight)
            return
    }

    if (sniperBind != "RButton") {
        SendInput "{RButton}"
    }

    SendInput "{LButton}"
    Sleep(bufferDelay)
    SendInput lastNumber . lastNumber

    if (autoShield) {
        SendInput shieldKey
        Sleep(100)
        SendInput lastNumber
    }

    
    lastMacroTime := A_TickCount
}

Grenade() {
    global lastGrenade, lastZTime
    
    if (A_TickCount - lastZTime < 1000) {
        SendInput "{9}"
        Sleep(10)
        SendInput "{LButton}"
        Sleep(30)
        SendInput "{0}"
        Sleep(10)
        SendInput "{LButton}"
        Sleep(30)
        SendInput "{0}"
        
    if (autoShield)
        SendInput shieldKey

        if (A_TickCount - lastGrenade > 10000) {
            tride.notify("Dropping grenades.", 1000)
            lastGrenade := A_TickCount
        }
        lastZTime := 0
    } else {
        lastZTime := A_TickCount
    }
}

doQuickReset() {
    global quickReset, windowName
    if (!quickReset || !WinActive(windowName))
        return

    if (PixelGetColor(815, 995) = "0x12DC12" && PixelGetColor(1090, 995) = "0x12DC12") {
        tride.notify("Quick resetting.", 1000)
        Send "{Escape}"
        Sleep(10)
        Send "{R}"
        Sleep(300)
        Send "{Enter}"
        Sleep(1000)
    }
}

class tride {
    static queue := []

    static Show(title, message, options := "") {
        options := IsObject(options) ? options : {}
        inst := { result: "No", gui: Gui("+AlwaysOnTop -Caption +ToolWindow") }
        inst.gui.BackColor := bg
        inst.gui.SetFont("s16 c" text " Bold", font)
        inst.gui.Add("Text", "Center x0 y25 w300", title)
        inst.gui.SetFont("s9 c" text " Norm", font)
        (desc := inst.gui.Add("Text", "Center x10 y60 w280", message)).GetPos(,,,&h)
        btnY := Max(115, 60 + h + 15)
        inst.gui.SetFont("s10 c" text " Bold", font)
        
        local btnYes := 0, btnNo := 0
        if options.HasProp("onlyOk") && options.onlyOk {
            btnYes := inst.gui.Add("Text", "x100 y" btnY " w100 h35 Center +0x200 Background" accent, options.HasProp("okText") ? options.okText : "OK")
            btnYes.OnEvent("Click", (*) => (inst.result := "Yes", inst.gui.Destroy()))
        } else {
            btnYes := inst.gui.Add("Text", "x40 y" btnY " w100 h35 Center +0x200 Background" accent, options.HasProp("yesText") ? options.yesText : "YES")
            btnNo := inst.gui.Add("Text", "x160 y" btnY " w100 h35 Center +0x200 Background" danger, options.HasProp("noText") ? options.noText : "NO")
            btnYes.OnEvent("Click", (*) => (inst.result := "Yes", inst.gui.Destroy()))
            btnNo.OnEvent("Click", (*) => (inst.result := "No", inst.gui.Destroy()))
        }
        
        DragHandler(wp, lp, msg, hwnd) => (hwnd = inst.gui.Hwnd ? PostMessage(0xA1, 2,,, "A") : "")
        OnMessage(0x0201, DragHandler)
        
        hwnd := inst.gui.Hwnd
        inst.gui.Show("w300 h" (btnY + 60))
        RoundCorners(hwnd), SoundPlay("*64")
        while WinExist(hwnd)
            Sleep(50)
        OnMessage(0x0201, DragHandler, 0)
        return inst.result
    }

    static notify(message, lifetime := 3000, action := "") {
        width := 350, barThickness := 8
        window := Gui("+AlwaysOnTop -Caption +ToolWindow")
        window.BackColor := bg
        
        isClickable := IsObject(action) && HasMethod(action)
        
        window.SetFont("s10 c" text " Bold", "Arial")
        closeBtn := window.Add("Text", "x" (width - 25) " y5 w20 h20 Center", "✕")
        
        window.SetFont("s11 c" (isClickable ? accent : text) " Bold", font)
        label := window.Add("Text", "Left x15 y18 w" (width - 70), message)
        label.GetPos(,,,&labelH)
        
        ; Minimum height of 75, but grows if text is long
        height := Max(75, 18 + labelH + 15 + barThickness)
        
        progressBar := window.Add("Progress", "x-1 y" (height - barThickness) " w" (width + 1) " h" barThickness " +Smooth c" accent " Background" bg, 100)
        
        yOffset := 20
        for item in this.queue
            yOffset += item.height + 5

        window.Show("x" (A_ScreenWidth - width - 20) " y" yOffset " w" width " h" height " NoActivate")
        RoundCorners(window.Hwnd)
        
        notification := {
            window: window,
            bar: progressBar,
            lifetime: lifetime,
            startedAt: 0,
            height: height
        }
        
        this.queue.Push(notification)
        
        closeBtn.OnEvent("Click", (*) => this.handleClick(notification))
        if isClickable
            label.OnEvent("Click", (*) => (this.handleClick(notification), SetTimer(action, -1)))
            
        if this.queue.Length = 1
            SetTimer(() => this.tick(), 20)
    }

    static handleClick(notification) {
        for index, item in this.queue {
            if (item = notification) {
                this.remove(index)
                break
            }
        }
    }

    static remove(index) {
        if (index < 1 || index > this.queue.Length)
            return
            
        try this.queue[index].window.Destroy()
        this.queue.RemoveAt(index)
        
        currentY := 20
        for i, item in this.queue {
            item.window.Show("x" (A_ScreenWidth - 370) " y" currentY " NoActivate")
            currentY += item.height + 5
        }
        
        if !this.queue.Length
            SetTimer(() => this.tick(), 0)
    }

    static tick() {
        if !this.queue.Length {
            SetTimer(, 0)
            return
        }
        
        current := this.queue[1]
        if !current.startedAt
            current.startedAt := A_TickCount
            
        timePassed := A_TickCount - current.startedAt
        remainingPercent := 100 - (timePassed / current.lifetime * 100)
        
        if (timePassed >= current.lifetime) {
            this.remove(1)
        } else {
            try {
                if (remainingPercent < 30)
                    current.bar.Opt("+c" danger)
                current.bar.Value := remainingPercent
            }
        }
    }
}
