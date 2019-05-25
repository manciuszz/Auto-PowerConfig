class WatchDog {
	static checkPeriod = 1000
	static runnerPrefix := "WatchdogRun"
	static monitoredProcesses := []
	
	run() {
		fn := this["runner"].Bind(this)
		SetTimer, % fn, % this.checkPeriod
		return this		
	}
	
	notify(wnd, msg, delay = 2000) {
		wndTitle := SubStr(wnd, 9)
		StringUpper, wndTitle, wndTitle
		TrayTip, Power Manager - %wndTitle%, % msg
		Sleep % delay
		TrayTip
		return this
	}
	
	monitorWindow(window, trigger := "Active", callbackNames := "") {
		this.monitoredProcesses.Push({ wndTitle: window, trigger: trigger, isRunning: false, callbackNames: callbackNames })	
		if (WinExist(window))
			this.notify(window, "Checking for: " . trigger)
		return this
	}
	
	_goSubSafe(mySub) {
		if IsFunc(mySub) {
			%mySub%()
		}
	}
	
	runner() {	
		for index, monitoredProcess in this.monitoredProcesses {
			windowDetectionType := monitoredProcess.trigger
			if ( !monitoredProcess.isRunning != !Win%windowDetectionType%(monitoredProcess.wndTitle) ) {
				if (!monitoredProcess.callbackNames) {
					this.monitoredProcesses.remove(index)
					MsgBox % "Process '" monitoredProcess.wndTitle "' doesn't have a callbackName"
					continue
				}		
				this._goSubSafe( !!monitoredProcess.callbackNames.MaxIndex() ? ( (monitoredProcess.isRunning := !monitoredProcess.isRunning) ? monitoredProcess.callbackNames.1 : monitoredProcess.callbackNames.2 ) : (monitoredProcess.callbackNames "_O" ( (monitoredProcess.isRunning := !monitoredProcess.isRunning) ? "N" : "FF" ))  )
			}
		}
	}
}