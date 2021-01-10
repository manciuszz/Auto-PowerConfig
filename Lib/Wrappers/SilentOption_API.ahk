class SilentOption { ; Requires Administrator priviliges...
    static _ := SilentOption.base := SilentOption.new()
    static _fanSpeedConfig := A_AppData . "\MSI\fanspeed.txt"
    static exeProcess := "SilentOption.exe"

	static currentConfig := ""
	static queuedApplyCommand := ""

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
        FileAppend(this._fanConfigToRaw(SilentOption.currentConfig), this._fanSpeedConfig)
    }

    applySettings() { ; Debounced 'applySettings' method
        if (!SilentOption.queuedApplyCommand) {
            SilentOption.queuedApplyCommand := ObjBindMethod(this, "__applySettings")
        }
        
        SetTimer(SilentOption.queuedApplyCommand, -250)
    }

	__applySettings() {
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
		if (!SilentOption.currentConfig) {
			SilentOption.currentConfig := this.getFanConfig()
		}

        SilentOption.currentConfig[key] := value
    }
}