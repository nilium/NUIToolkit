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

Import "Button.bmx"
Import "ImageDrawable.bmx"

Type NCheckbox Extends NButton
	Global NCheckboxDrawable:NDrawable = New NImageDrawable.InitWithImage(LoadAnimImage("res/checkbox.png", 16, 16, 0, 5))
	
	Field _checked:Int=False
	
	Method InitWithFrame:NCheckbox(frame:NRect)
		Super.InitWithFrame(frame)
		SetDrawable(NCheckboxDrawable)
		Return Self
	End Method
	
	Method Draw()
		_drawable.DrawRect(0, 0, 16, 16, 4*Disabled(True))
		
		If 0.02# < _down_fade Then
			SetAlpha(_down_fade)
			_drawable.DrawRect(0, 0, 16, 16, 1)
			SetAlpha(1#)
		EndIf
		
		If _hilite_fade*(1#-_down_fade) Then
			SetBlend(LIGHTBLEND)
			SetAlpha(_hilite_fade)
			_drawable.DrawRect(0, 0, 16, 16, 2)
			SetAlpha(1)
			SetBlend(ALPHABLEND)
		EndIf
		
		If _checked Then
			_drawable.DrawRect(0, _down_fade, 16, 16, 3)
		EndIf
		
		DrawText(_text, 19, 7-_theight*.5)
	End Method
	
	Method OnPress()
		SetChecked(Not _checked)
	End Method
	
	Method SetText(text$)
		Super.SetText(text)
		SetFrame(Frame(_temp_rect))
	End Method
	
	Method SetFrame(frame:NRect)
		_temp_rect.CopyValues(frame)
		_temp_rect.size.Set(19+_twidth, 16)
		Super.SetFrame(_temp_rect)
	End Method
	
	Method Setchecked(checked%)
		_checked = 0<checked
	End Method
	
	Method Checked%()
		Return _checked
	End Method
End Type
