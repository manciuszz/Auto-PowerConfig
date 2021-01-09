class DynamicKey {	
	static Bind(hk, fun, arg*) {
		static funs := {}, args := {}
		funs[hk] := Func(fun), args[hk] := arg
		Hotkey(hk, Hotkey_Handle, "On")
		return
		
		Hotkey_Handle:
			funs[A_ThisHotkey].Call(args[A_ThisHotkey]*)
		return
	}

	static Unbind(hk := "") { ; TODO?: Good practice would be to clear 'funs' array too, but I guess its not that relevant..
		Hotkey((!hk ? A_ThisHotkey : hk), "Off") 
	}
}

class FocusStealPrevention {
	static __vInstance := ""

	static _MyGui := Gui.New("+LastFound")	

	static debugTips := false

	__New() {
		this.previous := -1
		this.current := WinActive("A") 
	}
	
	__shellHook() {
		DllCall("RegisterShellHookWindow", "UInt", FocusStealPrevention._MyGui.Hwnd)
		
		this.MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
		this.shellMessage := ObjBindMethod(this, "ShellMessage")
		OnMessage(this.MsgNum, this.shellMessage)
	}
	
	__shellUnhook() {
		DllCall("DeregisterShellHookWindow", "UInt", FocusStealPrevention._MyGui.Hwnd)
		OnMessage(this.MsgNum, this.shellMessage, 0)
	}
	
	static Enable() {
		if (!FocusStealPrevention.__vInstance)
			FocusStealPrevention.__vInstance := FocusStealPrevention.new()

		FocusStealPrevention.__vInstance.__shellHook()
	}
	
	static Disable() {
		FocusStealPrevention.__vInstance.__shellUnhook()
	}
	
	StopStealing(id) {	
		if (this.current > 0 && this.current != id) {
			WinActivate("ahk_id " . this.current)
			return true
		} else if (this.previous > 0 && this.previous != id) {
			WinActivate("ahk_id " . this.previous)
			return true
		}
		return false
	}

	ShellMessage(wParam, lParam, msg, hwnd) {
		if (wParam = 1) {
			this.lastNewWindow := A_TickCount
			if (this.StopStealing(lParam)) {
				DllCall("FlashWindow", "UInt", lParam, "Int", 1)
				if (FocusStealPrevention.debugTips) {
					Title := Utility.WinGetTitle("ahk_id " . lParam)
					this.ShowTip("Thief: " . Title . " (" . A_TimeIdlePhysical . ")", "Stopped Focus Steal")
				}
			}
		} 
		
		if (lParam > 0 && wParam = 32772) { 
			this.LogCurrent(lParam)
		}
	}
	
	LogCurrent(id) {
		if (id != this.current) {
			this.previous := this.current
			this.current := id
			return true
		}
		return false
	}
	
	ShowTip(title, text := "") {
		TrayTip(text, title, 16)
	}
}

class Suspender {
	static SuspendProcesses(PIDs) {
		for i, processID in PIDs
			this.Process_Suspend(processID)
	}

	static ResumeProcesses(PIDs) {
		for i, processID in PIDs
			this.Process_Resume(processID)
	}

	static Process_Suspend(PID_or_Name) {
		PID := (InStr(PID_or_Name, ".")) ? this.ProcExist(PID_or_Name) : PID_or_Name
		h := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", PID)
		if !h   
			Return -1
		DllCall("ntdll.dll\NtSuspendProcess", "Int", h)
		DllCall("CloseHandle", "Int", h)
	}

	static Process_Resume(PID_or_Name) {
		PID := (InStr(PID_or_Name, ".")) ? this.ProcExist(PID_or_Name) : PID_or_Name
		h := DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", PID)
		if !h   
			Return -1
		DllCall("ntdll.dll\NtResumeProcess", "Int", h)
		DllCall("CloseHandle", "Int", h)
	}

	static GetProcessIDs(processName) {
		processID_list := []
		for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name = '" . processName . "'")
		   processID_list.Push(process.ProcessId)
		return processID_list.Length > 0 ? processID_list : [-1]
	}

	static ProcExist(PID_or_Name := "") {
		return ProcessExist((PID_or_Name == "") ? DllCall("GetCurrentProcessID") : PID_or_Name) != 0
	}
}

class TaskManager {
	static SetExplorerState(state := "Kill") {
		Start() {
			RunWait("cmd /c start `"`" " . "%windir%\explorer.exe",, "Hide")
		}
		
		Kill() {
			RunWait("taskkill /F /IM explorer.exe",, "Hide")
		}
		
		switch state {
			case "Start":
				Start()
			case "Kill":
				Kill()
		}
	}

	static RestoreServiceAffinity(serviceName, affinity := 255) {
		RunWait("PowerShell Get-Process -Id (get-wmiobject Win32_service | where Name -eq '" . serviceName . "' | `% { $_.ProcessId }) | `% { $_.ProcessorAffinity=" . affinity . " }",, "Hide")
	}

	static SetProcessorAffinity(affinity := 255, excludedProcesses*) {
		RawArray(params*) {
			; if (!params.Length)
				; str := "'""""''"
			for index, param in params
				str .= "'" . param . "',"
			return SubStr(str, 1, StrLen(str) - 1)
		}
	
		processList := RawArray(excludedProcesses*)
		RunWait("PowerShell Get-Process | `% { $p = $_; $m = $FALSE; (" . processList . ") | `% { if ($p.ProcessName -match $_) { $m = $TRUE } }; if ( $m -ne $TRUE ) { $_.ProcessorAffinity=" . affinity . " } }",, "Hide")
	}
	
	static SetProcessCPUPriority(Process, Priority := "Normal") {
		; WinWait, ahk_exe %Process%.exe ; Note: Can't detect hidden processes.
		RunWait("PowerShell Get-Process " . Process . " | `% { $_.PriorityClass = '" . Priority . "' }",, "Hide")
	}
}

class Display {
	static ChangeResolution(screenWidth := 1920, screenHeight := 1080, colorDepth := 32) { ; Note: Works only on supported resolutions, in other words, no 801x601 and etc..
		deviceMode := BufferAlloc(156, 0)
		NumPut("int", 156, deviceMode, 36) 
		DllCall("EnumDisplaySettingsA", "UInt", 0, "UInt", -1, "UInt", deviceMode.Ptr)
		
		NumPut("UInt64", 0x5c0000, deviceMode, 40) 
		NumPut("int", colorDepth, deviceMode, 104)
		NumPut("int", screenWidth, deviceMode, 108)
		NumPut("int", screenHeight, deviceMode, 112)
		return DllCall("ChangeDisplaySettingsA", "UInt", deviceMode.Ptr, "UInt", 0)
	}
}

class PowerConfig {
	static _previouslyActive := ""

	static GetPowerPlan(powerPlan := "Balanced") {
		static cachedPlans := false
		
		ParsePlans(rawPowerPlans, regexQuery := "im)Power Scheme GUID: (.*)  \((.*)\)\s?(\*)?") {
			if (cachedPlans)
				return cachedPlans
			
			cachedPlans := Map()
			
			pos := 1
			while (pos && RegExMatch(rawPowerPlans, regexQuery, fields, pos)) {
				GUID := fields[1]
				PowerSchemeName := fields[2]
				Active := fields[3]
				cachedPlans[PowerSchemeName] := GUID
				if (Active)
					cachedPlans["Currently Active"] := { Name: PowerSchemeName, GUID: GUID }
				pos := fields.Pos(2) + 1
			}
			
			return cachedPlans
		}

		rawPowerPlans := Utility.GetShellOutput("cmd.exe /q /c powercfg -l")		
		powerPlanArray := ParsePlans(rawPowerPlans)
	
		result := ""
		try {
			result := powerPlanArray[powerPlan]
		}
		
		return result
	}
	
	static GetPreviousActivePlan() {
		return this._previouslyActive
	}
	
	static SetPowerPlan(powerPlan) {
		this._previouslyActive := PowerConfig.GetPowerPlan("Currently Active")
		Utility.RunCommand("powercfg -s " . PowerConfig.GetPowerPlan(powerPlan))
		return powerPlan
	}
}
	
class Utility {

	static GetShellOutput(cmd, silent := true) {
	
		ShellOutput(inputCmd) {
			return ComObjCreate("WScript.Shell").Exec(inputCmd).StdOut.ReadAll()
		}
		
		SilentOutput(inputCmd) {
			oldHiddenWindowState := A_DetectHiddenWindows
			DetectHiddenWindows True
			Run(A_ComSpec,, "Hide", output_PID)
			WinWait("ahk_pid " . output_PID)
			DllCall("AttachConsole", "UInt", output_PID)
			output := ShellOutput(cmd)
			DllCall("FreeConsole")
			ProcessClose(output_PID)
			DetectHiddenWindows oldHiddenWindowState
			return output
		}
	
		return silent ? SilentOutput(cmd) : ShellOutput(cmd)
	}

	static GetProcessExePath(p_id) {
		for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId=" p_id)
			return process.ExecutablePath
	}
	
	static RunCommand(filePath, optionalArguments := "", silent := true) {
		try {
			Run(filePath . " " . optionalArguments,, silent ? "Hide" : "")
		} catch e {
			if (InStr(e.Message, "Failed attempt to launch program"))
				MsgBox("Failed attempt to launch program: " . filePath . "`n`nPro tip: Open it manually and reload script.")
		}		
		return this
	}

	static ElevateToAdmin() {
		full_command_line := DllCall("GetCommandLine", "str")
		if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
			try {
				if (A_IsCompiled)
					Run '*RunAs "' A_ScriptFullPath '" /restart'
				else
					Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
			}
			ExitApp
		}
	}

	static LaunchProcess(fileEXE, optionalParams := "", silent := true) {
		static configPath := A_WorkingDir . "\Lib\Cache\" . "QuickAccessCache.ini"
		processAlreadyLoaded := false

		filePath := this.GetProcessPath(fileEXE, "ahk_exe " . fileEXE) ; Check if the process is already launched
		if (filePath)
			processAlreadyLoaded := true
							
		if (!filePath) ; Check if we got the process path stored inside the configuration file.
			filePath := IniRead(configPath, "FilePaths", fileEXE, A_Space)

		if (!filePath) {
			Loop Files, fileEXE, "R" { ; Check if its near our main .ahk file
				filePath := A_LoopFileLongPath
				break
			}
		}
			
		if (!filePath) ; When all else fails, make the user manually point us to the file...
			filePath := FileSelect(3, fileEXE, "Select the executable file", fileEXE . " (*.exe)")

		if (filePath && InStr(filePath, fileEXE)) { ; Check if valid and store it inside the configuration file for future use...
			if (FileExist(filePath)) { ; The path from configuration file could not exist at some point...
				IniWrite(filePath, configPath, "FilePaths", fileEXE) ; Should we always force update the config file? hmm..
				if !(processAlreadyLoaded)
					return this.RunCommand(filePath, optionalParams, silent)
			} else {
				IniDelete(configPath, "FilePaths", fileEXE)
				this.LaunchProcess(fileExe, optionalParams, silent) ; Retry
			}
		}
	}
	
	static ExitProcess(ProcessID) {
		ProcessClose(ProcessID)
	}
	
	static GetProcessPath(fileName := "", processEXE := "A") {
		foundPath := ""
		DetectHiddenWindows True
		try {
			foundPath := WinGetProcessPath(processEXE)
		}
		SplitPath foundPath,, processDir
		return processDir . (processDir && fileName ? "\" . fileName : "")
	}
	
	static AHKScript(filePath) {
		static result := {}
		
		if (!FileExist(filePath)) {
			MsgBox("File " . filePath . " not found!")
			return
		}
		
		AHKScript_Internals(labelName) {
			Goto(labelName)
			
			Open:
				this.RunCommand(filePath)
			Return
					
			Close:
				DetectHiddenWindows True
				WinClose(filePath . " ahk_class AutoHotkey")
			Return
		}	
						
		result.DefineMethod("Open", (_) => AHKScript_Internals("Open"))
		result.DefineMethod("Close", (_) => AHKScript_Internals("Close"))
		
		return result
	}
	
	static Join(sep, params) {
		for (param in params)
			str .= sep . param
		return SubStr(str, StrLen(sep)+1)
	}
	
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

	static WinGetTitle(wnd) {
		try {
			DetectHiddenWindows False
			windowTitle := WinGetTitle(wnd)
			if (windowTitle)
				return windowTitle
			
			DetectHiddenWindows True
			windowTitle := WinGetTitle(wnd)
			
			if (!windowTitle)
				DetectHiddenWindows False
			return windowTitle
		}
	}
}