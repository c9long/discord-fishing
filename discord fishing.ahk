#Requires AutoHotkey v2.0
#SingleInstance force

; Auto /fish sender for AutoHotkey v2
; Toggle on/off with F8. Exit with Esc.

serverName := IniRead("config.ini", "Settings", "server", "YourServerName")
channelName := IniRead("config.ini", "Settings", "channel", "YourSpamChannelName")
channelID := IniRead("config.ini", "Settings", "channelid", "YourChannelID")
discordExe := IniRead("config.ini", "Settings", "exe", "Discord.exe")

MyGui := Gui()
MyGui.Add("Text",, "Server Name:")
ServerEdit := MyGui.Add("Edit", "w400", serverName)
MyGui.Add("Text",, "Channel Name:")
ChannelEdit := MyGui.Add("Edit", "w400", channelName)
MyGui.Add("Text",, "Channel ID:")
ChannelIDEdit := MyGui.Add("Edit", "w400", channelID)
MyGui.Add("Text",, "Tip: Enable Developer Mode in Discord (Settings > Advanced), right-click the channel, and select 'Copy ID'.")
MyGui.Add("Text",, "Discord Executable:")
Radio1 := MyGui.Add("Radio", "vExeChoice", "Discord (x86 or x64)")
Radio2 := MyGui.Add("Radio",, "Discord Development (ARM64)")
if discordExe == "Discord.exe"
    Radio1.Value := 1
else
    Radio2.Value := 1
RunBtn := MyGui.Add("Button",, "Run Script")
RunBtn.OnEvent("Click", (*) => RunScript())
MyGui.Show("w1280 h720")
WinWaitClose("ahk_id " MyGui.Hwnd)

RunScript() {
    global serverName, channelName, channelID, discordExe
    serverName := ServerEdit.Value
    channelName := ChannelEdit.Value
    channelID := ChannelIDEdit.Value
    if Radio1.Value
        discordExe := "Discord.exe"
    else
        discordExe := "DiscordDevelopment.exe"
    IniWrite(serverName, "config.ini", "Settings", "server")
    IniWrite(channelName, "config.ini", "Settings", "channel")
    IniWrite(channelID, "config.ini", "Settings", "channelID")
    IniWrite(discordExe, "config.ini", "Settings", "exe")
    MyGui.Destroy()
}

interval := 3300 ; milliseconds
running := false
isBuying := false
isFishing := false
buyPending := false
pendingMode := ""
isFishPaused := false
buyItemPending := false
buyExpensivePending := false
itemTimerActive := false
workerTimerActive := false
nextItemTime := 0
nextWorkerTime := 0

F2:: {
    global isFishPaused, interval, running, buyItemPending, buyExpensivePending, nextItemTime
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
            nextItemTime := A_TickCount + 305000
        }
        if buyExpensivePending {
            buyExpensivePending := false
            BuyExpensiveItems()
            SetTimer(BuyExpensiveItems, 1205000)
            nextItemTime := A_TickCount + 1205000
        }
    }
    ToolTip isFishPaused ? "Fishing Paused" : "Fishing Resumed"
    SetTimer(RemoveToolTip, 1200)
}

F6:: {
    global nextWorkerTime, workerTimerActive
    BuyWorker10()
    SetTimer(BuyWorker30, 0)
    SetTimer(BuyWorker10, 605000)
    workerTimerActive := true
    nextWorkerTime := A_TickCount + 605000
    ToolTip "Worker10 Purchased"
    SetTimer(RemoveToolTip, 1200)
}

^F6:: {
    global running, nextItemTime, itemTimerActive
    if running {
        BuyItems()
        SetTimer(BuyItems, 0)
        SetTimer(BuyExpensiveItems, 0)
        SetTimer(BuyItems, 305000)
        itemTimerActive := true
        nextItemTime := A_TickCount + 305000
        ToolTip "Items Purchased (Ctrl+F6)"
        SetTimer(RemoveToolTip, 1200)
    } else {
        ToolTip "Cannot purchase items while not running"
        SetTimer(RemoveToolTip, 1200)
    }
}

F7:: {
    global nextWorkerTime, workerTimerActive
    BuyWorker30()
    SetTimer(BuyWorker10, 0)
    SetTimer(BuyWorker30, 1805000)
    workerTimerActive := true
    nextWorkerTime := A_TickCount + 1805000
    ToolTip "Worker30 Purchased"
    SetTimer(RemoveToolTip, 1200)
}

^F7:: {
    global running, nextItemTime, itemTimerActive
    if running {
        BuyExpensiveItems()
        SetTimer(BuyItems, 0)
        SetTimer(BuyExpensiveItems, 0)
        SetTimer(BuyExpensiveItems, 1205000)
        itemTimerActive := true
        nextItemTime := A_TickCount + 1205000
        ToolTip "Expensive Items Purchased (Ctrl+F7)"
        SetTimer(RemoveToolTip, 1200)
    } else {
        ToolTip "Cannot purchase items while not running"
        SetTimer(RemoveToolTip, 1200)
    }
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

IsInCorrectChannel() {
    if not (WinExist("A") && (WinGetProcessName("A") == discordExe))
        return false
    currentTitle := WinGetTitle("A")
    return currentTitle == "#" channelName " | " serverName " - Discord"
}

#HotIf IsInCorrectChannel()

=:: {
    global interval
    interval += 100
    ToolTip "Interval: " interval " milliseconds"
    SetTimer(RemoveToolTip, 1200)
}

-:: {
    global interval
    interval -= 100
    if interval < 100
        interval := 100
    ToolTip "Interval: " interval " milliseconds"
    SetTimer(RemoveToolTip, 1200)
}

Esc:: {
    global serverName, channelName, channelID, discordExe, ServerEdit, ChannelEdit, ChannelIDEdit, Radio1, Radio2, MyGui
    MyGui := Gui()
    MyGui.Add("Text",, "Server Name:")
    ServerEdit := MyGui.Add("Edit", "w400", serverName)
    MyGui.Add("Text",, "Channel Name:")
    ChannelEdit := MyGui.Add("Edit", "w400", channelName)
    MyGui.Add("Text",, "Channel ID:")
    ChannelIDEdit := MyGui.Add("Edit", "w400", channelID)
    MyGui.Add("Text",, "Tip: Enable Developer Mode in Discord (Settings > Advanced), right-click the channel, and select 'Copy ID'.")
    MyGui.Add("Text",, "Discord Executable:")
    Radio1 := MyGui.Add("Radio", "vExeChoice", "Discord (x86 or x64)")
    Radio2 := MyGui.Add("Radio",, "Discord Development (ARM64)")
    if discordExe == "Discord.exe"
        Radio1.Value := 1
    else
        Radio2.Value := 1
    RunBtn := MyGui.Add("Button",, "Update Settings")
    RunBtn.OnEvent("Click", (*) => UpdateSettings())
    MyGui.Show("w1280 h720")
}

^Esc:: {
    global running, isFishPaused, buyItemPending, buyExpensivePending, nextItemTime, nextWorkerTime, itemTimerActive, workerTimerActive
    status := "Status:`n"
    status .= "Auto /fish: " (running ? "ON" : "OFF") "`n"
    status .= "Fishing Paused: " (isFishPaused ? "YES" : "NO") "`n"
    currentTime := A_TickCount
    if buyItemPending or buyExpensivePending {
        nextItem := "Pending"
    } else if itemTimerActive {
        itemRemaining := nextItemTime > currentTime ? Ceil((nextItemTime - currentTime) / 1000) : 0
        nextItem := itemRemaining "s"
    } else {
        nextItem := "undefined"
    }
    status .= "Next Item Purchase: " nextItem "`n"
    if workerTimerActive {
        workerRemaining := nextWorkerTime > currentTime ? Ceil((nextWorkerTime - currentTime) / 1000) : 0
        nextWorker := workerRemaining "s"
    } else {
        nextWorker := "undefined"
    }
    status .= "Next Worker Purchase: " nextWorker
    ToolTip status
    SetTimer(RemoveToolTip, 3000)
}

#HotIf

SendFish(*) {
    global isBuying, isFishing, buyPending, pendingMode, isFishPaused, interval
    if not (WinExist("A") && (WinGetProcessName("A") == discordExe))
        return
    if isFishPaused
        return
    if isBuying
        return
    if not IsInCorrectChannel()
        return
    isFishing := true

    ; Send the command, pause ~1 second, then press Enter twice
    if IsInCorrectChannel()
        SendInput "^a"
    SendInput "/fish"
    Sleep 500
    SendInput "{Enter}"
    Sleep 300
    SendInput "{Enter}"
    SetTimer(SendFish, interval)
    isFishing := false
    if buyPending {
        buyPending := false
        mode := pendingMode
        pendingMode := ""
        if mode == "normal" {
            BuyItems(true)
        } else if mode == "expensive" {
            BuyExpensiveItems(true)
        } else if mode == "worker10" {
            BuyWorker10(true)
        } else if mode == "worker30" {
            BuyWorker30(true)
        }
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
    itemTimerActive := false
    workerTimerActive := false
    buyItemPending := false
    buyExpensivePending := false
    nextItemTime := 0
    nextWorkerTime := 0
}

SwitchToChannel(*) {
    global serverName, channelName, channelID, discordExe
    WinActivate "ahk_exe " discordExe
    Sleep 500
    currentTitle := WinGetTitle("A")
    expected := "#" channelName " | " serverName " - Discord"
    if currentTitle != expected {
        SendInput "^k"
        Sleep 300
        SendText "#" channelID
        Sleep 300
        SendInput "{Enter}"
        Sleep 500
        return true
    }
    return false
}

BuyItems(force := false) {
    global isBuying, isFishing, buyPending, pendingMode, isFishPaused, running, buyItemPending, nextItemTime
    if not running
        return
    if isFishPaused {
        if force
            return
        buyItemPending := true
        return
    }
    if isBuying and not force
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
    if IsInCorrectChannel()
        SendInput "^a"
    SendInput "/buy fish5m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 800
    SendInput "/buy treasure5m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 800
    isBuying := false
    SetTimer(BuyItems, 305000)
    nextItemTime := A_TickCount + 305000
}

BuyExpensiveItems(force := false) {
    global isBuying, isFishing, buyPending, pendingMode, isFishPaused, running, buyExpensivePending, nextItemTime
    if not running
        return
    if isFishPaused {
        if force
            return
        buyExpensivePending := true
        return
    }
    if isBuying and not force
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
    if IsInCorrectChannel()
        SendInput "^a"
    SendInput "/buy fish20m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 800
    SendInput "/buy treasure20m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 800
    isBuying := false
    SetTimer(BuyExpensiveItems, 1205000)
    nextItemTime := A_TickCount + 1205000
}

BuyWorker30(force := false) {
    global isBuying, isFishing, buyPending, pendingMode, discordExe, nextWorkerTime
    if isBuying and not force
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
    wasOnDiscord := WinExist("A") && (WinGetProcessName("A") == discordExe)
    switched := false
    Loop {
        if SwitchToChannel()
            switched := true
        Sleep 500
        if IsInCorrectChannel()
            break
    }
    if IsInCorrectChannel()
        SendInput "^a"
    SendInput "/buy auto30m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 300
    SendInput "{Enter}"
    Sleep 300
    if not wasOnDiscord
        SendInput "!{Tab}"
    else if switched
        SendInput "!{Left}"
    SetTimer(BuyWorker30, 1805000)
    nextWorkerTime := A_TickCount + 1805000
}

BuyWorker10(force := false) {
    global isBuying, isFishing, buyPending, pendingMode, discordExe, nextWorkerTime
    if isBuying and not force
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
    wasOnDiscord := WinExist("A") && (WinGetProcessName("A") == discordExe)
    switched := false
    Loop {
        if SwitchToChannel()
            switched := true
        Sleep 500
        if IsInCorrectChannel()
            break
    }
    if IsInCorrectChannel()
        SendInput "^a"
    SendInput "/buy auto10m"
    Sleep 300
    SendInput "{Enter}"
    Sleep 300
    SendInput "{Enter}"
    Sleep 300
    if not wasOnDiscord
        SendInput "!{Tab}"
    else if switched
        SendInput "!{Left}"
    SetTimer(BuyWorker10, 605000)
    nextWorkerTime := A_TickCount + 605000
}

F1::ExitApp

UpdateSettings() {
    global serverName, channelName, channelID, discordExe, ServerEdit, ChannelEdit, ChannelIDEdit, Radio1, Radio2, MyGui
    serverName := ServerEdit.Value
    channelName := ChannelEdit.Value
    channelID := ChannelIDEdit.Value
    if Radio1.Value
        discordExe := "Discord.exe"
    else
        discordExe := "DiscordDevelopment.exe"
    IniWrite(serverName, "config.ini", "Settings", "server")
    IniWrite(channelName, "config.ini", "Settings", "channel")
    IniWrite(channelID, "config.ini", "Settings", "channelID")
    IniWrite(discordExe, "config.ini", "Settings", "exe")
    MyGui.Destroy()
    ToolTip "Settings Updated"
    SetTimer(RemoveToolTip, 1200)
}

; End of script
