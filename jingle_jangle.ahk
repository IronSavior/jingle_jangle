; Jingle Jangle
; League of Legends jungle timer
; Author: Erik Elmore <erik@ironsavior.net>
; https://github.com/IronSavior/jingle_jangle
; Version: April 25, 2013

#SingleInstance, Force
#NoEnv
#UseHook

Main:
  ally_team  := "ally"
  enemy_team := "enemy"
  null_team  := "river"
  
  GoSub Config
  GoSub Config_Sounds
  GoSub Setup_Hotkeys
  GoSub Init_GUI
  Gui,Show, AutoSize NoActivate, %title_bar%
  SetTimer, UpdateDisplay, 1000
return

Config:
  ; Respawn times in seconds
  init_dragon := 60*6
  init_baron  := 60*7
  init_blue   := 60*5
  init_red    := 60*5
  
  ; Seconds deducted from initial respawn times
  early_warning := 15

  ; Display parameters
  title_bar  := "Welcome to the Jungle"
  font_size  := 10
  col1_width := 60
  col2_width := 80
  col3_width := 35
  col_margin := 5
  alarm_expiry := 10  ; Clear timer this many seconds after alarm
  
  ; Alarm sound file
  alarm_sound := "jj-alarm.mp3"
  
  ; default system sound to use if alarm_sound doesn't exist
  ; See http://www.autohotkey.com/docs/commands/SoundPlay.htm
  default_sound = *-1
  
  ; Hotkey settings
  dragon_key = F1
  baron_key  = F2
  blue_key   = F3
  red_key    = F4
  passthru   =    ; ~ to retain original key function, blank to block
  enemy_key  = +  ; + for Shift, ! for Alt (leave passthru blank for Alt+F4)
  enemy_key_label := "Shift+"
return

Config_Sounds:
  if( FileExist(alarm_sound) ) {
    alarm_%null_team%_dragon := alarm_sound
    alarm_%null_team%_baron  := alarm_sound
    alarm_%ally_team%_blue   := alarm_sound
    alarm_%ally_team%_red    := alarm_sound
    alarm_%enemy_team%_blue  := alarm_sound
    alarm_%enemy_team%_red   := alarm_sound
  }
  else {
    alarm_%null_team%_dragon := default_sound
    alarm_%null_team%_baron  := default_sound
    alarm_%ally_team%_blue   := default_sound
    alarm_%ally_team%_red    := default_sound
    alarm_%enemy_team%_blue  := default_sound
    alarm_%enemy_team%_red   := default_sound
  }
return

Setup_Hotkeys:
  Hotkey, %passthru%%dragon_key%,          hotkey_dragon
  Hotkey, %passthru%%baron_key%,           hotkey_baron
  Hotkey, %passthru%%blue_key%,            hotkey_ally_blue
  Hotkey, %passthru%%red_key%,             hotkey_ally_red
  Hotkey, %passthru%%enemy_key%%blue_key%, hotkey_enemy_blue
  Hotkey, %passthru%%enemy_key%%red_key%,  hotkey_enemy_red
return

Init_GUI:
  Gui +AlwaysOnTop +ToolWindow
  Gui,Font, s%font_size%
  
  Gui,Font, cBlack
  AddCampTimer(dragon_key, "Dragon:", "dragon", null_team)
  
  Gui,Font, cPurple
  AddCampTimer(baron_key, "Baron:", "baron",  null_team)
  
  Gui,Font, cBlue
  AddCampTimer(blue_key, "Ally Blue:", "blue",   ally_team)
  
  Gui,Font, cRed
  AddCampTimer(red_key, "Ally Red:", "red",    ally_team)
  
  Gui,Font, cBlue
  AddCampTimer(enemy_key_label blue_key, "Enemy Blue:", "blue",   enemy_team)
  
  Gui,Font, cRed
  AddCampTimer(enemy_key_label red_key, "Enemy Red:", "red",    enemy_team)
return

UpdateDisplay:
  UpdateCampTimer("dragon", null_team)
  UpdateCampTimer("baron",  null_team)
  UpdateCampTimer("blue",   ally_team)
  UpdateCampTimer("red",    ally_team)
  UpdateCampTimer("blue",   enemy_team)
  UpdateCampTimer("red",    enemy_team)
return

ResetCampTimer( camp, team ) {
  local nothing
  active_%team%_%camp% := true
  target_%team%_%camp% := A_TickCount + (init_%camp% - early_warning) * 1000
}

UpdateCampTimer( camp, team ) {
  local nothing
  local now := A_TickCount
  if( now > alarm_expiry * 1000 + target_%team%_%camp% ) {
    GuiControl,, display_%team%_%camp%,
  }
  if( active_%team%_%camp% = false ) {
    return
  }
  if( now < target_%team%_%camp% ) {
    local delta := (target_%team%_%camp% - now) // 1000
    local minutes := delta // 60
    local seconds := Mod(delta, 60)
    seconds := seconds < 10 ? "0" . seconds : seconds
    GuiControl,, display_%team%_%camp%, %minutes%:%seconds%
  }
  else {
    active_%team%_%camp% := false
    CountdownEvent(camp, team)
  }
}

AddCampTimer( key, label, camp, team ){
  local nothing
  active_%team%_%camp% := false
  Gui,Add,Text, x0 w%col1_width% +Right, [%key%]
  Gui,Add,Text, x+%col_margin% w%col2_width% +Right, %label%
  Gui,Add,Text, x+%col_margin% w%col3_width% +Left vdisplay_%team%_%camp%
}

CountdownEvent( camp, team ) {
  local nothing
  GuiControl,, display_%team%_%camp%, <----
  SoundPlay, % alarm_%team%_%camp%
}

GuiClose:
  ExitApp
return

hotkey_dragon:
  ResetCampTimer("dragon", null_team)
  UpdateCampTimer("dragon", null_team)
return

hotkey_baron:
  ResetCampTimer("baron", null_team)
  UpdateCampTimer("baron", null_team)
return

hotkey_ally_blue:
  ResetCampTimer("blue", ally_team)
  UpdateCampTimer("blue", ally_team)
return

hotkey_ally_red:
  ResetCampTimer("red", ally_team)
  UpdateCampTimer("red", ally_team)
return

hotkey_enemy_blue:
  ResetCampTimer("blue", enemy_team)
  UpdateCampTimer("blue", enemy_team)
return

hotkey_enemy_red:
  ResetCampTimer("red", enemy_team)
  UpdateCampTimer("red", enemy_team)
return
