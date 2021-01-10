; [Class] WinHook
; > Fanatic Guru (2019 02 18 v2)
;
; > Manciuszz (2021-01-10)
; Added 'AutoHotkey_2.0-a115-f7c71ea8' support.
; 
; Class to set hooks of windows or processes
;
;{============================	
;
;	Class (Nested):	WinHook.Shell
;
;		Method:
; 			Add(Func, wTitle:="", wClass:="", wExe:="", Event:=0)
;
;		Desc: Add Shell Hook
;
;   	Parameters:
;		1) {Func}		Function name or Function object to call on event
;   	2) {wTitle}	window Title to watch for event (default = "", all windows)
;   	3) {wClass}	window Class to watch for event (default = "", all windows)
;   	4) {wExe}		window Exe to watch for event (default = "", all windows)
;   	5) {Event}		Event (default = 0, all events)
;
;		Returns: {Index}	index to hook that can be used to Remove hook
;
;				(Sorted) Shell Hook Events:
;				1 = HSHELL_WINDOWCREATED
;				2 = HSHELL_WINDOWDESTROYED
;				3 = HSHELL_ACTIVATESHELLWINDOW
;				4 = HSHELL_WINDOWACTIVATED
;				5 = HSHELL_GETMINRECT
;				6 = HSHELL_REDRAW
;				7 = HSHELL_TASKMAN
;				8 = HSHELL_LANGUAGE
;				9 = HSHELL_SYSMENU
;				10 = HSHELL_ENDTASK
;				11 = HSHELL_ACCESSIBILITYSTATE
;				12 = HSHELL_APPCOMMAND
;				13 = HSHELL_WINDOWREPLACED
;				14 = HSHELL_WINDOWREPLACING
;				32768 = 0x8000 = HSHELL_HIGHBIT
;				32772 = 0x8000 + 4 = 0x8004 = HSHELL_RUDEAPPACTIVATED (HSHELL_HIGHBIT + HSHELL_WINDOWACTIVATED)
;				32774 = 0x8000 + 6 = 0x8006 = HSHELL_FLASH (HSHELL_HIGHBIT + HSHELL_REDRAW)
;
;		Note: ObjBindMethod(obj, Method) can be used to create a function object to a class method
;		WinHook.Shell.Add(ObjBindMethod(TestClass.TestNestedClass, "MethodName"), wTitle, wClass, wExe, Event)
;
; ----------
;
;		Desc: Function Called on Event
;			FuncOrMethod(Win_Hwnd, Win_Title, Win_Class, Win_Exe, Win_Event)
;		
;		Parameters:
;		1) {Win_Hwnd}		window handle ID of window with event 
;   	2) {Win_Title}		window Title of window with event
;   	3) {Win_Class}		window Class of window with event
;   	4) {Win_Exe}			window Exe of window with event
;   	5) {Win_Event}		window Event
;
;		Note: FuncOrMethod will be called with DetectHiddenWindows On.
;
; --------------------
;
;		Method: 	Report(ByRef Object)
;
;		Desc: 		Report Shell Hooks
;
;		Returns:	string report
;					 ByRef Object[Index].{Func, Title:, Class, Exe, Event}
;
; --------------------
;
;		Method:		Remove(Index)
;		Method:		Deregister()
;
;{============================	
;
;	Class (Nested):		WinHook.Event
;
;		Method:
;			Add(eventMin, eventMax, eventProc, idProcess, WinTitle := "") 			
;
;		Desc: Add Event Hook
;
;   	Parameters:
;		1) {eventMin}		lowest Event value handled by the hook function
;   	2) {eventMax}		highest event value handled by the hook function
;   	3) {eventProc}		event hook function, call be function name or function object
;   	4) {idProcess}		ID of the process from which the hook function receives events (default = 0, all processes)
;   	5) {WinTitle}			WinTitle to identify which windows to operate on, (default = "", all windows)
;
;		Returns: {hWinEventHook}	handle to hook that can be used to unhook
;
;				(Sorted) Event Hook Events:
;				0x0001 = EVENT_SYSTEM_SOUND
;				0x0002 = EVENT_SYSTEM_ALERT
;				0x0003 = EVENT_SYSTEM_FOREGROUND
;				0x0004 = EVENT_SYSTEM_MENUSTART
;				0x0005 = EVENT_SYSTEM_MENUEND
;				0x0006 = EVENT_SYSTEM_MENUPOPUPSTART
;				0x0007 = EVENT_SYSTEM_MENUPOPUPEND
;				0x0008 = EVENT_SYSTEM_CAPTURESTART
;				0x0009 = EVENT_SYSTEM_CAPTUREEND
;				0x000A = EVENT_SYSTEM_MOVESIZESTART
;				0x000B = EVENT_SYSTEM_MOVESIZEEND
;				0x000C = EVENT_SYSTEM_CONTEXTHELPSTART
;				0x000D = EVENT_SYSTEM_CONTEXTHELPEND
;				0x000E = EVENT_SYSTEM_DRAGDROPSTART
;				0x000F = EVENT_SYSTEM_DRAGDROPEND
;				0x0010 = EVENT_SYSTEM_DIALOGSTART
;				0x0011 = EVENT_SYSTEM_DIALOGEND
;				0x0012 = EVENT_SYSTEM_SCROLLINGSTART
;				0x0013 = EVENT_SYSTEM_SCROLLINGEND
;				0x0014 = EVENT_SYSTEM_SWITCHSTART
;				0x0015 = EVENT_SYSTEM_SWITCHEND
;				0x0016 = EVENT_SYSTEM_MINIMIZESTART
;				0x0017 = EVENT_SYSTEM_MINIMIZEEND
;				0x0020 = EVENT_SYSTEM_DESKTOPSWITCH
;				0x00FF = EVENT_SYSTEM_END
;				0x8000 = EVENT_OBJECT_CREATE
;				0x8001 = EVENT_OBJECT_DESTROY
;				0x8002 = EVENT_OBJECT_SHOW
;				0x8003 = EVENT_OBJECT_HIDE
;				0x8004 = EVENT_OBJECT_REORDER
;				0x8005 = EVENT_OBJECT_FOCUS
;				0x8006 = EVENT_OBJECT_SELECTION
;				0x8007 = EVENT_OBJECT_SELECTIONADD
;				0x8008 = EVENT_OBJECT_SELECTIONREMOVE
;				0x8009 = EVENT_OBJECT_SELECTIONWITHIN
;				0x800A = EVENT_OBJECT_STATECHANGE
;				0x800B = EVENT_OBJECT_LOCATIONCHANGE
;				0x800C = EVENT_OBJECT_NAMECHANGE
;				0x800D = EVENT_OBJECT_DESCRIPTIONCHANGE
;				0x800E = EVENT_OBJECT_VALUECHANGE
;				0x800F = EVENT_OBJECT_PARENTCHANGE
;				0x8010 = EVENT_OBJECT_HELPCHANGE
;				0x8011 = EVENT_OBJECT_DEFACTIONCHANGE
;				0x8012 = EVENT_OBJECT_ACCELERATORCHANGE
;				0x8013 = EVENT_OBJECT_INVOKED
;				0x8014 = EVENT_OBJECT_TEXTSELECTIONCHANGED
;				0x8015 = EVENT_OBJECT_CONTENTSCROLLED
;				0x8016 = EVENT_SYSTEM_ARRANGMENTPREVIEW
;				0x8017 = EVENT_OBJECT_CLOAKED
;				0x8018 = EVENT_OBJECT_UNCLOAKED
;				0x8019 = EVENT_OBJECT_LIVEREGIONCHANGED
;				0x8020 = EVENT_OBJECT_HOSTEDOBJECTSINVALID
;				0x8021 = EVENT_OBJECT_DRAGSTART
;				0x8022 = EVENT_OBJECT_DRAGCANCEL
;				0x8023 = EVENT_OBJECT_DRAGCOMPLETE
;				0x8024 = EVENT_OBJECT_DRAGENTER
;				0x8025 = EVENT_OBJECT_DRAGLEAVE
;				0x8026 = EVENT_OBJECT_DRAGDROPPED
;				0x8027 = EVENT_OBJECT_IME_SHOW
;				0x8028 = EVENT_OBJECT_IME_HIDE
;				0x8029 = EVENT_OBJECT_IME_CHANGE
;				0x8030 = EVENT_OBJECT_TEXTEDIT_CONVERSIONTARGETCHANGED
;				0x80FF = EVENT_OBJECT_END

;
;		Note: ObjBindMethod(obj, Method) can be used to create a function object to a class method
;		WinHook.Event.Add((eventMin, eventMax, ObjBindMethod(TestClass.TestNestedClass, "MethodName"), idProcess, WinTitle := "")
;
; ----------
;
;		Desc: Function Called on Event
;		FuncOrMethod(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
;		
;		Parameters:
;		1) {hWinEventHook}		Handle to an event hook instance.
;   	2) {event}						Event that occurred. This value is one of the event constants
;   	3) {hwnd}						Handle to the window that generates the event.
;   	4) {idObject}					Identifies the object that is associated with the event.
;   	5) {idChild}					Child ID if the event was triggered by a child element.
;   	6) {dwEventThread}		Identifies the thread that generated the event.
;   	7) {dwmsEventTime}	Specifies the time, in milliseconds, that the event was generated.
;
;		Note: FuncOrMethod will be called with DetectHiddenWindows On.
;
; --------------------
;
;		Method:	Report(ByRef Object)
;
;		Returns:	string report
;					 ByRef Object[hWinEventHook].{eventMin, eventMax, eventProc, idProcess, WinTitle}
;
; --------------------
;
;		Method: 	UnHook(hWinEventHook)
;		Method: 	UnHookAll()
;
;{============================	
class WinHook {

	class Shell {

		static Add(Func, wTitle:="", wClass:="", wExe:="", Event:=0) {
			if (!WinHook.Shell.HasOwnProp("Hooks")) {
				WinHook.Shell.Hooks := Array(), WinHook.Shell.Events := Map()
				DllCall("RegisterShellHookWindow", "UInt", A_ScriptHwnd)
				MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
				OnMessage(MsgNum, ObjBindMethod(WinHook.Shell, "Message"))
			}

			if !IsObject(Func)
				Func := Func(Func)

			WinHook.Shell.Hooks.Push({Func: Func, Title: wTitle, Class: wClass, Exe: wExe, Event: Event})
			WinHook.Shell.Events[Event] := true
			return WinHook.Shell.Hooks.Length
		}

		static Remove(Index) {
			WinHook.Shell.Hooks.Delete(Index)
			WinHook.Shell.Events[Event] := {}	; delete and rebuild Event list
			for key, Hook in WinHook.Shell.Hooks
				WinHook.Shell.Events[Hook.Event] := true
		}

		static Report(ByRef Obj:="") {
			_Display := ""
			Obj := WinHook.Shell.Hooks
			for key, Hook in WinHook.Shell.Hooks {
				_Display .= key "|" Hook.Event "|" Hook.Func.Name "|" Hook.Title "|" Hook.Class "|" Hook.Exe "`n"
			}
			return Trim(_Display, "`n")
		}

		static Deregister() {
			DllCall("DeregisterShellHookWindow", "UInt", A_ScriptHwnd)
			WinHook.Shell.Hooks := "", WinHook.Shell.Events := ""		
		}
		
		static Message(Event, Hwnd, *) { ; Private Method
			Try { ; Suppress errors in case of 'WinGet' functions throwing an error due to something like target window not being found.
				DetectHiddenWindows(True)
				if (WinHook.Shell.Events.Has(Event) or WinHook.Shell.Events[0]) {
					wTitle := WinGetTitle("ahk_id " . Hwnd)
					wClass := WinGetClass("ahk_id " . Hwnd)
					wExe := WinGetProcessName("ahk_id " . Hwnd)
					for key, Hook in WinHook.Shell.Hooks {
						if ((Hook.Title = wTitle or Hook.Title = "") and (Hook.Class = wClass or Hook.Class = "") and (Hook.Exe = wExe or Hook.Exe = "") and (Hook.Event = Event or Hook.Event = 0)) {
							if (Hook.Func.IsVariadic) {
								return Hook.Func.Call(Hwnd, wTitle, wClass, wExe, Event)
							} else if (Hook.Func.MaxParams > 0) {
								_arguments := [Hwnd, wTitle, wClass, wExe, Event]
								_arguments.Capacity := Hook.Func.MaxParams
								return Hook.Func.Call(_arguments*)
							}
						}
					}
				}
			}
		}
	}

	class Event {
		static Add(eventMin, eventMax, eventProc, idProcess := 0, WinTitle := "") {
			if (!WinHook.Event.HasOwnProp("Hooks")) {
				WinHook.Event.Hooks := Map()
				WinHook.Event.CB_WinEventProc := CallbackCreate(ObjBindMethod(WinHook.Event, "Message"), "Fast", 7)
				OnExit(ObjBindMethod(WinHook.Event, "UnHookAll"))
			}

			hWinEventHook := DllCall("SetWinEventHook"
				, "UInt",	eventMin						;  UINT eventMin
				, "UInt",	eventMax						;  UINT eventMax
				, "Ptr" ,	0x0								;  HMODULE hmodWinEventProc
				, "Ptr" ,	WinHook.Event.CB_WinEventProc   ;  WINEVENTPROC lpfnWinEventProc
				, "UInt" ,	idProcess						;  DWORD idProcess
				, "UInt",	0x0								;  DWORD idThread
				, "UInt",	0x0|0x2)  						;  UINT dwflags, OutOfContext|SkipOwnProcess
			
			if !IsObject(eventProc)
				eventProc := Func(eventProc)
			WinHook.Event.Hooks[hWinEventHook] := { eventMin: eventMin, eventMax: eventMax, eventProc: eventProc, idProcess: idProcess, WinTitle: WinTitle }
			return hWinEventHook
		}

		static Report(ByRef Obj:="") {
			_Display := ""
			Obj := WinHook.Event.Hooks
			for hWinEventHook, Hook in WinHook.Event.Hooks
				_Display .= hWinEventHook "|" Hook.eventMin "|" Hook.eventMax "|" Hook.eventProc.Name "|" Hook.idProcess "|" Hook.WinTitle "`n"
			return Trim(_Display, "`n")
		}

		static UnHook(hWinEventHook) {
			DllCall("UnhookWinEvent", "Ptr", hWinEventHook)
			WinHook.Event.Hooks.Delete(hWinEventHook)
		}

		static UnHookAll(*) {
			for hWinEventHook, Hook in WinHook.Event.Hooks
				DllCall("UnhookWinEvent", "Ptr", hWinEventHook)

			CallbackFree(WinHook.Event.CB_WinEventProc)
			WinHook.Event.Hooks := "", WinHook.Event.CB_WinEventProc := ""
		}

		static Message(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) { ; 'Private Method 
			Try {
				DetectHiddenWindows(True)
				Hook := WinHook.Event.Hooks[hWinEventHook]
				_List := WinGetList(Hook.WinTitle)

				for this_hwnd in _List {
					if (this_hwnd == hwnd) {
						if (Hook.eventProc.IsVariadic) {
							return Hook.eventProc.Call(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
						} else if (Hook.eventProc.MaxParams > 0) {
							_arguments := [hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime]
							_arguments.Capacity := Hook.eventProc.MaxParams
							return Hook.eventProc.Call(_arguments*)
						}
					}
				}
			}
		}
	}
}