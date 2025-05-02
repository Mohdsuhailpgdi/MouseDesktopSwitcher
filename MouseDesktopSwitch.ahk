#Requires AutoHotkey v2.0

; — Load the VDA DLL —
vdaPath := A_ScriptDir "\VirtualDesktopAccessor.dll"
hVDA := DllCall("LoadLibrary", "Str", vdaPath, "Ptr")
if !hVDA {
    MsgBox("❌ Failed to load " vdaPath)
    ExitApp()
}

; — Resolve function pointers —
GetCountPtr   := DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "GetDesktopCount",         "Ptr")
GetCurrentPtr := DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "GetCurrentDesktopNumber", "Ptr")
GoToPtr       := DllCall("GetProcAddress", "Ptr", hVDA, "AStr", "GoToDesktopNumber",      "Ptr")

; — Wrapper functions —
GetDesktopCount()
{
    global GetCountPtr
    return DllCall(GetCountPtr, "Int")
}

GetCurrentDesktop()
{
    global GetCurrentPtr
    return DllCall(GetCurrentPtr, "Int")
}

GoToDesktopNumber(n)
{
    global GoToPtr
    DllCall(GoToPtr, "Int", n)
}

GoToPrevDesktop()
{
    current := GetCurrentDesktop()
    last    := GetDesktopCount() - 1
    new     := (current = 0) ? last : current - 1
    GoToDesktopNumber(new)
}

GoToNextDesktop()
{
    current := GetCurrentDesktop()
    last    := GetDesktopCount() - 1
    new     := (current = last) ? 0 : current + 1
    GoToDesktopNumber(new)
}

; — Timing state for debounce —
lastScroll := 0

; — Plain middle‐click passes through as a normal click —
MButton:: {
    Click "Middle"
    return
}

; — While holding MButton, WheelUp → previous desktop (debounced to 0.5s) —
MButton & WheelUp::
{
    global lastScroll
    now := A_TickCount
    if (now - lastScroll >= 500) {
        lastScroll := now
        GoToPrevDesktop()
    }
    return
}

; — While holding MButton, WheelDown → next desktop (debounced to 0.5s) —
MButton & WheelDown::
{
    global lastScroll
    now := A_TickCount
    if (now - lastScroll >= 500) {
        lastScroll := now
        GoToNextDesktop()
    }
    return
}
