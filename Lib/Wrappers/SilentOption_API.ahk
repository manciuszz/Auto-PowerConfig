class SilentOption { ; Requires Administrator priviliges...
    static _ := SilentOption.base := SilentOption.new()
    static _fanSpeedConfig := A_AppData . "\MSI\fanspeed.txt"
    static exeProcess := "SilentOption.exe"
	static currentConfig := ""

	class StopFocusSteal {
		static _MyGui := Gui.New("+LastFound")	
		static _ := SilentOption.StopFocusSteal.new()

		static debugTips := false

		__New() {
			this.previous := -1
			this.current := -1 

			this.__shellHook()
		}
		
		__shellHook() {
			DllCall( "RegisterShellHookWindow", "UInt", SilentOption.StopFocusSteal._MyGui.Hwnd)
			MsgNum := DllCall( "RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")

			OnMessage(MsgNum, ObjBindMethod(this, "ShellMessage"))
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
					if (SilentOption.StopFocusSteal.debugTips) {
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

    class CPU extends SilentOption {		
        static simpleMode(value) {
            this.setFanConfig("FanCPUCurrentMode", "simple")
			if (value != "")
            	this.setFanConfig("FanCPUSimpleModeValue", value)
			this.applySettings()
        }

        static advancedMode(temps*) {
            this.setFanConfig("FanCPUCurrentMode", "advanced")
			if (temps != "") {
				if (!IsInteger(temps[1]))
					temps := temps[1]
				
				for index, temperature in temps
            		this.setFanConfig("FanCPUT" . index . "Percentage", temperature)	
			}
			this.applySettings()
        }
    }

    class GPU extends SilentOption {
        static simpleMode(value) {
            this.setFanConfig("FanVGACurrentMode", "simple")
			if (value != "")
            	this.setFanConfig("FanVGASimpleModeValue", value)

			this.applySettings()
        }

        static advancedMode(temps*) {
            this.setFanConfig("FanVGACurrentMode", "advanced")
			if (temps != "") {
				if (!IsInteger(temps[1]))
					temps := temps[1]
				
				for index, temperature in temps
            		this.setFanConfig("FanVGAT" . index . "Percentage", temperature)	
			}
			this.applySettings()
        }
    }

    writeSettingsToFile() {
		FileDelete(this._fanSpeedConfig)
        FileAppend(this._fanConfigToRaw(this.currentConfig), this._fanSpeedConfig)
    }

	applySettings() {
		this.writeSettingsToFile()

		PID := ProcessExist(this.exeProcess)

		if (PID)
			Utility.ExitProcess(PID)
			
        Utility.LaunchProcess(this.exeProcess)
	}

    _fanConfigToRaw(currentConfig) {
        rawConfig := ""

        for key, value in currentConfig {
            rawConfig .= Format("{1:s}:{2:s}`n", key, value)
        }

        return rawConfig
    }

    getFanConfig() {
        configObject := Map()

        RAWFanSpeedConfig := FileRead(this._fanSpeedConfig)
        Loop Parse, RAWFanSpeedConfig, "`n", "`r" {
            if (A_LoopField == "")
                continue

            ConfigSetting := StrSplit(A_LoopField, ":")
            configObject[ConfigSetting[1]] := ConfigSetting[2]
        }

        return configObject
    }

    setFanConfig(key, value) {
		if (!this.currentConfig) {
			this.currentConfig := this.getFanConfig()
		}

        this.currentConfig[key] := value
    }
}