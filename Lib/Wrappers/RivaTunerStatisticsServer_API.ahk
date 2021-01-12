class RTSS { ; NOTE: Requires to be ran as Administrator in order to function properly.
	static _cache := {}

	static exeProcess := "ahk_exe RTSS.exe"
	
	activeProfile(profileEXE) {
		if (profileEXE == "")
			return
			
		this.profileEXE := RegExReplace(profileEXE, "ahk_.*\s+", "")
		this._cache[ this.profileEXE ] := {}
		return this
	}
	
	getProfileConfigPath(profileEXE := "") {
		this.activeProfile(profileEXE)
		return this.__getProcessPath("Profiles\" . this.profileEXE . ".cfg", this.exeProcess)
	}
	
	readValueFromProfile(section, key, profileEXE) {
		IniRead, value, % this.getProfileConfigPath(profileEXE), % section, % key
		return value
	}
	
	writeValueToProfile(section, key, value, profileEXE) {
		if (value == this._cache[ this.profileEXE ][section, key])
			return
			
		IniWrite, % value, % this.getProfileConfigPath(profileEXE), % section, % key
		this._cache[ this.profileEXE ][section, key] := value
		return this
	}
	
	getFPS(profileEXE := "") {
		return this.readValueFromProfile("Framerate", "Limit", profileEXE)
	}

	replaceFPS(fpsLimit := 0, profileEXE := "") {
		this.writeValueToProfile("Framerate", "LimitDenominator", (fpsLimit > 1000 ? 1000 : 1), profileEXE) 		
		this.writeValueToProfile("Framerate", "Limit", fpsLimit, profileEXE)
		this.updateProfile()
		return this
	}
	
	getScanline(scanLine := 0, profileEXE := "") {
		return this.readValueFromProfile("Framerate", "SyncScanline" . scanLine, profileEXE)
	}
	
	adjustScanline(scanLineValue := 0, scanLine := 0, profileEXE := "") {
		this.writeValueToProfile("Framerate", "SyncScanline" . scanLine, scanLineValue, profileEXE)
		this.updateProfile()
		return this
	}
	
	toggleFrameColorBar(barType := 2, profileEXE := "") {
		this.writeValueToProfile("OSD", "FrameColorBarsNum", barType, profileEXE)
		this.writeValueToProfile("OSD", "EnableFrameColorBar", !this.readValueFromProfile("OSD", "EnableFrameColorBar", profileEXE), profileEXE)
		this.updateProfile()
		return this
	}

	toggleScanInfo() {
		this.writeValueToProfile("OSD", "SyncInfo", !this.readValueFromProfile("OSD", "SyncInfo", profileEXE), profileEXE)
		this.updateProfile()
		return this
	}
	
	toggleDisplay(forceState := "") {
		static isHidden := false
		
		isHidden := (forceState != "" ? forceState : !isHidden)
		
		if (isHidden) {
			this.restoreWindow()
		} else {
			this.minimizeWindow()
		}
		return this
	}
	
	restoreWindow() {
		WinSet, Top,, % this.exeProcess
		; PostMessage, 0x112, 0xF120,,, % this.exeProcess
	}
	
	minimizeWindow() {
		WinSet, Bottom,, % this.exeProcess
		; PostMessage, 0x112, 0xF020,,, % this.exeProcess
	}
	
	applyChanges() {
		static toggleStates := { MINIMIZE: 0, MAXIMIZE: 1 }

		if (!WinExist(this.exeProcess))
			return this
		
		DetectHiddenWindows, Off
		WinGetTitle, rtssTitle, % this.exeProcess
		this.toggleDisplay(toggleStates.MINIMIZE)
		ControlClick, ListBox1, % rtssTitle,,,, NA
		return this
	}
	
	updateProfile() {
		Send, !{NumpadDel} ; Hotkey bound to "ALT + NumpadDel" inside RTSS to add 0 to FramerateLimit, which is workaround in order to update ALL profiles.
		return this
	}
	
	__getProcessPath(fileName := "", processEXE := "A") {
		DetectHiddenWindows, On
		WinGet, foundPath, ProcessPath, % processEXE
		SplitPath, foundPath,, processDir
		return processDir . (processDir && fileName ? "\" . fileName : "")
	}
}

; Used when doing standalone testing
; #Persistent

; global profileName := "Darwin-Win64-Shipping.exe"
; RTSS.getProfileConfig(profileName)
; #If WinActive("ahk_exe " . profileName)
; ^Up:: RTSS.adjustScanline(RTSS.getScanline() + 1)
; ^Down:: RTSS.adjustScanline(RTSS.getScanline() - 1)
; +^Up:: RTSS.adjustScanline(RTSS.getScanline() + 10)
; +^Down:: RTSS.adjustScanline(RTSS.getScanline() - 10)
; #If WinActive("ahk_exe notepad++.exe")
; ^R::Reload
; #If
; +NumpadSub::RTSS.replaceFPS(RTSS.getFPS() - 1)