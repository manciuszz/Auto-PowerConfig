; Note: Apparently 'ControlClick' works only when user mouse is inside this application window due to the app having internal MouseInside checks...
class SilentOption { ; NOTE: Should be ran as an administrator to function properly.	
	static _ := SilentOption.base := SilentOption.new()
	static exeProcess := "ahk_exe SilentOption.exe"
	static _offset := ""
  
	class CPU extends SilentOption {		
		static simpleMode() {
			if (WinExist(this.exeProcess)) {
				this.maximize() ; ... so we maximize the window, so that we wouldn't need to physically move our mouse...
				this.click(270, 280) ; Press 'Simple Mode' button
				return this
			}
			return this._error("Failed to activate simple mode!")
		}
		
		static advancedMode() {
			if (WinExist(this.exeProcess)) {
				this.maximize()
				this.click(660, 655) ; Press 'Advanced Mode' button
				return this
			}
			return this._error("Failed to activate advanced mode!")
		}
	}
	
	class GPU extends SilentOption {
		static simpleMode() {
			if (WinExist(this.exeProcess)) {
				; TODO ...
				return this
			}
			return this._error("Failed to activate simple mode!")
		}
		
		static advancedMode() {
			if (WinExist(this.exeProcess)) {
				; TODO ...
				return this
			}
			return this._error("Failed to activate advanced mode!")
		}
	}
	
	applySettings() {
		if (WinExist(this.exeProcess)) {
			this.maximize()
			this.click(1050, 480) ; Press 'Apply'
			Sleep(1)
			this.click(570, 355) ; Press 'OK'
			return ErrorLevel
		}
		return this._error("Failed to apply settings!")
	}
	
	_error(msg) {
		MsgBox("[SilentOption API] > " . msg)
		return {}
	}
	
	getWindowInfo() {
		WinGetPos(win_x, win_y, win_width, win_height, this.exeProcess)
		return { x: win_x, y: win_y, width: win_width, height: win_height }
	}
	
	_initOffset() {
		if (this._offset)
			return
		this._offset := this.getWindowInfo()
	}
	
	maximize() {
		this._initOffset()
		WinMaximize(this.exeProcess)
	}
	
	focus() {
		this._initOffset()
		; ControlFocus,, % this.exeProcess
		WinActivate(this.exeProcess)
	}
	
	click(x, y, speed := 0) {
		windowData := this.getWindowInfo()
		x := x // (this._offset.width / windowData.width)
		y := y // (this._offset.height / windowData.height)
		
		MouseGetPos(lastX, lastY)
		this.focus()
		MouseMove(x, y, speed)
		ControlClick("x" . x . " y" . y, this.exeProcess,,,, "NA")
		MouseMove(lastX, lastY, speed)
	}
}