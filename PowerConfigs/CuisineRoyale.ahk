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
		SilentOption.GPU.advancedMode(55, 65, 85, 100, 125, 150)

		TaskManager.SetProcessAffinityCores("chrome, steam*", [6, 7])
		Suspender.SuspendProcess("java.exe")

		; this.Notify("Enabled " . PowerConfig.SetPowerPlan("Consistent Performance") . " power plan.")
	}
	
	Off() {
		; ThrottleProfile.set("Internet").setActiveStatus("ON")
		; this.Notify("ThrottleStop profile changed to 'Internet'.")
	
		; Suspender.ResumeProcesses(Suspender.GetProcessIDs("brave.exe"))
		; this.Notify("Brave Browser processes resumed.")
		
		this.Notify("Closing opened applications.")
		Utility.AHKScript(CuisineRoyale.cuisineAssistant).Close()
		Utility.AHKScript(CuisineRoyale.finerCurves).Close()

		TaskManager.SetProcessAffinityCores("chrome, steam*") ; Restore to all cores
		Suspender.ResumeProcess("java.exe")

		; Once we close MSI Afterburner, NVIDIA Optimus shutsdown dGPU, meaning the fans shutdown with it... Let's allow an X amount of time for extra cooling.

		ContinueAfterSleepWith() {
			if (WinExist("ahk_exe cuisine_royale_eac_launcher.exe"))
				return

			Utility.ExitProcess("MSIAfterburner.exe")
			Utility.ExitProcess("RTSS.exe")

			SilentOption.CPU.simpleMode(-20)
			SilentOption.GPU.advancedMode(30, 60, 80, 100, 125, 150)
		}

		Utility.DelayAction(2 * 60 * 1000, () => ContinueAfterSleepWith()) ; So we don't interrupt the main thread with sleep...

		; this.Notify("Restored to previously set " . PowerConfig.SetPowerPlan(PowerConfig.GetPreviousActivePlan().Name) . " power plan.")
	}
}

WatchDog.new(CuisineRoyale).Monitor("cuisine_royale_eac_launcher.exe", "Exist")