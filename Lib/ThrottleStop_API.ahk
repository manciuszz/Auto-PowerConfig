#Include <Utility>
	
class ThrottleMisc {
	static CLR := { "buttonId": "Button25" }
	static exeProcess := "ahk_exe ThrottleStop.exe"
		
	; TODO?: Add misc settings cache store to track statuses
	toggle(settingArrays*) {
		for index, settingArr in settingArrays {
			this["toggle"settingArr.1](settingArr.2)
		}	
	}

	togglePowerSaver(forceStatus) {
		MsgBox % forceStatus
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
		MsgBox % "TaskBar"
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
		ControlClick, % this.CLR.buttonId, % ThrottleMisc.exeProcess
		return this
	}
}
	
class ThrottleMultiplier extends Logger {
	static multiplier := { "valueControl": { "buttonId": "Edit1" }, "controller": { "buttonId": "msctls_updown323" }, "toggleControl": { "buttonId": "Button7" } }
	
	get() {
		ControlGetText, currentValue, % this.multiplier.valueControl.buttonId, % ThrottleMisc.exeProcess
		return this._debugWrapper(StrReplace(currentValue, " T", ""))
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
		Sleep, 1
		this.set(minValue)
	}
		
	getToggleStatus() {
		ControlGet, toggleStatus, Checked,, % this.multiplier.toggleControl.buttonId, % ThrottleMisc.exeProcess
		return this._debugWrapper(toggleStatus)
	}
	
	setToggle() {
		ControlClick, % this.multiplier.toggleControl.buttonId, % ThrottleMisc.exeProcess
		return this
	}
		
	increase() {
		ControlClick, % this.multiplier.controller.buttonId, % ThrottleMisc.exeProcess,,,, NA x33 y10
		return this
	}

	decrease() {
		ControlClick, % this.multiplier.controller.buttonId, % ThrottleMisc.exeProcess,,,, NA x10 y10
		return this
	}
}

class ThrottleProfile extends Logger {
	static currentProfile := { "buttonId": "Button22" }
	static optionsButton := { "buttonId": "Button20", "winTitle": "Options" }
	static profileFields := { "Edit1": "Button1", "Edit2": "Button2", "Edit3": "Button3", "Edit4": "Button4" }
	static activateProfileToggle := { "buttonId": "Button21" }

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
		static profileMap := {}
		if (profileMap.GetCapacity() > 0)
			return this._debugWrapper(profileMap)[selectedProfile]
					
		Loop 4 {
			profileName := "ProfileName" . A_Index
			IniRead, profileName, % Utility.getProcessPath("ThrottleStop.ini", ThrottleMisc.exeProcess), ThrottleStop, %profileName%
			profileMap[profileName] := this.profileFields["Edit"A_Index]
		}
					
		return this._debugWrapper(profileMap)[selectedProfile]
	}
	
	getActiveProfile() {
		ControlGetText, activeProfile, % this.currentProfile.buttonId, % ThrottleMisc.exeProcess
		return this._debugWrapper(activeProfile)
	}
	
	set(selectedProfile := "") {
		if (this.getActiveProfile() == selectedProfile)
			return this
						
		ControlClick, % this.getProfiles(selectedProfile), % ThrottleMisc.exeProcess
		return this
	}
	
	getActiveStatus() {
		static statusRemap := { "ON": "OFF", "OFF": "ON" }
		ControlGetText, currentStatus, % this.activateProfileToggle.buttonId, % ThrottleMisc.exeProcess
		trimmedStatus := StrReplace(currentStatus, "Turn ", "")
		StringUpper, upperCaseStatus, trimmedStatus
		return this._debugWrapper(statusRemap[upperCaseStatus])
	}
	
	setActiveStatus(forceStatus := "") {
		if (forceStatus != "") {
			currentStatus := this.getActiveStatus()
			if (forceStatus == currentStatus)
				return this
		}
			
		ControlClick, % this.activateProfileToggle.buttonId, % ThrottleMisc.exeProcess
		return this
	}
		
}

class Temperatures extends Logger {
	static temperatureClassNN := "Edit11"

	get() {
		ControlGetText, currentTemp, % this.temperatureClassNN, % ThrottleMisc.exeProcess
		return this._debugWrapper(StrReplace(currentTemp, "°C", ""))
	}
}