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
Import "Number.bmx"

Private

Type NDropdownItemButton Extends NButton
	Global NDropdownItemDrawable:NDrawable = New NImageDrawable.InitWithImage(LoadAnimImage("res/listitem.png", 2, 2, 0, 4))
	
	Method InitWithFrame:NDropdownItemButton(frame:NRect)
		Super.InitWithFrame(frame)
		SetDrawable(NDropdownItemDrawable)
		Return Self
	End Method
	
	Method DrawCaption()
		Local t$ = FitTextToWidth(_text, Bounds(_temp_rect).size.width-4)
		SetAlpha(1)
		DrawText(t, 1, Floor((_temp_rect.size.height-1 - TextHeight(t))*.5))
	End Method
End Type

Type NDropdownPopup Extends NPopup
	Global NDropdownPopupDrawable:NDrawable = New NNinePatchDrawable.InitWithImageAndBorders(LoadImage("res/dropdown_pop.png"), 4, 4, 4, 6, 1)
	
	Field _fade!=0
	
	Method InitWithFrame:NDropdownPopup(frame:NRect)
		Super.InitWithFrame(frame)
		Return Self
	End Method
	
	Method Draw()
		Local frame:NRect = Frame(_temp_rect)
		SetAlpha(-.5 + _fade)
		SetColor(0, 0, 0)
		NGlobalDrawables.ShadowPatch.DrawRect(-2, 0, frame.size.width+4, frame.size.height+6)
		SetAlpha(.5 + .5*_fade)
		SetColor(255, 255, 255)
		NDropdownPopupDrawable.DrawRect(0, 0, frame.size.width, frame.size.height)
		SetAlpha(1)
	End Method
	
	Method Bounds:NRect(out:NRect=Null)
		out = Frame(out)
		out.origin.x = 3
		out.origin.y = 3
		out.size.width :- 6
		out.size.height :- 6
		Return out
	End Method
	
	Method PerformLayout()
		Local index:Int = 0
		Local width# = Bounds(_temp_rect).size.width
		For Local subview:NView = EachIn _subviews
			_temp_rect.Set(0, index*18, width, 18)
			subview.SetFrame(_temp_rect)
			index :+ 1
		Next
		Super.PerformLayout()
	End Method
	
	Method ClipsSubviews:Int()
		Return True
	End Method
	
	Method ViewForPoint:NView(point:NPoint)
		If Not Bounds(_temp_rect).ContainsPoint(point) Then
			Return Null
		EndIf
		Return Super.ViewForPoint(point)
	End Method
End Type

Type NDropdownItem Extends NEventHandler Final
	Field value:Object
	Field name:String
	Field owner:NDropdown
	
	Method Fire(sender:NView, eventname$, data:TMap)
		Local link:TLink = owner._items.FindLink(Self)
		Local index:Int = 0
		link = link.PrevLink()
		While link
			index :+ 1
			link = link.PrevLink()
		Wend
		owner._selectionChanged(index)
		sender.Superview().Hide()
	End Method
End Type

Public

Const NSelectionChangedEvent$ = "SelectionChanged"

' Keys into the map passed to fired events
Const NSelectionValue$="SelectionValue"
Const NSelectionName$="SelectionName"
Const NSelectionIndex$="SelectionIndex"

Type NDropdown Extends NButton
	
	Global NDropdownDrawable:NDrawable = New NNinePatchDrawable.InitWithImageAndBorders(LoadAnimImage("res/dropdown.png", 64, 24, 0, 4), 5, 16, 0, 0, 1)
	
	Field _window:NDropdownPopup = New NDropdownPopup
	Field _selectedItemIndex:Int = 0
	Field _selected:NDropdownItem
	Field _items:TList = New TList
	
	Method AddItem(name$, value:Object)
		Local item:NDropdownItem = New NDropdownItem
		item.value = value
		item.name = name
		item.owner = Self
		Local button:NButton = New NDropdownItemButton.InitWithFrame(MakeRect(0, _items.Count()*18, _window.Bounds(_temp_rect).size.width, 18))
		button.SetText(name)
		button.AddEventHandler(NButtonPressedEvent, item)
		_window.AddSubview(button)
		_items.AddLast(item)
	End Method
	
	Method InitWithFrame:NDropdown(frame:NRect)
		Super.InitWithFrame(frame)
		SetDrawable(NDropdownDrawable)
		_window = _window.InitWithFrame(_window.Frame(_temp_rect))
		_window.SetHidden(true)
		Addsubview(_window)
		Return Self
	End Method
	
	Method SetFrame(frame:NRect)
		_temp_rect = _temp_rect.CopyValues(frame)
		Local width# = Max(_temp_rect.size.width, 12)
		_temp_rect.size.Set(width, 24)
		Super.SetFrame(_temp_rect)
		PerformLayout()
	End Method
	
	Method OnPress()
		_temp_rect.Set(0, 0, Frame(_temp_rect).size.width, 24)
		_window.SetFrame(_temp_rect)
		Local h# = Min(Max(18, 18 * _items.Count()), 140)+6
		Animate(_window._frame.size, "height", h, 120)
		
		_window._fade = 0
		Animate(_window, "_fade", 1.0, 80)
		
		_window.PerformLayout()
		
		ActiveGUI.SetPopup(_window)
	End Method
	
	Method PerformLayout()
		_temp_rect.Set(-3, 3, Frame(_temp_rect).size.width-10, _window.Frame(_temp_rect).size.height)
		_window.SetFrame(_temp_rect)
		_window.PerformLayout()
		Super.PerformLayout()
	End Method
	
	Method DrawCaption()
		If 0 <= _selectedItemIndex And _selectedItemIndex < _items.Count() Then
			Local item:NDropdownItem = NDropdownItem(_items.ValueAtIndex(_selectedItemIndex))
			If item Then
				Local vx%, vy%, vw%, vh%
				GetViewport(vx, vy, vw, vh)
				Frame(_temp_rect)
				_temp_rect.origin.Set(4, 0)
				_temp_rect.size.width :- 20
				Local text$ = FitTextToWidth(item.name, _temp_rect.size.width)
				If text Then
					_temp_rect.origin = ConvertPointToScreen(_temp_rect.origin, _temp_rect.origin)
		
					Local clip:NRect = New NRect
					clip.Set(vx, vy, vw, vh)
					clip = _temp_rect.Intersection(clip, clip)
		
					If 0 < clip.size.width and 0 < clip.size.height Then
						SetViewport(clip.origin.x, clip.origin.y, clip.size.width, clip.size.height)
						DrawText(text, 4, 11-_theight*.5)
						SetViewport(vx, vy, vw, vh)
					EndIf
				EndIf
			EndIf
		EndIf
	End Method
	
	Method _selectionChanged(index:Int)
		_selectedItemIndex = index
		Local value:Object = Null
		Local name$ = Null
		Local data:TMap = New TMap
		data.Insert(NSelectionIndex, NNumber.ForInt(index))
		If 0 <= _selectedItemIndex And _selectedItemIndex < _items.Count() Then
			Local item:NDropdownItem = NDropdownItem(_items.ValueAtIndex(_selectedItemIndex))
			value = item.value
			name = item.name
			data.Insert(NSelectionValue, value)
			data.Insert(NSelectionName, name)
		EndIf
		OnSelectionChanged(index, value, name)
		FireEvent(NSelectionChangedEvent, data)
	End Method
	
	Method OnSelectionChanged(index:Int, value:Object, name$)
	End Method
	
	Method SetSelectedIndex(index:Int)
		If index <> _selectedItemIndex Then
			_selectedItemIndex = index
		EndIf
	End Method
	
	Method SelectedIndex%()
		Return _selectedItemIndex
	End Method
	
End Type
