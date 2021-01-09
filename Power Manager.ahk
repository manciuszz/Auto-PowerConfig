; Script tested on "AutoHotkey_2.0-a115-f7c71ea8" (2020-07-14)

#Persistent
#SingleInstance Force

; Global Libraries
#Include <Include>
#Include <Utility>
#Include <WatchDog>

; Automatically load PowerConfigs inside the folder
class PowerManager {
	static entry_point := PowerManager.new().InitialRoutine()

	InitialRoutine() {
		ObjBindMethod(this, A_Args.Length > 0 ? A_Args[1] : "Import").Call()
	}

	Import() {
		Include(A_ScriptDir "\PowerConfigs\*.ahk", "Main")
	}

	Main() {
		Utility.ElevateToAdmin()
	}
}

#HotIf WinActive("ahk_exe notepad++.exe") ; For development purposes...
^R::Reload
