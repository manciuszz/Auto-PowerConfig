Utility.runSelfAsAdministrator()

#Include <WatchDog>
#Include <ThrottleStop_API>
#Include <SilentOption_API>
#Include <RivaTunerStatisticsServer_API>
#Include <Gdip2>

#NoEnv
#UseHook
#MaxThreadsPerHotkey 2
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#Persistent
#SingleInstance Force
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
	static vAutoExecDummy := StartMonitoringProcesses() ; TL:DR -> This makes self-execution for functions possible, but it has a few problems...
	
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

_updateOverlay(clearText := false, profileEXE := "") {
	static vOverlayDummy := false
	static notifications := []

	if (!vOverlayDummy) {
		static overlayWindow := new gDip.Window({ "width": 235, "height": 75 })
		overlayWindow.styleSheetInsert(new gDip.StyleSheet(
		(Join
			"#main", {
				"text-align": "right",
				"vertical-align": "top",
				"border-color": "rgb(0, 0, 255)",
				"border-width": "2px"
			},
			".square-body", {
				"width": "225px", 
				"height": "75px", 
				"background-color": "rgba(0, 0, 0, 0.8)",
				"color": "rgba(255, 0, 0, 1)",
				"font-size": "16px"
			}
		)))
		overlayWindow.shapeInsert("#main.square-body")
		
		SetTimer, RefreshTemperatures, 1000
		vOverlayDummy := true
	}
	
	if (clearText) {
		SetTimer, RefreshTemperatures, Delete
		return overlayWindow.Clear()
	}
		
	notifications := []
	notifications.push("Current Profile: " . (ThrottleProfile.getActiveStatus() == "ON" ? ThrottleProfile.getActiveProfile() : "Disabled"))
	notifications.push("Current CPU-Multiplier: " . ThrottleMultiplier.get())
	notifications.push("Current Temp's: " . Temperatures.get() . "°C")
		
	overlayWindow.shapeMatch("#main").text(Utility.Join("`n", notifications))
	overlayWindow.Update({ x: (A_ScreenWidth - overlayWindow.width), y: 100 })
	return overlayWindow
		
	RefreshTemperatures:
		notifications[3] := "Current Temp's: " . Temperatures.get() . "°C"
		overlayWindow.shapeMatch("#main").text(Utility.Join("`n", notifications))
		overlayWindow.Update()
	return	
}

; _updateOverlay(clearText := false, profileEXE := "") {
	; static temperatureRefresher := false

	; if (clearText) {
		; DrawText(,-1) ; Clear all messages...
		; SetTimer, DrawTemps, Delete
		; temperatureRefresher := false
		; return 
	; }
		
	; DrawText("Current Profile: " . (ThrottleProfile.getActiveStatus() == "ON" ? ThrottleProfile.getActiveProfile() : "Disabled"), 1)
	; DrawText("Current CPU-Multiplier: " . ThrottleMultiplier.get(), 2)
	; DrawText("Current Temp's: " . Temperatures.get() . "°C", 3)
	; if (profileEXE)
		; DrawText("Current FPS Limit: " . Format("{1:0.3f}", RTSS.getFPS(profileEXE) / 1000), 4)
		
	; if (temperatureRefresher)
		; return
	
	; SetTimer, DrawTemps, 1000
	; temperatureRefresher := true
	; return
	
	; DrawTemps:
		; DrawText("Current Temp's: " . Temperatures.get() . "°C", 3)
	; return	
; }

_ThrottlePerformance(wndTitle, multiplier := "") { ; On the fly "CoolDown" hotkey function
	static toggleThrottleMode := false
	if (WinExist(ThrottleMisc.exeProcess)) {
		currentProfile := toggleThrottleMode ? "Game" : "Battery"
		ThrottleProfile.set(currentProfile).setActiveStatus("ON")
		; RTSS.replaceFPS(wndTitle, toggleThrottleMode ? 59935 : 30000).applyChanges()
		toggleThrottleMode := !toggleThrottleMode
		_updateOverlay()
	}
}

; ----------------------

; this = { wndTitle: String, trigger: String, isRunning: Boolean, callbackNames: String|Array }
PowerManager1_ON(this) {
	global
	if (WinExist(ThrottleMisc.exeProcess)) {
		ThrottleMisc.clearTempLogs()
		ThrottleProfile.set("Game").setActiveStatus("ON")
		ThrottleMultiplier.set(25)
		_updateOverlay()
	}
}

PowerManager1_OFF(this, temperatureThreshold := 60) {
	global
	if (WinExist(ThrottleMisc.exeProcess)) {
		if (Temperatures.get() > temperatureThreshold) {
			ThrottleProfile.set("Battery").setActiveStatus("ON")
		} else {
			ThrottleProfile.set("Internet").setActiveStatus("OFF")
		}
		_updateOverlay(true)
	}
}

; ----------------------

PowerManager2_ON(this) {
	global
	if (WinExist(ThrottleMisc.exeProcess)) {
		ThrottleMisc.clearTempLogs()
		ThrottleProfile.set("Internet").setActiveStatus("ON")
		; ThrottleMultiplier.set(25)
	}
}

PowerManager2_OFF(this, temperatureThreshold := 60) {
	global
	if (WinExist(ThrottleMisc.exeProcess)) {
		if (Temperatures.get() > temperatureThreshold) {
			ThrottleProfile.set("Battery").setActiveStatus("ON")
		} else {
			ThrottleProfile.set("Internet").setActiveStatus("OFF")
		}
		_updateOverlay(true)
	}
}

; ----------------------

PowerManager3_ON(this, cpuMultiplier := 19) { ; Game "Creative Destruction" profile
	global
	
	DetectHiddenWindows, Off
	if (WinExist(ThrottleMisc.exeProcess)) {
		ThrottleMisc.clearTempLogs()
		ThrottleProfile.set("Game").setActiveStatus("ON")
		ThrottleMultiplier.set(cpuMultiplier)
		_updateOverlay()
	}
	
	if (WinExist("Creative Destruction")) { ; Because "Creative Destruction" and "Blade and Soul" has the same process name...
		static isCalled := false
		if (isCalled)
			return

		DynamicKey.bind("*XButton2", "_ThrottlePerformance", this.wndTitle, cpuMultiplier)

		; Utility.changeResolution(1360, 768)
		; Notify(notifyProcessID, "Changing Desktop Resolution to enhance Creative Destruction experience.")

		Utility.AHKScript("C:\Users\Manciuszz\Desktop\AHK\Project-Aim Assistance.ahk").open()
		WatchDog.notify(this.wndTitle, "Creative Destruction Enhancer loaded.")
		
		Utility.AHKScript("C:\Users\Manciuszz\Desktop\AHK\PixelAimAssistance.ahk").open()
		WatchDog.notify(this.wndTitle, "Creative Destruction Aim Assistance loaded.")
		
		Utility.setProcessCPUPriority("client", "High")
		WatchDog.notify(this.wndTitle, "Application CPU priority has been set to 'High'.")
		
		isCalled := true
	}	
}

PowerManager3_OFF(this, temperatureThreshold := 60) {
	global

	DetectHiddenWindows, Off
	if (WinExist(ThrottleMisc.exeProcess)) {
		if (Temperatures.get() > temperatureThreshold) { ; To allow faster cooling down after done playing games...
			ThrottleProfile.set("Battery").setActiveStatus("ON")
		} else {
			ThrottleProfile.set("Internet").setActiveStatus("OFF")
		}
		_updateOverlay()
	}
	
	if !(WinExist("Creative Destruction")) {
		Utility.AHKScript("C:\Users\Manciuszz\Desktop\AHK\Project-Aim Assistance.ahk").close()
		Utility.AHKScript("C:\Users\Manciuszz\Desktop\AHK\PixelAimAssistance.ahk").close()
		WatchDog.notify(this.wndTitle, "Closed Creative Destruction Enhancer")
		DynamicKey.unbind("*XButton2")
		RTSS.toggleDisplay(true)
		_updateOverlay(true)
	}
}

; -----------  PSEUDO COROUTINES END HERE --------------

+^WheelUp:: ThrottleMultiplier.increase(), _updateOverlay()
+^WheelDown:: ThrottleMultiplier.decrease(), _updateOverlay()

; #If WinExist(ThrottleMisc.exeProcess) ; ThrottleStop context-sensitive hotkeys...
; *Insert:: Reload
; *PgDn:: return