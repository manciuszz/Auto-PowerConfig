class ThrottleMisc {
	static _ := ThrottleMisc.base := ThrottleMisc.new()
	static CLR := Object("buttonId", "Button25")
	static exeProcess[] => "ahk_id " ThrottleUtility.WinExist("ahk_exe ThrottleStop.exe")
		
	; TODO?: Add misc settings cache store to track statuses
	toggle(settingArrays*) {
		for index, settingArr in settingArrays {
			this["toggle" . settingArr[1]].Call(settingArr[2])
		}	
	}

	togglePowerSaver(forceStatus) {
		MsgBox(forceStatus)
		return this
	}
	
	toggleDisableTurbo() {
		return this
	}
	
	toggleSpeedStep() {
		return this
	}

	toggleBD_PROCHOT() {
		return this
	}

	toggleTaskBar() {
		MsgBox("TaskBar")
	}
	
	toggleLogFile() {
		return this
	}
	
	toggleC1E() {
		return this
	}
	
	toggleOnTop() {
		return this
	}
	
	toggleMoreData() {
		return this
	}
	
	toggleStopData() {
		return this
	}
	
	clearTempLogs() {
		ControlClick(this.CLR.buttonId, ThrottleMisc.exeProcess)
		return this
	}
}
	
class ThrottleMultiplier {
	static _ := ThrottleMultiplier.base := ThrottleMultiplier.new()
	static multiplier := ThrottleMultiplier.__multiplierButtonsInit()

	static __multiplierButtonsInit() {
		multiplier := Object()
		multiplier.valueControl := Object("buttonId", "Edit1")
		multiplier.controller := Object("buttonId", "msctls_updown323")
		multiplier.toggleControl := Object("buttonId", "Button7")
		return multiplier
	}
	
	get() {
		currentValue := ControlGetText(this.multiplier.valueControl.buttonId, ThrottleMisc.exeProcess)
		return StrReplace(currentValue, " T", "")
	}
			
	set(minValue := 8) {
		currentMultiplier := this.get()
		if (minValue > currentMultiplier) {
			this.increase()
		} else if (minValue < currentMultiplier) {
			this.decrease()
		} else {
			return this
		}
		Sleep(1)
		this.set(minValue)
	}
		
	getToggleStatus() {
		toggleStatus := ControlGetChecked(this.multiplier.toggleControl.buttonId, ThrottleMisc.exeProcess)
		return (toggleStatus)
	}
	
	setToggle() {
		ControlClick(this.multiplier.toggleControl.buttonId, ThrottleMisc.exeProcess)
		return this
	}
		
	increase() {
		ControlClick(this.multiplier.controller.buttonId, ThrottleMisc.exeProcess,,,, "NA x33 y10")
		return this
	}

	decrease() {
		ControlClick(this.multiplier.controller.buttonId, ThrottleMisc.exeProcess,,,, "NA x10 y10")
		return this
	}
}

class ThrottleProfile {
	static _ := ThrottleProfile.base := ThrottleProfile.new()

	static activateProfileToggle := Object("buttonId", "Button21")
	static currentProfile := Object("buttonId", "Button22")
	static optionsButton := Object("buttonId", "Button20", "winTitle", "Options")
	static profileFields := Map("Edit1", "Button1", "Edit2", "Button2", "Edit3", "Button3", "Edit4", "Button4")

	; _openOptions() {
		; ClassNN := this.optionsButton.buttonId
		; winTitle := this.optionsButton.winTitle
		; ControlClick, %ClassNN%, % ThrottleMisc.exeProcess ; Open 'Options' window
		; WinWait, %winTitle%
	; }
	
	; _closeOptions() {
		; winTitle := this.optionsButton.winTitle
		; ControlClick, Button2, %winTitle% ; Click 'Cancel' button inside 'Options' window.
	; }
	
	; getProfiles() {
		; this._openOptions()
		; profileMap := {}
		; for fieldId, buttonId in this.profileFields {
			; ControlGetText, profileName, %fieldId%, % ThrottleMisc.exeProcess
			; profileMap[profileName] := buttonId
		; }	
		; this._closeOptions()	
		; return profileMap	
	; }
	
	getProfiles(selectedProfile := "") { ; Is a singleton
		static profileMap := Map()
		
		if (profileMap.Capacity > 0)
			return profileMap[selectedProfile]
					
		Loop 4 {
			profileName := "ProfileName" . A_Index
			profileName := IniRead(Utility.GetProcessPath("ThrottleStop.ini", ThrottleMisc.exeProcess), "ThrottleStop", profileName)
			profileMap[profileName] := this.profileFields["Edit" . A_Index]
		}
					
		return profileMap[selectedProfile]
	}
	
	getActiveProfile() {
		activeProfile := ControlGetText(this.currentProfile.buttonId, ThrottleMisc.exeProcess)
		return activeProfile
	}
	
	set(selectedProfile := "") {
		if (this.getActiveProfile() == selectedProfile)
			return this
						
		ControlClick(this.getProfiles(selectedProfile), ThrottleMisc.exeProcess)
		return this
	}
	
	getActiveStatus() {
		static statusRemap := Map("ON", "OFF", "OFF", "ON")
		currentStatus := ControlGetText(this.activateProfileToggle.buttonId, ThrottleMisc.exeProcess)
		trimmedStatus := StrReplace(currentStatus, "Turn ", "")
		upperCaseStatus := StrUpper(trimmedStatus)
		return statusRemap[upperCaseStatus]
	}
	
	setActiveStatus(forceStatus := "") {
		if (forceStatus != "") {
			currentStatus := this.getActiveStatus()
			if (forceStatus == currentStatus)
				return this
		}
			
		ControlClick(this.activateProfileToggle.buttonId, ThrottleMisc.exeProcess)
		return this
	}
		
}

class Temperatures {
	static _ := Temperatures.base := Temperatures.new()

	static temperatureClassNN := "Edit11"

	get() {
		currentTemp := ControlGetText(this.temperatureClassNN, ThrottleMisc.exeProcess)
		return StrReplace(currentTemp, "°C", "")
	}
}

class ThrottleUtility {
	static WinExist(wnd) {	
		DetectHiddenWindows False
		windowExist := WinExist(wnd)
		if (windowExist)
			return windowExist
			
		DetectHiddenWindows True
		windowExist := WinExist(wnd)
		if (!windowExist)
			DetectHiddenWindows False
		return windowExist
	}
	
	static WinActive(wnd) {
		DetectHiddenWindows False
		windowExist := WinActive(wnd)
		if (windowExist)
			return windowExist
			
		DetectHiddenWindows True
		windowExist := WinActive(wnd)
		if (!windowExist)
			DetectHiddenWindows False
		return windowExist
	}
}