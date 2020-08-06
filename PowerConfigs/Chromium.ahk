class Chrome {
	On() {
		PowerConfig.SetPowerPlan("Internet")
	}
	
	Off() {
		PowerConfig.SetPowerPlan(PowerConfig.GetPreviousActivePlan().Name)
	}
}

WatchDog.new(Chrome).Monitor("chrome.exe", "Active")
