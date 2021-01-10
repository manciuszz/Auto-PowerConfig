#Include <WinHook>

class Notepad {
	On() {
		Test(Hwnd, wTitle, wClass, wExe, Event) {
			MsgBox(Hwnd . " " . wTitle . " " . wClass . " " . wExe . " " . Event)
		}

		; WinHook.Shell.Add(Func("Test"), "", "", "notepad++.exe")

		Test2(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
			MsgBox(WinGetTitle(hwnd) . " " . event)
		}
		; WinHook.Event.Add(0x8003, 0x8005, Func("Test2"), 0, "ahk_exe notepad++.exe")
	}
	
	Off() {
		
	}
}

; WatchDog.new(Notepad).Monitor("notepad.exe", "Active")
