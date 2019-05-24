#Include <Utility>

class RTSS {
	static exeProcess := "ahk_exe RTSS.exe"
	
	getProfileConfig(profileEXE := "") {
		return Utility.getProcessPath("Profiles\" . profileEXE . ".cfg", this.exeProcess)
	}

	replaceFPS(profileEXE, fpsLimit := 0) {
		IniWrite, %fpsLimit%, % this.getProfileConfig(profileEXE), Framerate, Limit
		return this
	}

	applyChanges() {
		DetectHiddenWindows, Off
		; WinActivate, % this.exeProcess
		ControlClick,, % this.exeProcess
		WinMinimize, % this.exeProcess
		return this
	}
}