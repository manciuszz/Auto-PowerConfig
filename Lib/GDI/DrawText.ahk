﻿#Include <GDI/GDI+>
#Include <GDI/GDI+Helper>

drawLineLimit = 50
drawnString := ""
drawLine = 1
debugMode := false

messageQueue := {}

Join(sep, params) {
    for index, param in params
        str .= sep . param
    return SubStr(str, StrLen(sep)+1)
}

DrawText(str := "", drawTo := 1, offsetX := 50, offsetY := 100, style := "Bold", color := "ffff0000", alignment := "Right") {
	global messageQueue, drawLine, drawLineLimit, G, drawnString

	SetUpGDIP()

	StartDrawGDIP()
	ClearDrawGDIP()

	Gdip_SetSmoothingMode(G, 4)

	; Red = ffff0000
	; White = ffffffff

	offsetX := A_ScreenWidth - offsetX

	opt = c%color% x%offsetX% y%offsetY% r4 s16 %style% %alignment%
	; pBrush := Gdip_BrushCreateSolid(0xf0000000)
	; Gdip_FillRectangle(G, pBrush, 100, 100, 330, 890)
	; Gdip_DeleteBrush(pBrush)
	
	; if (debugMode) {
		; if (drawLine <= drawLineLimit) {
			; drawnString .= str . "`n"
		; } else {
			; drawLine = 1
			; drawnString := str . "`n"
		; }
	; } else {
		if (drawLine > drawLineLimit) {
			Loop %drawLineLimit% {
				messageQueue.Delete(A_Index)
			}
			drawLine = 1
		} else if (!str && drawTo > 0) {
			messageQueue.Delete(drawTo)
		}		
		messageQueue[drawTo != "" ? drawTo : drawLine] := str
		drawnString := Join("`n", messageQueue)
	; }

	Gdip_TextToGraphics(G, drawnString, opt)
	drawLine++

	Gdip_DeleteGraphics(G)
	EndDrawGDIP()
}