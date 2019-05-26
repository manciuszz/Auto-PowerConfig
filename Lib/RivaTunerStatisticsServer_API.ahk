#Include <Utility>

class RTSS {
	static exeProcess := "ahk_exe RTSS.exe"
	
	getProfileConfig(profileEXE := "") {
		return Utility.getProcessPath("Profiles\" . profileEXE . ".cfg", this.exeProcess)
	}

	getFPS(profileEXE) {
		IniRead, currentFPS, % this.getProfileConfig(profileEXE), Framerate, Limit
		return currentFPS
	}

	replaceFPS(profileEXE, fpsLimit := 0) {
		IniWrite, %fpsLimit%, % this.getProfileConfig(profileEXE), Framerate, Limit
		return this
	}
	
	toggleDisplay(forceState := "") {
		static isHidden := false
		isHidden := (forceState != "" ? forceState : !isHidden)
		if (isHidden) {
			WinShow, RivaTunerStatisticsServer
		} else {
			WinHide, RivaTunerStatisticsServer
		}
		return this
	}

	applyChanges() {
		if !(WinExist(this.exeProcess))
			return
		this.toggleDisplay(false)
		ControlClick, , RivaTunerStatisticsServer
		ControlClick, x325 y375, RivaTunerStatisticsServer
		WinMinimize, RivaTunerStatisticsServer
		return this
	}
}