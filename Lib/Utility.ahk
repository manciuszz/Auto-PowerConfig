class Logger {
	static _logQueue := []

	_startConsole() {
		global h_Stdout
		static is_open = 0  
		if (is_open = 1)    
			return
		 
		is_open := 1	
		DllCall("AttachConsole", int, -1, int)
		DllCall("AllocConsole", int)

		DllCall("SetConsoleTitle", "str","[AHK] Debug Console")
		h_Stdout := DllCall("GetStdHandle", "int", -11)
		WinSet, Bottom,, ahk_id %h_stout% 
		; WinMinimize % "ahk_id " DllCall("GetConsoleWindow", "ptr")
		return
	}

	obj2Str(obj) { ; Credits to whoever wrote this
		linear := this._isLinear(obj)
		For e, v in obj {
			if (linear == False) {
				if (IsObject(v)) 
				   r .= e ":" this.obj2Str(v) ", "        
				else {                  
					r .= e ":"  
					if v is number 
						r .= v ", "
					else 
						r .= """" v """, " 
				}            
			} else {
				if (IsObject(v)) 
					r .= this.obj2Str(v) ", "
				else {          
					if v is number 
						r .= v ", "
					else 
						r .= """" v """, " 
				}
			}
		}
		return linear ? "[" trim(r, ", ") "]" 
					 : "{" trim(r, ", ") "}"
	}

	_isLinear(obj) {
		n := obj.count(), i := 1   
		loop % (n / 2) + 1
			if (!obj[i++] || !obj[n--])
				return 0
		return 1
	}

	_printBox() {
		MsgBox % this.obj2Str(this._logQueue)
	}
	
	_printConsole() {
		global h_stdout
		this._startConsole()
		str := this.obj2Str(this._logQueue) . "`n"
		FileAppend %str%, CONOUT$
		WinSet, Bottom,, ahk_id %h_stout%
	}
	
	print(str) {
		global h_stdout
		this._startConsole()
		str .= "`n"
		FileAppend %str%, CONOUT$
		WinSet, Bottom,, ahk_id %h_stout%
	}
	
	_debugWrapper(output) { ; Proxy method to log other function outputs and print them out fast
		if (this.logResult) {
			this.logResult := false
			this._logQueue.Push(output)
			this._printConsole()
			this._logQueue := []
		}
		return output
	}
	
	log {
		get {
			this.logResult := true
			return this	
		}
	}
}
	
class Utility extends Logger {
	runSelfAsAdministrator() {
		if not A_IsAdmin {
			Run *RunAs "%A_ScriptFullPath%"
			ExitApp
		}
	}
	
	launchProcess(fileEXE) {
		static configPath := A_WorkingDir . "\" . "config.ini"
		processAlreadyLoaded := false

		filePath := this.getProcessPath(fileEXE, "ahk_exe " . fileEXE) ; Check if the process is already launched
		if (filePath)
			processAlreadyLoaded := true
					
		if (!filePath) ; Check if we got the process path stored inside the configuration file.
			IniRead, filePath, % configPath, FilePaths, %fileEXE%, %A_Space%
	
		if !(filePath) {
			Loop, Files, %fileEXE%, R ; Check if its near our main .ahk file
			{
				filePath := A_LoopFileLongPath
				break
			}
		}
			
		if !(filePath) ; When all else fails, make the user manually point us to the file...
			FileSelectFile, filePath, 3, %fileEXE%, Select the executable file, %fileEXE% (*.exe)

		if (filePath && InStr(filePath, fileEXE)) { ; Check if valid and store it inside the configuration file for future use...
			if (FileExist(filePath)) { ; The path from configuration file could not exist at some point...
				IniWrite, %filePath%, % configPath, FilePaths, %fileEXE% ; Should we always force update the config file? hmm..
				if !(processAlreadyLoaded)
					return this.runFile(filePath)
			} else {
				IniDelete, % configPath, FilePaths , %fileEXE%
				this.launchProcess(fileExe) ; Retry
			}
		}
	}
	
	runFile(filePath) {
		Run, % filePath			
		return this
	}
	
	findTextInsideControlWindow(SearchText) {
		if !(SearchText) {
			MsgBox % "Input required!"
			return
		}			
			
		WinGet, List, ControlList, A
		Loop, Parse, List, `n
		{
			ControlGetText, Text, %A_LoopField%, A
			If (Text = SearchText)
				MsgBox ClassNN: %A_LoopField%
		}
		return this
	}
	
	getProcessPath(fileName := "", processEXE := "A") {
		DetectHiddenWindows, On
		WinGet, foundPath, ProcessPath, % processEXE
		SplitPath, foundPath,, processDir
		return this._debugWrapper(processDir . (processDir && fileName ? "\" . fileName : ""))
	}
	
	_rawArray(params*) {
		if (!params.Length())
			str := "'""""''"
		for index, param in params
			str .= "'" . param . "',"
		return SubStr(str, 1, StrLen(str) - 1)
	}
	
	; setPowerPlan(powerPlan) {
		;; powercfg -list
		; static powerConfigs := { "Consistent Performance": "2d68a000-50f6-404d-8c14-d9d96e2b7aa6"
					 ; ,"Downclocked Performance": "517b87a5-680a-4051-aae3-56be073450a1" }
		; GUID := powerConfigs[powerPlan]
		; Run, powercfg -s %GUID%,, Hide
	; }
	
	setExplorerState(CMD := "Kill") {
		if ( CMD == "Kill" ) {
			RunWait, taskkill /F /IM explorer.exe,, Hide
		} else if ( CMD == "Start") {
			RunWait, cmd /c start "" "%windir%\explorer.exe",, Hide
		}
	}
	
	restoreServiceAffinity(serviceName, affinity := 255) {
		RunWait, PowerShell "Get-Process -Id (get-wmiobject Win32_service | where Name -eq '%serviceName%' | `% { $_.ProcessId }) | `% { $_.ProcessorAffinity=%affinity% }",, Hide
	}

	setProcessorAffinity(affinity := 255, excludedProcesses*) {
		processList := this._rawArray(excludedProcesses*)
		RunWait, PowerShell "Get-Process | `% { $p = $_; $m = $FALSE; (%processList%) | `% { if ($p.ProcessName -match $_) { $m = $TRUE } }; if ( $m -ne $TRUE ) { $_.ProcessorAffinity=%affinity% } }",, Hide
	}
	
	setProcessCPUPriority(Process, Priority = "Normal") {
		; WinWait, ahk_exe %Process%.exe ; Note: Can't detect hidden processes.
		RunWait, PowerShell "Get-Process %Process% | `% { $_.PriorityClass = '%Priority%' }",, Hide
	}
	
	changeResolution(screenWidth := 1920, screenHeight := 1080, colorDepth := 32) { ; Note: Works only on supported resolutions, in other words, no 801x601 and etc..
		VarSetCapacity(deviceMode, 156, 0)
		NumPut(156, deviceMode, 36) 
		DllCall("EnumDisplaySettingsA", UInt, 0, UInt, -1, UInt, &deviceMode)
		NumPut(0x5c0000, deviceMode, 40) 
		NumPut(colorDepth, deviceMode, 104)
		NumPut(screenWidth, deviceMode, 108)
		NumPut(screenHeight, deviceMode, 112)
		return DllCall("ChangeDisplaySettingsA", UInt, &deviceMode, UInt, 0)
	}
	
	AHKScript(filePath) {
		return { open: Func(this._AHKScript_Internals.Name).Bind(this, "Open", filePath), close: Func(this._AHKScript_Internals.Name).Bind(this, "Close", filePath) } 
	}
	
	_AHKScript_Internals(labelName, filePath) {
		Goto, %labelName%
		
		Open:
			this.runFile(filePath)
		Return
				
		Close:
			DetectHiddenWindows, On
			WinClose, %filePath% ahk_class AutoHotkey
		Return
	}
}