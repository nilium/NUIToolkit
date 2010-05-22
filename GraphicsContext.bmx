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

Import "Rect.bmx"
Import "Font.bmx"

Public

Type NGraphicsState
	Method SetClipping(x#, y#, w#, h#) Abstract
	Method MoveToPoint(x#, y#) Abstract
	Method Translate(x#, y#) Abstract
	Method Rotate(a#) Abstract
	Method SetClearColor(r#, g#, b#) Abstract
	Method SetDrawingAlpha(a#) Abstract
	Method SetDrawingColor(r#, g#, b#) Abstract
	Method SetBlendingMode(b%) Abstract
	Method SetFont(font:NFont) Abstract
	Method Acquire() Abstract
	Method Restore() Abstract
	Method Clone:NGraphicsState() Abstract
End Type

Private

Global NGraphicsStateTypeID:TTypeID = TTypeID.ForName("NGraphicsState")

Public

Type NGraphicsContext
	Field _states:TList = New TList
	Field _top:NGraphicsState
	
	Method InitWithGraphicsStateType:NGraphicsContext(typ:TTypeID)
		Assert typ Else "No type ID provided for context"
		Assert typ <> NGraphicsStateTypeID Else "Invalid type ID provided for context"
		_top = NGraphicsState(typ.NewObject())
		Assert _top Else "Invalid type ID, does not extend NGraphicsState"
		_top.Acquire()
		Return Self
	End Method
	
	Method SaveState() Final
		_states.AddLast(_top)
		_top = _top.Clone()
	End Method
	
	Method RestoreState() Final
		Local lastLink:TLink = _states.LastLink()
		Assert lastLink Else "State stack underflow"
		_top = NGraphicsState(lastLink.Value())
		lastLink.Remove()
		_top.Restore()
	End Method
	
	Method MoveToPoint(x#, y#) Final
		_top.MoveToPoint(x, y)
	End Method
	
	Method SetDrawingColor(r#, g#, b#) Final
		_top.SetDrawingColor(r, g, b)
	End Method
	
	Method SetDrawingAlpha(a#) Final
		_top.SetDrawingAlpha(a)
	End Method
	
	Method Translate(x#, y#) Final
		_top.Translate(x, y)
	End Method
	
	Method SetClipping(x#, y#, w#, h#) Final
		_top.SetClipping(x, y, w, h)
	End Method
	
	Method SetClearColor(r#, g#, b#) Final
		_top.SetClearColor(r, g, b)
	End Method
	
	Method Rotate(r#)
		_top.Rotate(r)
	End Method
	
	Method SetBlendingMode(b%)
		_top.SetBlendingMode(b)
	End Method
	
End Type