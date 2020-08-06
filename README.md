# Auto-PowerConfig

A tool written (FOR POWER USERS) in AutoHotkey to programmatically control PC performance using popular tools such as "ThrottleStop", "RivaTuner Statistics Server" and the less popular 'SilentOption'.

# Usage

Define your actions and triggers inside "Projects" folder via ".ahk" extension and launch "Power Manager.ahk" application.

#### Example:

> CuisineRoyale.ahk
```autohotkey
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
```

The programmed actions above would trigger defined method "On()" when you launch the Cuisine Royale game whose process name is "cuisine_royale.exe", otherwise once the game is closed and "cuisine_royale.exe" process no longer "Exist" it will trigger method "Off()".

# Future plans

- Popular tools API wrappers would be nice to have :)
- It is possible to create a GUI to make this more accessible to everyone.

#### Notes: 
> [*A dirty AHK v1 version is available in a different git branch.*](https://github.com/manciuszz/Auto-PowerConfig/tree/master)
