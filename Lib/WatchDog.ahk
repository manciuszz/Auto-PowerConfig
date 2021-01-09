class WatchDog {
	static notificationDelay := 2000
	static checkPeriod := 1000
	static tooltipPrefix := "Power Manager ->"

	notificationDelay := WatchDog.notificationDelay
	checkPeriod := WatchDog.checkPeriod
	tooltipPrefix := WatchDog.tooltipPrefix
	
	__New(configObj) {
		this.callbackMethods := type(configObj) == "Class" ? configObj.new() : configObj
		this.wndTitle := ""
		this.trigger := "Active"
		this.isRunning := false
	}
	
	Notify(msg) {
		wndTitle := StrUpper(StrReplace(this.wndTitle, "ahk_exe "))
		TrayTip(this.tooltipPrefix . " " . wndTitle, msg, "Mute")
		SetTimer(Func("TrayTip"), -this.notificationDelay)
		; Sleep(this.notificationDelay)
		; TrayTip()
		return this
	}
	
	Monitor(window, trigger := "Active") {
		this.wndTitle := "ahk_exe " . window
		this.trigger := trigger
		
		if (WatchDog.Utility.WinExist(this.wndTitle))
			this.Notify("Checking for: " . this.trigger)
			
		return this._run()
	}
	
	_run() {
		SetTimer(ObjBindMethod(this, "_runner"), this.checkPeriod)
		return this		
	}
	
	_goSubSafe(mySub) {		
		if (type(this.callbackMethods) == "Object") {
			method := this.callbackMethods.%mySub%
			if (method.MaxParams == 1)
				method.Call(this)
			else
				method.Call()
		} else {
			if (type(this.callbackMethods.base) == "Prototype")
				this.callbackMethods.GetMethod(mySub).Call(this)
		}
	}
	
	_runner() {	
		if (A_IsSuspended)
			return
	
		if (!this.isRunning != !WatchDog.Utility.Win%this.trigger%(this.wndTitle)) {
			this.isRunning := !this.isRunning
			this._goSubSafe(this.isRunning ? "On" : "Off")
		}
	}
	
	class Utility {
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
}