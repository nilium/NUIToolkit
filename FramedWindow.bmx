Rem
Copyright (c) 2010, Noel R. Cower
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this 
   list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the documentation 
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
EndRem

SuperStrict

Import "GUI.bmx"
Import "NinePatch.bmx"

Type NFramedWindow Extends NWindow
	Global FramePatch:NDrawable = New NNinePatch.InitWithImage(LoadAnimImage("res/window.png", 256, 256, 0, 2), 10, 10, 42, 10, .6)
	Field _dragging:Int = 0 ' 1 = move window, 2 = resize
	Field _drag_x:Int, _drag_y:Int
	Field _twidth#, _theight#
	
	Method InitWithFrame:NFramedWindow(frame:NRect)
		Super.InitWithFrame(frame)
		Return Self
	End Method
	
	Method DrawFrame()
		Local frame:NRect = Frame(_temp_rect)
		FramePatch.DrawRect(0, 0, frame.size.width, frame.size.height, Not IsMainWindow())
		Local cx# = Floor((frame.size.width-_twidth)*.5)
		Local cy# = Floor(12-_theight*.5)
		SetColor(255,255,255)
		SetAlpha(0.5)
		DrawText _text, cx, cy+1
		SetColor(0,0,0)
		SetAlpha(1.0)
		DrawText _text, cx, cy
		SetColor(255,255,255)
	End Method
	
	Method MousePressed:NView(x%, y%)
		' resizing the view takes precedence over other controls
		Local frame:NRect = Frame(_temp_rect)
		frame.Set(frame.size.width - 24, frame.size.height - 24, 24, 24)
		If frame.Contains(x, y) Then
			If Not IsMainWindow() Then
				MakeMainWindow()
			EndIf
			_dragging = 2
			Self.Frame(frame)
			_drag_x = frame.size.width - x
			_drag_y = frame.size.height - y
			Return Self
		EndIf
		
		Local r:NView = Super.MousePressed(x, y)
		If r Then
			Return r
		EndIf
		
		Self.Frame(frame)
		frame.origin.Set(0, 0)
		frame.size.height = 24
		If frame.Contains(x, y) Then
			_dragging = 1
			Return Self
		EndIf
		
		Return Null
	End Method
	
	Method MouseMoved:NView(x%, y%, dx%, dy%)
		If _dragging = 1 Then
			_frame.origin.x :+ dx
			_frame.origin.y :+ dy
			Return Self
		ElseIf _dragging = 2 Then
			Local frame:NRect = Frame(_temp_rect)
			frame.size.Set(Max(50, x+_drag_x), Max(50, y+_drag_y))
			SetFrame(frame)
			PerformLayout()
			Return Self
		EndIf
		
		Return Super.MouseMoved(x, y, dx, dy)
	End Method
	
	Method MouseReleased(x%, y%)
		_dragging = False
	End Method
	
	Method MouseEntered()
	End Method
	
	Method MouseLeft()
	End Method
	
	Method Bounds:NRect(out:NRect=Null)
		out = Super.Bounds(out)
		
		out.origin.x :+ 5
		out.origin.y :+ 24
		out.size.width :- 10
		out.size.height :- 29
		
		Return out
	End Method
	
	Method ClippingRect:NRect(out:NRect=Null)
		Return Bounds(out)
	End Method

	Method SetText(text$)
		If text Then
			_twidth = TextWidth(text)
			_theight = TextHeight(text)
		EndIf
		Super.SetText(text)
	End Method
End Type