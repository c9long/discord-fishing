#Requires AutoHotkey v2.0
#SingleInstance force

; Auto /fish sender for AutoHotkey v2
; Toggle on/off with F8. Exit with Esc.

interval := 3300 ; milliseconds
running := false
isBuying := false
isFishing := false
buyPending := false
pendingMode := ""
isFishPaused := false
buyItemPending := false
buyExpensivePending := false
serverName := "Coruscant"  ; Replace with your server name
channelName := "bots"     ; Replace with your channel name (without #)

F2:: {
    global isFishPaused, interval, running, buyItemPending, buyExpensivePending
    isFishPaused := !isFishPaused
    if isFishPaused {
        SetTimer(SendFish, 0)
    } else {
        if running
            SetTimer(SendFish, interval)
        if buyItemPending {
            buyItemPending := false
            BuyItems()
            SetTimer(BuyItems, 305000)
        }
        if buyExpensivePending {
            buyExpensivePending := false
            BuyExpensiveItems()
            SetTimer(BuyExpensiveItems, 1205000)
        }
    }
    ToolTip isFishPaused ? "Fishing Paused" : "Fishing Resumed"
    SetTimer(RemoveToolTip, 1200)
}

F6:: {
    BuyWorker10()
    SetTimer(BuyWorker30, 0)
    SetTimer(BuyWorker10, 605000)
    ToolTip "Worker10 Purchased"
    SetTimer(RemoveToolTip, 1200)
}

^F6:: {
    BuyItems()
    SetTimer(BuyExpensiveItems, 0)
    SetTimer(BuyItems, 305000)
    ToolTip "Items Purchased (Ctrl+F6)"
    SetTimer(RemoveToolTip, 1200)
}

F7:: {
    BuyWorker30()
    SetTimer(BuyWorker10, 0)
    SetTimer(BuyWorker30, 1805000)
    ToolTip "Worker30 Purchased"
    SetTimer(RemoveToolTip, 1200)
}

^F7:: {
    BuyExpensiveItems()
    SetTimer(BuyItems, 0)
    SetTimer(BuyExpensiveItems, 1205000)
    ToolTip "Expensive Items Purchased (Ctrl+F7)"
    SetTimer(RemoveToolTip, 1200)
}

F8:: {
    global running, interval, isBuying, isFishPaused
    running := !running
    if running {
        if not isFishPaused
            SetTimer(SendFish, interval)
    } else {
        StopAllTimers()
    }

    ToolTip running ? "Auto /fish: ON" : "Auto /fish: OFF"
    ; hide tooltip after 1.2s
    SetTimer(RemoveToolTip, 1200)
}

#HotIf WinActive("ahk_exe DiscordDevelopment.exe")

=:: {
    global interval
    interval += 100
    seconds := interval / 1000
    ToolTip "Interval: " seconds " seconds"
    SetTimer(RemoveToolTip, 1200)
}

-:: {
    global interval
    interval -= 100
    if interval < 100
        interval := 100
    seconds := interval / 1000
    ToolTip "Interval: " seconds " seconds"
    SetTimer(RemoveToolTip, 1200)
}

#HotIf

SendFish(*) {
    global isBuying, isFishing, buyPending, pendingMode, isFishPaused
    if not (WinExist("A") && (WinGetProcessName("A") == "DiscordDevelopment.exe"))
        return
    if isFishPaused
        return
    if isBuying
        return
    isFishing := true

    ; Send the command, pause ~1 second, then press Enter twice
    SendInput "/fish"
    Sleep 500
    SendInput "{Enter}"
    Sleep 300
    SendInput "{Enter}"
    isFishing := false
    if buyPending {
        buyPending := false
        mode := pendingMode
        pendingMode := ""
        isBuying := true
        if mode == "normal" {
            SwitchToChannel()
            Sleep 500
            SendInput "/buy fish5m"
            Sleep 300
            SendInput "{Enter}"
            Sleep 800
            SendInput "/buy treasure5m"
            Sleep 300
            SendInput "{Enter}"
        } else if mode == "expensive" {
            SwitchToChannel()
            Sleep 500
            SendInput "/buy fish20m"
            Sleep 300
            SendInput "{Enter}"
            Sleep 800
            SendInput "/buy treasure20m"
            Sleep 300
            SendInput "{Enter}"
        } else if mode == "worker10" {
            wasOnDiscord := WinExist("A") && (WinGetProcessName("A") == "DiscordDevelopment.exe")
            SwitchToChannel()
            Sleep 500
            SendInput "/buy auto10m"
            Sleep 300
            SendInput "{Enter}"
            Sleep 300
            SendInput "{Enter}"
            if not wasOnDiscord
                SendInput "!{Tab}"
            SetTimer(BuyWorker10, 605000)
        } else if mode == "worker30" {
            wasOnDiscord := WinExist("A") && (WinGetProcessName("A") == "DiscordDevelopment.exe")
            SwitchToChannel()
            Sleep 500
            SendInput "/buy auto30m"
            Sleep 300
            SendInput "{Enter}"
            Sleep 300
            SendInput "{Enter}"
            if not wasOnDiscord
                SendInput "!{Tab}"
            SetTimer(BuyWorker30, 1805000)
        }
        isBuying := false
    }
}

RemoveToolTip(*) {
    ToolTip
    SetTimer(RemoveToolTip, 0)
}

StopAllTimers() {
    SetTimer(SendFish, 0)
    SetTimer(BuyItems, 0)
    SetTimer(BuyExpensiveItems, 0)
    SetTimer(BuyWorker10, 0)
    SetTimer(BuyWorker30, 0)
}

SwitchToChannel(*) {
    global serverName, channelName
    WinActivate "ahk_exe DiscordDevelopment.exe"
    Sleep 500
    currentTitle := WinGetTitle("A")
    if not (InStr(currentTitle, serverName) and InStr(currentTitle, channelName)) {
        SendInput "^k"
        Sleep 300
        SendInput serverName " " channelName
        Sleep 300
        SendInput "{Enter}"
        Sleep 500
    }
}

BuyItems(*) {
    global isBuying, isFishing, buyPending, pendingMode, isFishPaused, buyItemPending
    if isFishPaused {
        buyItemPending := true
        return
    }
    if isBuying
        return
    if isFishing {
        Sleep 500
        SendInput "{Enter}"
        Sleep 100
        SendInput "{Enter}"
        buyPending := true
        pendingMode := "normal"
        return
    }
    isBuying := true
    SwitchToChannel()
    Sleep 500
    SendInput "/buy fish5m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 800
    SendInput "/buy treasure5m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 800
    isBuying := false
}

BuyExpensiveItems(*) {
    global isBuying, isFishing, buyPending, pendingMode, isFishPaused, buyExpensivePending
    if isFishPaused {
        buyExpensivePending := true
        return
    }
    if isBuying
        return
    if isFishing {
        Sleep 500
        SendInput "{Enter}"
        Sleep 100
        SendInput "{Enter}"
        buyPending := true
        pendingMode := "expensive"
        return
    }
    isBuying := true
    SwitchToChannel()
    Sleep 500
    SendInput "/buy fish20m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 800
    SendInput "/buy treasure20m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 800
    isBuying := false
}

BuyWorker10(*) {
    global isBuying, isFishing, buyPending, pendingMode
    if isBuying
        return
    if isFishing {
        Sleep 500
        SendInput "{Enter}"
        Sleep 100
        SendInput "{Enter}"
        buyPending := true
        pendingMode := "worker10"
        return
    }
    wasOnDiscord := WinExist("A") && (WinGetProcessName("A") == "DiscordDevelopment.exe")
    SwitchToChannel()
    Sleep 500
    SendInput "/buy auto10m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 300
    SendInput "{Enter}"
    Sleep 300
    if not wasOnDiscord
        SendInput "!{Tab}"
}

BuyWorker30(*) {
    global isBuying, isFishing, buyPending, pendingMode
    if isBuying
        return
    if isFishing {
        Sleep 500
        SendInput "{Enter}"
        Sleep 100
        SendInput "{Enter}"
        buyPending := true
        pendingMode := "worker30"
        return
    }
    wasOnDiscord := WinExist("A") && (WinGetProcessName("A") == "DiscordDevelopment.exe")
    SwitchToChannel()
    Sleep 500
    SendInput "/buy auto30m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 300
    SendInput "{Enter}"
    Sleep 300
    if not wasOnDiscord
        SendInput "!{Tab}"
}

F1::ExitApp

; End of script
