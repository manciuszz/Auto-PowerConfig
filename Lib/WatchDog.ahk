;========================================================================
;
; This template contains two examples by default. You may remove them.
;
; * HOW TO ADD A PROGRAM to be checked upon (de)activation/(un)existance:
;
; 1. Add a variable named ProgWinTitle# (Configuration Section)
; containing the desired title/ahk_class/ahk_id/ahk_group
;
; 2. Add a variable named WinTrigger# (Configuration Section)
; containing the desired trigger ("Exist" or "Active")
;
; 3. Add labels named LabelTriggerOn# and/or LabelTriggerOff#
; (Custom Labels Section) containing the desired actions
;
; 4. You may also change CheckPeriod value if desired
;
;========================================================================

#Persistent

; ------ ------ CONFIGURATION SECTION ------ ------

Notify(wnd, msg, delay = 2000, number = 1) {
	wndTitle := SubStr(ProgWinTitle%wnd%, 9)
	StringUpper, wndTitle, wndTitle
	TrayTip, Power Manager - %wndTitle%, % msg
	Sleep, %delay%
	TrayTip
}

MonitorWindow(window, number, trigger = "Active") {
	global 
	ProgWinTitle%number% := window
	WinTrigger%number% := trigger
	if (WinExist(window))
		Notify(number, "Checking for: " . WinTrigger%number%)
}

; SetTimer Period
checkPeriod = 1000
runnerPrefix := "WatchdogRun"

; ------ END OF CONFIGURATION SECTION ------ ------

Init() {
	static vAutoExecDummy := Init()
	SetTimer, WatchDogRunner, %checkPeriod%
}

; ------ ------ ------

WatchDogRunner() {
  global
  While ( ProgWinTitle%A_Index% != "" && WinTrigger := WinTrigger%A_Index% ) {
    if ( !ProgRunning%A_Index% != !Win%WinTrigger%( ProgWinTitle := ProgWinTitle%A_Index% ) )
      GoSubSafe( runnerPrefix A_Index "_O" ( (ProgRunning%A_Index% := !ProgRunning%A_Index%) ? "N" : "FF" )  )
	Sleep, %checkPeriod% / 2
  }
}

; ------ ------ ------

GoSubSafe(mySub) {
  if IsFunc(mySub)
    %mySub%()
}