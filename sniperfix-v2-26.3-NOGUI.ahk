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
requireCenteredCursor := true            ; Only works in first person (requires fullscreen)         (true/false)

macroBind := "RButton"                   ; Keybind for macro                                        "key"
exitBind := "Home"                       ; Keybind to exit the script                               "key"

updateAutomatically := true              ; Automatically check for updates on startup               (true/false)

bufferDelay := 1                         ; Increment by 1ms if experiencing issues with macro       (ms)
equipDelay := 1150                       ; Prevents accidental clicks when equipping weapon         (ms)
chamberDelay := 100                      ; Prevents double clicks between shots                     (ms)

windowName := "Roblox"                   ; Macro will only execute in this application(s)           "Roblox, Roblox Studio, ..."
; ______________________________________________________________________________________________________________

lastNumber := ""
lastNumberTime := 0
lastMacroTime := 0
centerWidth := A_ScreenWidth / 2
centerHeight := A_ScreenHeight / 2

RoundCorners(Hwnd)
{
    WinGetClientPos(&gX, &gY, &gWidth, &gHeight, Hwnd)
    WinSetRegion(Format("0-0 w{1} h{2} r20-20", gWidth, gHeight), Hwnd)
}

checkForUpdates() {
    global version, updater, versionText, changelogText, downloadUrl, latestVersion
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
                }

                if IsSet(versionText)
                    versionText.Value := "Changelog v" . latestVersion
                
                if IsSet(changelogText) && changelog != ""
                    changelogText.Value := changelog
                
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
                    if (MsgBox("A new version (v" latestVersion ") is available!`n`nCurrent: v" version "`nLatest: v" latestVersion "`n`nWould you like to update?", "Update Detector", 4) = "Yes") {
                        updater.Show("w400 h250")
                        RoundCorners(updater.Hwnd)
                        StartDownload()
                    }
                }
            }
        }
    }
}

StartDownload() {
    global downloadUrl, latestVersion, updater, progress, versionText, changelogText, starText
    if !IsSet(downloadUrl) || downloadUrl = "" {
        MsgBox("Could not find download URL for the update.", "Error", 16)
        return
    }

    filename := "sniperfix-v2-" . latestVersion . "-NOGUI.ahk"
    
    try {
        progress.Value := 20
        Download(downloadUrl, filename)
        
        progress.Value := 100
        versionText.Visible := false
        changelogText.Visible := false
        starText.Visible := false

        updater.SetFont("12 cC5E478 bold", "consolas")
        finishMsg := updater.Add("Text", " x10 y120", "The updated script has been downloaded`nto this directory.`nClosing in 3...")
        
        loop 3 {
            Sleep(1000)
            finishMsg.Value := "The updated script has been downloaded`nto this directory.`nClosing in " . (3 - A_Index) . "..."
        }
        ExitApp()
    } catch as e {
        MsgBox("Failed to download the update.`n`nError: " . e.Message, "Error", 16)
    }
}

updater := Gui(, "Updater")
updater.Opt("-MAXIMIZEBOX -Caption")
updater.BackColor := "0A2338"
updater.SetFont("s24 cC5E478 Bold", "consolas")
updater.Add(
"Text", "Center x10 y10",
"Sniperfix Updater"
)

updater.SetFont("s8 c3789FF Bold", "consolas")
updater.Add(
"Text", "Center x12 y45",
"Made with <3 by Mythic"
)

updater.SetFont("s8 cC5E478", "consolas")
versionText := updater.Add(
"Text", "x10 y80",
"Changelog: fetching..."
)

updater.SetFont("s8 c3789FF", "consolas")
changelogText := updater.Add(
"Text", "x12 y95 w375 h110",
"Fetching changelogs..."
)

updater.SetFont("s8 cC5E478", "consolas")
starText := updater.Add(
"Text", "x10 y215",
"Would really appreciate if you star on github!"
)
progress := updater.Add("Progress", "x0 y233 w400 h16 +Smooth c654AA3 Background011627", 0)

if updateAutomatically {
    checkForUpdates()
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
#HotIf WinActive(windowName)
Hotkey("~" . macroBind, (*) => Macro())
#HotIf
Hotkey(exitBind, (*) => ExitApp())



Macro() {
    global lastNumberTime, lastMacroTime, lastNumber, requireCenteredCursor, isWhitelisted, equipDelay, chamberDelay, macroBind, centerWidth, centerHeight
    if (A_TickCount - lastNumberTime < equipDelay
        || A_TickCount - lastMacroTime < chamberDelay
        || !isWhitelisted(lastNumber))
        return

    if (requireCenteredCursor) {
        MouseGetPos &x, &y
        if (x != centerWidth || y != centerHeight)
            return
    }

    if (macroBind != "RButton")
        SendInput "{RButton}"

    SendInput "{LButton}"
    Sleep(bufferDelay)
    SendInput lastNumber . lastNumber

    lastMacroTime := A_TickCount
}
