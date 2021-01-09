#Include <Wrappers\ThrottleStop_API>
#Include <Wrappers\SilentOption_API>

class CuisineRoyale {
	static finerCurves := "D:\Programming\FinerCurves\FinerCurves_v2.ahk"
	static cuisineAssistant := "D:\Interception\CuisineAssistant\CuisineAssistant.ahk"

	On() {
		; ThrottleProfile.set("Game").setActiveStatus("ON")
		; ThrottleMultiplier.set(30)
		; this.Notify("ThrottleStop profile changed to 'Game' and CPU Multiplier to 30.")
	
		; Suspender.SuspendProcesses(Suspender.GetProcessIDs("brave.exe"))
		; this.Notify("Brave Browser processes temporarily suspended.")
		
		this.Notify("Opening pre-configured applications.")
		Utility.LaunchProcess("MSIAfterburner.exe")
		Utility.AHKScript(CuisineRoyale.cuisineAssistant).Open()
		Utility.AHKScript(CuisineRoyale.finerCurves).Open()
				
		SilentOption.CPU.advancedMode(0, 54, 75, 100, 125, 150)

		; this.Notify("Enabled " . PowerConfig.SetPowerPlan("Consistent Performance") . " power plan.")
	}
	
	Off() {
		; ThrottleProfile.set("Internet").setActiveStatus("ON")
		; this.Notify("ThrottleStop profile changed to 'Internet'.")
	
		; Suspender.ResumeProcesses(Suspender.GetProcessIDs("brave.exe"))
		; this.Notify("Brave Browser processes resumed.")
		
		this.Notify("Closing opened applications.")
		Utility.ExitProcess("MSIAfterburner.exe")
		Utility.ExitProcess("RTSS.exe")
		Utility.AHKScript(CuisineRoyale.cuisineAssistant).Close()
		Utility.AHKScript(CuisineRoyale.finerCurves).Close()

		SilentOption.CPU.simpleMode(-20)

		; this.Notify("Restored to previously set " . PowerConfig.SetPowerPlan(PowerConfig.GetPreviousActivePlan().Name) . " power plan.")
	}
}

WatchDog.new(CuisineRoyale).Monitor("cuisine_royale_eac_launcher.exe", "Exist")