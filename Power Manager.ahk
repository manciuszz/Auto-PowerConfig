﻿Utility.runSelfAsAdministrator()

#Include <WatchDog>
#Include <ThrottleStop_API>
#Include <SilentOption_API>
#Include <RivaTunerStatisticsServer_API>
#Include <GDI/DrawText>

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
	
	if (true && A_IsAdmin) { ; Note: Comment these and the includes above if not needed.
		Utility.launchProcess("RTSS.exe")
		Utility.launchProcess("ThrottleStop.exe")
		Utility.launchProcess("SilentOption.exe")
	}		
		
	monitoredProcesses := {
	(Join,
			1: { "ahk_exe androidemulator.exe": "Active" }
			2: { "ahk_exe opera.exe": "Active" }
			3: { "ahk_exe client.exe": "Active" }
	)}
	
	for windowID, windowInfo in monitoredProcesses {
		for processID, windowDetectionType in windowInfo {
			WatchDog.monitorWindow(processID, windowDetectionType, "PowerManager" . windowID)		
		}
	}
	WatchDog.run()
}

; -----------  PSUEDO COROUTINES START HERE --------------
PowerManager1_ON() {
	global
	if (WinExist(ThrottleMisc.exeProcess)) {
		ThrottleMisc.clearTempLogs()
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
		ThrottleMisc.clearTempLogs()
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

; ----------------------

_ThrottlePerformance(multiplier := "") { ; On the fly "CoolDown" hotkey function
	static toggleThrottleMode := false
	if (WinExist(ThrottleMisc.exeProcess)) {
		currentProfile := toggleThrottleMode ? "Game" : "Battery"
		ThrottleProfile.set(currentProfile).setActiveStatus("ON")
		DrawText("Current Profile: " . currentProfile, 1)
		DrawText("Current CPU-Multiplier: " . ThrottleMultiplier.get(), 2)
		DrawText("Current Temp's: " . Temperatures.get(), 3)
		; RTSS.replaceFPS("client.exe", toggleThrottleMode ? 59935 : 30000).applyChanges()
		toggleThrottleMode := !toggleThrottleMode
	}
}

PowerManager3_ON(cpuMultiplier := 19) { ; Game "Creative Destruction" profile
	global
	if (WinExist(ThrottleMisc.exeProcess)) {
		ThrottleMisc.clearTempLogs()
		ThrottleProfile.set("Game").setActiveStatus("ON")
		ThrottleMultiplier.set(cpuMultiplier)
		DrawText("Current Profile: Game", 1)
		DrawText("Current CPU-Multiplier: " . cpuMultiplier, 2)
		DrawText("Current Temp's: " . Temperatures.get(), 3)
	}
	
	if (WinExist("Creative Destruction")) { ; Because "Creative Destruction" and "Blade and Soul" has the same process name...
		static isCalled := false
		if (isCalled)
			return
								
		DynamicKey.bind("*XButton2", "_ThrottlePerformance", cpuMultiplier)

		notifyProcessID := "client.exe"

		; Utility.changeResolution(1360, 768)
		; Notify(notifyProcessID, "Changing Desktop Resolution to enhance Creative Destruction experience.")

		Utility.AHKScript("C:\Users\Manciuszz\Desktop\AHK\Project-Aim Assistance.ahk").open()
		WatchDog.notify(notifyProcessID, "Creative Destruction Enhancer loaded.")
		
		Utility.AHKScript("C:\Users\Manciuszz\Desktop\AHK\PixelAimAssistance.ahk").open()

		WatchDog.notify(notifyProcessID, "Creative Destruction Aim Assistance loaded.")
		
		Utility.setProcessCPUPriority("client", "High")
		WatchDog.notify(notifyProcessID, "Application CPU priority has been set to 'High'.")
		
		isCalled := true
	}	
}

PowerManager3_OFF(temperatureThreshold := 60) {
	global
	if (WinExist(ThrottleMisc.exeProcess)) {
		if (Temperatures.get() > temperatureThreshold) { ; To allow faster cooling down after done playing games...
			ThrottleProfile.set("Battery").setActiveStatus("ON")
			DrawText("Current Profile: Battery", 1)
			DrawText("Current Temp's: " . Temperatures.get(), 2)
			DrawText("", 3)
		} else {
			ThrottleProfile.set("Internet").setActiveStatus("OFF")
			DrawText("Current Profile: Disabled", 1)
			DrawText("", 2)
		}
	}
	
	if !(WinExist("Creative Destruction")) {
		Utility.AHKScript("C:\Users\Manciuszz\Desktop\AHK\Project-Aim Assistance.ahk").close()
		Utility.AHKScript("C:\Users\Manciuszz\Desktop\AHK\PixelAimAssistance.ahk").close()
		WatchDog.notify("client.exe", "Closed Creative Destruction Enhancer")
		DynamicKey.unbind("*XButton2")
		RTSS.toggleDisplay(true)
	}
}

; -----------  PSEUDO COROUTINES END HERE --------------

+^WheelUp:: ThrottleMultiplier.increase()
+^WheelDown:: ThrottleMultiplier.decrease()

#If WinExist(ThrottleMisc.exeProcess) ; ThrottleStop context-sensitive hotkeys...
*Insert:: Reload
; *PgDn:: return