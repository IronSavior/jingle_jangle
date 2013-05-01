; Jingle Jangle
; League of Legends jungle timer
; Author: Erik Elmore <erik@ironsavior.net>
; https://github.com/IronSavior/jingle_jangle
; Version: May 1, 2013
#SingleInstance, Force
#NoEnv
#UseHook

Main:
  GoSub Config
  Setup_Hotkeys()
  Setup_GUI()
  SetTimer, TimerTick, 1000
return

Config:
  alarm_sound   := "jj-alarm.mp3"
  early_warning := 15  ; Raise alarm this many seconds early
  alarm_expiry  := 15  ; Clear timer this many seconds after alarm
  AddCampTimer("dragon", "Dragon:",     60*6, "F1")
  AddCampTimer("baron",  "Baron:",      60*7, "F2",         "cPurple")
  AddCampTimer("blue",   "Ally Blue:",  60*5, "F3",         "cBlue")
  AddCampTimer("red",    "Ally Red:",   60*5, "F4",         "cRed")
  AddCampTimer("blue_",  "Enemy Blue:", 60*5, "Shift & F3", "cBlue")
  AddCampTimer("red_",   "Enemy Red:",  60*5, "Shift & F4", "cRed")
return

AddCampTimer( id, label, duration, hotkey, color = "cBlack", hotkey_label = 0, alarm = 0 ) {
  global
  all_camps := all_camps ? all_camps . "," . id : id
  label_%id% := label
  init_%id% := duration
  hotkey_%id% := hotkey
  color_%id% := color
  hotkey_label_%id% := hotkey_label ? hotkey_label : hotkey
  alarm_%id% := alarm ? alarm : alarm_sound
}

Setup_Hotkeys() {
  global
  local id, id0
  StringSplit, id, all_camps, `,
  while( id := id%A_Index% ) {
    Hotkey, % hotkey_%id%, timer_hotkey
  }
}

Setup_GUI() {
  global
  local title_bar := "Welcome to the Jungle"
  local font_size := 10
  local col_w1 := 60   ; pixel width of hotkey name
  local col_w2 := 80   ; pixel width of camp name
  local col_w3 := 35   ; pixel width of timer
  local col_m  := 5    ; pixel width of margin between columns
  Gui +AlwaysOnTop +ToolWindow
  Gui,Font, s%font_size%
  local id, id0
  StringSplit, id, all_camps, `,
  while( id := id%A_Index% ) {
    SetupTimer(id, init_%id%, label_%id%, hotkey_label_%id%, color_%id%, col_m, col_w1, col_w2, col_w3 )
  }
  Gui,Show, AutoSize NoActivate, %title_bar%
}

GuiClose:
  ExitApp
return

TimerTick:
  UpdateDisplay()
return

UpdateDisplay() {
  global
  local id, id0
  StringSplit, id, all_camps, `,
  while( id := id%A_Index% ) {
    UpdateTimer(id)
  }
}

on_timer_hotkey( hotkey ) {
  global
  local id, id0
  StringSplit, id, all_camps, `,
  while( id := id%A_Index% ) {
    if( hotkey_%id% = hotkey ) {
      ResetTimer(id)
      UpdateTimer(id)
    }
  }
}

timer_hotkey:
  on_timer_hotkey(A_ThisHotkey)
return

ResetTimer( id ) {
  global
  active_%id% := true
  target_%id% := A_TickCount + (init_%id% - early_warning) * 1000
}

UpdateTimer( id ) {
  global
  local now := A_TickCount
  if( now > alarm_expiry * 1000 + target_%id% ) {
    GuiControl,, display_%id%,
  }
  if( active_%id% = false ) {
    return
  }
  if( now < target_%id% ) {
    local delta := (target_%id% - now) // 1000
    local minutes := delta // 60
    local seconds := Mod(delta, 60)
    seconds := seconds < 10 ? "0" . seconds : seconds
    GuiControl,, display_%id%, %minutes%:%seconds%
  }
  else {
    active_%id% := false
    TimerAlarm(id)
  }
}

SetupTimer( id, init, display_name, display_hotkey, color, col_m, col_w1, col_w2, col_w3 ) {
  global
  active_%id% := false
  target_%id% := 0
  Gui,Font, %color%
  Gui,Add,Text, x0 w%col_w1% +Right, [%display_hotkey%]
  Gui,Add,Text, x+%col_m% w%col_w2% +Right, %display_name%
  Gui,Add,Text, x+%col_m% w%col_w3% +Left vdisplay_%id%
}

TimerAlarm( id ) {
  global
  local sound := FileExist(alarm_%id%) ? alarm_%id% : "*-1"
  GuiControl,, display_%id%, <----
  SoundPlay, %sound%
}
