class SilentOption {
	static exeProcess := "ahk_exe SilentOption.exe"

	simpleMode() {
		if (WinExist(this.exeProcess)) {
			ControlFocus,, % this.exeProcess
			; WinActivate, % this.exeProcess
			MouseGetPos, lastX, lastY
			MouseMove, 280, 280, 0 ; Apparently you have to have your mouse inside the window in order for the Control Click to work...
			ControlClick,, % this.exeProcess,,,, NA x280 y280
			MouseMove, lastX, lastY, 0
			return ErrorLevel
		}
		return "Failed to activate simple mode!"
	}
	
	advancedMode() {
		if (WinExist(this.exeProcess)) {
			ControlFocus,, % this.exeProcess
			; WinActivate, % this.exeProcess
			MouseGetPos, lastX, lastY
			MouseMove, 280, 400, 0 ; Apparently you have to have your mouse inside the window in order for the Control Click to work...
			ControlClick,, % this.exeProcess,,,, NA x280 y400
			MouseMove, lastX, lastY, 0
			return ErrorLevel
		}
		return "Failed to activate advanced mode!"
	}
}