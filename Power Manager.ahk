Utility.runSelfAsAdministrator()

#Include <WatchDog>
#Include <ThrottleStop_API>
#Include <SilentOption_API>
#Include <RivaTunerStatisticsServer_API>

#NoEnv
#UseHook
#MaxThreadsPerHotkey 2
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#Persistent
#SingleInstance force
ListLines Off
; Process, Priority, , H ; Set process priority to High -> if unstable, comment or remove this line
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input

StartMonitoringProcesses() {
	static vAutoExecDummy := StartMonitoringProcesses() ; TL:DR -> This makes self-execution for functions possible
	
	if A_IsAdmin { ; Note: Comment these and the includes above if not needed.
		Utility.launchProcess("RTSS.exe")
		Utility.launchProcess("ThrottleStop.exe")
		Utility.launchProcess("SilentOption.exe")
	}		
		
	monitoredProcesses := {
	(Join,
			1: { "ahk_exe androidemulator.exe": "Active" }
			2: { "ahk_exe opera.exe": "Active" }
	)}
	
	for windowID, windowInfo in monitoredProcesses {
		for processID, windowDetectionType in windowInfo {
			MonitorWindow(processID, windowID, windowDetectionType)
		}
	}
}

; -----------  PSUEDO COROUTINES START HERE --------------
global runnerPrefix := "PowerManager"

PowerManager1_ON() {
	global
	if (WinExist(ThrottleMisc.exeProcess)) {
		ThrottleMisc.clearTemps()
		ThrottleProfile.set("Game").setActiveStatus("ON")
		ThrottleMultiplier.set(25)
	}
}

PowerManager1_OFF(temperatureThreshold := 60) {
	global
	if (WinExist(ThrottleMisc.exeProcess)) {
		if (Temperatures.get() > temperatureThreshold)
			ThrottleProfile.set("Battery").setActiveStatus("ON")
		else
			ThrottleProfile.set("Internet").setActiveStatus("OFF")
	}
}

; ----------------------

PowerManager2_ON() {
	global
	if (WinExist(ThrottleMisc.exeProcess)) {
		ThrottleMisc.clearTemps()
		ThrottleProfile.set("Internet").setActiveStatus("ON")
		; ThrottleMultiplier.set(25)
	}
}

PowerManager2_OFF(temperatureThreshold := 60) {
	global
	if (WinExist(ThrottleMisc.exeProcess)) {
		if (Temperatures.get() > temperatureThreshold)
			ThrottleProfile.set("Battery").setActiveStatus("ON")
		else
			ThrottleProfile.set("Internet").setActiveStatus("OFF")
	}
}

; -----------  PSEUDO COROUTINES END HERE --------------

#If WinExist(ThrottleMisc.exeProcess) ; ThrottleStop context-sensitive hotkeys...
; *PgDn:: Temperatures.log.get()
; *XButton1:: FindTextInsideControlWindow("Game")
*Insert:: Reload