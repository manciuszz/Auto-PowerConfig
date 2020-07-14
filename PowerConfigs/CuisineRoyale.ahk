class CuisineRoyale {
	On() {	
		; Suspender.SuspendProcesses(Suspender.GetProcessIDs("brave.exe"))
		; this.Notify("Brave Browser processes temporarily suspended.")
		
		this.Notify("Opening pre-configured applications.")
		Utility.LaunchProcess("MSIAfterburner.exe")
		Utility.AHKScript("D:\Interception\CuisineAssistant\CuisineAssistant.ahk").Open()
		Utility.AHKScript("D:\Programming\FinerCurves\FinerCurves_v2.ahk").Open()
		
		this.Notify("Enabled " . PowerConfig.SetPowerPlan("Consistent Performance") . " power plan.")
	}
	
	Off() {
		; Suspender.ResumeProcesses(Suspender.GetProcessIDs("brave.exe"))
		; this.Notify("Brave Browser processes resumed.")
		
		this.Notify("Closing opened applications.")
		Utility.ExitProcess("MSIAfterburner.exe")
		Utility.ExitProcess("RTSS.exe")
		Utility.AHKScript("D:\Interception\CuisineAssistant\CuisineAssistant.ahk").Close()
		Utility.AHKScript("D:\Programming\FinerCurves\FinerCurves_v2.ahk").Close()

		this.Notify("Restored to previously set " . PowerConfig.SetPowerPlan(PowerConfig.GetPreviousActivePlan().Name) . " power plan.")
	}
}

WatchDog.new(CuisineRoyale).Monitor("cuisine_royale.exe", "Exist")
