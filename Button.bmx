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

Import "Animation.bmx"
Import "NinePatch.bmx"
Import "GUI.bmx"

Const NButtonPressedEvent$="NButtonPressed"

Type NButton Extends NView
	Global NButtonDrawable:NDrawable = New NNinePatch.InitWithImageAndBorders(LoadAnimImage("res/button.png", 64, 64, 0, 4), 10, 10, 10, 10, 1)
	
	Field _drawable:NDrawable
	Field _fade_hilite!=0.0
	Field _fade_press!=0.0
	Field _twidth#, _theight#
	Field _pressed:Int = False
	Field _inside:Int = False
	Field _down_fade!=0.0
	Field _hilite_fade!=0.0
	
	Method New()
		_drawable = NButtonDrawable
		SetText("Button")
	End Method
	
	Method MousePressed:NView(button%, x%, y%)
		If button = 1 And Bounds(_temp_rect).Contains(x, y) Then
			_pressed = True
			_inside = True
			Animate(Self, "_down_fade", 1.0, 80)
			Return Self
		EndIf
	End Method
	
	Method MouseMoved:NView(x%, y%, dx%, dy%)
		Local view:NView = Super.MouseMoved(x, y, dx, dy)
		If view <> Self And view <> Null Then
			Return view
		EndIf
		
		Local inside:Int = Bounds(_temp_rect).Contains(x,y)
		If inside <> _inside Then
			If _pressed And inside Then
				Animate(Self, "_down_fade", 1.0, 80)
			Else
				Animate(Self, "_down_fade", 0.0, 80)
			EndIf
		EndIf
		_inside = inside
		
		If inside Then
			Return Self
		EndIf
		Return Null
	End Method
	
	Method MouseReleased:Int(button%, x%, y%)
		If button = 1 And _pressed Then
			_pressed = 0
			Animate(Self, "_down_fade", 0.0, 80)
			If Bounds(_temp_rect).Contains(x,y) And Not _inside Then
				_inside = True
				_hilite_fade = 1.0
			EndIf
			If _inside Then
				_Press()
			EndIf
		EndIf
	End Method
	
	Method MouseEntered:Int()
		Animate(Self, "_hilite_fade", 1.0, 200)
		_inside = True
	End Method
	
	Method MouseLeft:Int()
		Animate(Self, "_hilite_fade", 0.0, 200)
		_inside = False
	End Method
	
	Method InitWithFrame:NButton(frame:NRect)
		Super.InitWithFrame(frame)
		Return Self
	End Method
	
	Method Draw()
		Local bounds:NRect = Bounds(_temp_rect)
		SetColor(255, 255, 255)
		Local hilite_fade! = _hilite_fade*(1.0-_down_fade)
		SetAlpha(1.0)
		_drawable.DrawRect(0, 0, bounds.size.width, bounds.size.height, 0)
		If hilite_fade > 0.02 And _down_fade < .98 Then
			SetAlpha(hilite_fade)
			_drawable.DrawRect(0, 0, bounds.size.width, bounds.size.height, 1)
		EndIf
		If _down_fade > 0.02 Then
			SetAlpha(_down_fade)
			_drawable.DrawRect(0, 0, bounds.size.width, bounds.size.height, 2)
		EndIf
		If _text Then
			SetAlpha(0.8)
			Local hx#, hy#
			Local sx#, sy#
			GetScale(sx, sy)
			SetScale(1.0, 1.0 - _down_fade*.1)
			DrawText(_text, Floor((bounds.size.width-_twidth)*.5), Floor((bounds.size.height-_theight)*.5 + (_down_fade)*2))
			SetScale(sx, sy)
		EndIf
		SetAlpha(1.0)
		Super.Draw()
	End Method
	
	Method SetText(text$)
		If text Then
			_twidth = TextWidth(text)
			_theight = TextHeight(text)
		EndIf
		Super.SetText(text)
	End Method
	
	Method SetDrawable(drawable:NDrawable)
		Assert drawable
		_drawable = drawable
	End Method
	
	Method _Press()
		FireEvent(NButtonPressedEvent, Null)
		OnPress()
	End Method
	
	Method OnPress()
	End Method
End Type
