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

Const WINDOW_RAISEDMAIN%=2
Const WINDOW_RAISED%=1
Const WINDOW_BELOWMAIN%=0
Const WINDOW_BELOWALL%=-1

Global ActiveGUI:NGUI = Null

Type NGUI
	Field _active:Int=False
	
	Field _windows:TList = New TList
	Field _mainWindow:NWindow=Null
	Field _mouseWindow:NView=Null
	Field _temp_rect:NRect = New NRect
	
	Field _mouse_btn%[16,2] ' button (16 because I'm paranoid and it's a nice number), 0=cur, 1=last
	Field _mouse_prev:NPoint = New NPoint
	Field _mouse_cur:NPoint = New NPoint
	
	Field _overView:NView
	
	Function EventHook:Object(id%, data:Object, ctx:Object)
		Local gui:NGUI = NGUI(ctx)
		Local evt:TEvent = TEvent(data)
		If gui And id = EmitEventHook And evt Then
			gui.PushEvent(evt)
		EndIf
		Return data
	End Function
	
	Method New()
		_mouse_cur.x = MouseX()
		_mouse_cur.y = MouseY()
		ActiveGUI = Self
	End Method
	
	Method Dispose()
		Assert ActiveGUI=Self
		ActiveGUI = Null
	End Method
	
	Method EnableEventHook()
		If _active = False Then
			_active = True
			AddHook(EmitEventHook, EventHook, Self)
		EndIf
	End Method
	
	Method DisableEventHook()
		If _active Then
			_active = False
			RemoveHook(EmitEventHook, EventHook, Self)
		EndIf
	End Method
	
	Method _PushMousePressedEventToWindow%(window:NView, evt:TEvent)
		If Not window.Hidden() Then
			Local point:NPoint = MakePoint(evt.x, evt.y)
			window.ConvertPointFromScreen(point, point)
			Local view:NView = window.MousePressed(evt.data, point.x, point.y)
			If view Then
				_mouseWindow = view
				If _overView <> _mouseWindow Then
					If _overView Then
						_overView.MouseLeft()
					EndIf
					_overView = view
					view.MouseEntered()
				EndIf
				Return True
			EndIf
		EndIf
		Return False
	End Method
	
	Method PushEvent(evt:TEvent)
		Select evt.id
			Case EVENT_MOUSEDOWN
				Local point:NPoint
				Local top:TLink = _windows.LastLink()
				_mouse_prev.CopyValues(_mouse_cur)
				_mouse_cur.x = evt.x
				_mouse_cur.y = evt.y
				
				If _mouseWindow And _mouseWindow.Superview() And _PushMousePressedEventToWindow(_mouseWindow, evt) Then
					top = Null
				EndIf
				
				While top
					Local window:NWindow = NWindow(top.Value())
					If _PushMousePressedEventToWindow(window, evt) Then
						Exit
					EndIf
					top = top.PrevLink()
				Wend
			Case EVENT_MOUSEUP
				_mouse_btn[evt.data, 1] = True
				_mouse_btn[evt.data, 0] = False
				_mouse_prev.CopyValues(_mouse_cur)
				_mouse_cur.x = evt.x
				_mouse_cur.y = evt.y
				If _mouseWindow Then
					Local point:NPoint = _mouseWindow.ConvertPointFromScreen(_mouse_cur)
					If Not _mouse_cur.Equals(_mouse_prev) Then
						_mouseWindow.MouseMoved(point.x, point.y, evt.x - _mouse_prev.x, evt.y - _mouse_prev.y)
					EndIf
					_mouseWindow.MouseReleased(evt.data, point.x, point.y)
					Local frame:NRect = _mouseWindow.Frame(_temp_rect)
					frame.origin.Set(0, 0)
					If Not frame.ContainsPoint(point) Then
						_overView.MouseLeft()
						_overView = Null
					EndIf
					_mouseWindow = Null
				EndIf
			Case EVENT_MOUSEMOVE
				_mouse_prev.CopyValues(_mouse_cur)
				_mouse_cur.x = evt.x
				_mouse_cur.y = evt.y
				If _mouseWindow Then
					Local point:NPoint = _mouseWindow.ConvertPointFromScreen(_mouse_cur)
					_mouseWindow.MouseMoved(point.x, point.y, evt.x-_mouse_prev.x, evt.y-_mouse_prev.y)
				Else
					Local dx# = evt.x-_mouse_prev.x
					Local dy# = evt.y-_mouse_prev.y
					Local set% = False
					Local window:NWindow = _mainWindow
					If window And Not window.Hidden() Then
						Local point:NPoint = window.ConvertPointFromScreen(_mouse_cur)
						Local view:NView = window.MouseMoved(point.x, point.y, dx, dy)
						If _overView <> view Then
							If _overView Then
								_overView.MouseLeft()
							EndIf
							_overView = view
							If view Then
								view.MouseEntered()
							EndIf
						EndIf
					EndIf
				EndIf
		End Select
	End Method
	
	Method Draw()
		Local vx%, vy%, vw%, vh%
		GetViewport(vx, vy, vw, vh)
		Local ox#, oy#
		GetOrigin(ox, oy)
		
		Local gw% = GraphicsWidth()
		Local gh% = GraphicsHeight()
		
		For Local window:NWindow = EachIn _windows
			If window.Hidden() Then
				Continue
			EndIf
			Local frame:NRect = window.Frame(_temp_rect)
			SetOrigin(Floor(frame.origin.x), Floor(frame.origin.y))
			SetViewport(0, 0, gw, gh)
			window.Draw()
			window.DrawSubviews()
			window.DrawSubwindows()
		Next
		
		SetOrigin(ox, oy)
		SetViewport(vx, vy, vw, vh)
	End Method
	
	Method AddWindow(window:NWindow, position:Int=WINDOW_BELOWMAIN)
		Assert window Else "Window is Null"
		Assert window._superview = Null Else "Subwindows cannot be attached to a GUI instance"
		
		If _mainWindow And position = WINDOW_BELOWMAIN Then
			_windows.InsertBeforeLink(window, _windows.LastLink())
		ElseIf position = WINDOW_RAISED Or position = WINDOW_BELOWMAIN Then
			_windows.AddLast(window)
		ElseIf position = WINDOW_RAISEDMAIN Then
			_windows.AddLast(window)
			window.MakeMainWindow()
		ElseIf position = WINDOW_BELOWALL Then
			_windows.AddFirst(window)
		EndIf
	End Method
	
	Method RemoveWindow(window:NWindow)
		If _mainWindow = window Then
			_mainWindow = Null
		EndIf
	End Method
	
	Method SetMainWindow(window:NWindow)
		If window = _mainWindow Then
			Return
		EndIf
		If window.CanBecomeMainWindow() Then
			If window.Superview() = Null Then
				_windows.Remove(window)
				_windows.AddLast(window)
			EndIf
			_mainWindow = window
		EndIf
	End Method
End Type

Type NWindow Extends NView
	Field _modal:Int = False
	Field _contentView:NView
	
	Method MousePressed:NView(button%, x%, y%)
		Local frame:NRect = Self.Frame(_temp_rect)
		frame.origin.Set(0,0)
		
		If frame.Contains(x, y) Then
			If Not IsMainWindow() And CanBecomeMainWindow() Then
				MakeMainWindow()
			EndIf
		EndIf
		
		Local view:NView = Super.MousePressed(button, x, y)
		If view Then
			Return view
		Else
			Return Self
		EndIf
	End Method
	
	Method InitWithFrame:NWindow(frame:NRect)
		Super.InitWithFrame(frame)
		_contentView = New NView
		Super.AddSubview(_contentView)
		PerformLayout
		Return Self
	End Method
	
	' Draws the window frame, if there is one
	Method DrawFrame() Abstract
	
	Method Draw()
		DrawFrame()
		Super.Draw()
	End Method
	
	Method ClipsSubviews:Int()
		Return True
	End Method
	
	Method IsMainWindow:Int() Final
		Return (ActiveGUI._mainWindow = Self)
	End Method
	
	Method CanBecomeMainWindow:Int()
		Return True
	End Method
	
	Method MakeMainWindow:Int() Final
		ActiveGUI.SetMainWindow(Self)
		Local sv:NView = Superview()
		If sv Then
			RemoveFromSuperview()
			sv.AddSubview(Self, NVIEW_ABOVE)
		EndIf
	End Method
	
	Method ContentView:NView()
		Return _contentView
	End Method
	
	Method SetContentView(view:NView)
		Assert view Else "View cannot be Null"
		_contentView.RemoveFromSuperview()
		_contentView = view
		Super.AddSubview(_contentView)
		PerformLayout()
	End Method
	
	Method AddSubview(view:NView, position:Int=NVIEW_ABOVE)
		If NWindow(view) Then
			Super.AddSubview(view)
		Else
			_contentView.AddSubview(view, position)
		EndIf
	End Method
	
	Method PerformLayout()
		Local bounds:NRect = Bounds(_temp_rect)
		bounds.origin.Set(0, 0)
		_contentView.SetFrame(bounds)
	End Method
	
	Method Modal:Int()
		Return _modal
	End Method
	
	Method SetModal(modal%)
		_modal = modal
		If _modal Then
			MakeMainWindow()
		EndIf
	End Method
End Type

Const NVIEW_ABOVE:Int = 1
Const NVIEW_BELOW:Int = -1

Type NEventHandler
	Field _callback%(sender:NView, eventdata:TMap)
	
	Method InitWithCallback:NEventHandler(callback%(sender:NView, eventdata:TMap))
		_callback = callback
		Return Self
	End Method
	
	Method Fire(sender:NView, eventdata:TMap)
		If _callback Then _callback(sender, eventdata)
	End Method
End Type

Function MakeEventHandler:NEventHandler(callback%(sender:NView, eventdata:TMap))
	Return New NEventHandler.InitWithCallback(callback)
End Function

Type NView
	Field _name$=""
	Field _tag:Object=Null
	Field _id%=0
	Field _superview:NView
	Field _subviews:TList = New TList
	Field _frame:NRect = New NRect
	Field _bounds:NRect = Null
	Field _min_size:NRect = New NRect ' TODO: make use of this
	Field _temp_rect:NRect = New NRect
	Field _text$=""
	Field _disabled%=False
	Field _hidden%=False
	Field _eventhandlers:TMap=New TMap
	
	Method SetID(id%)
		_id = id
	End Method
	
	Method ID:Int()
		Return _id
	End Method
	
	Method SetName(name$)
		_name = name
	End Method
	
	Method Name:String()
		Return _name
	End Method
	
	Method SetTag(tag:Object)
		_tag = tag
	End Method
	
	Method Tag:Object()
		Return _tag
	End Method
	
	Method InitWithFrame:NView(frame:NRect)
		SetFrame(frame)
		Return Self
	End Method
	
	Method FindSubviewWithName:NView(name$, recurse%=True)
		For Local subview:NView = EachIn _subviews
			If subview._name = name Then
				Return subview
			EndIf
		Next
		If recurse Then
			Local view:NView
			For Local subview:NView = EachIn _subviews
				view = subview.FindSubviewWithName(name, True)
				If view Then
					Return view
				EndIf
			Next
		EndIf
		Return Null
	End Method
	
	Method FindSubviewWithID:NView(id%, recurse%=True)
		For Local subview:NView = EachIn _subviews
			If subview._id = id Then
				Return subview
			EndIf
		Next
		If recurse Then
			Local view:NView
			For Local subview:NView = EachIn _subviews
				view = subview.FindSubviewWithID(id, True)
				If view Then
					Return view
				EndIf
			Next
		EndIf
		Return Null
	End Method
	
	' Returns true if the event was handled, false if not (event will be passed to the next root view/window)
	' If it returns true, that view will handle all future mouse events until the mouse is released
	' The mouse coordinates are converted to this view's coordinate system before it's passed
	' Subclasses should call this first to determine whether or not a subview is more suitable for receipt of the event,
	' then if the method returns null, handle the event themselves
	Method MousePressed:NView(button%, x%, y%)
		Bounds(_temp_rect)
'		If _temp_rect.Contains(x, y) Then
			x :- _temp_rect.origin.x
			y :- _temp_rect.origin.y
			Local point:NPoint = New NPoint
			Local top:TLink = _subviews.LastLink()
			Local subview:NView
			While top
				subview = NView(top.Value())
				
				If subview.Hidden() Or Not NWindow(subview) Then
					top = top.PrevLink()
					Continue
				EndIf
				
				subview.Frame(_temp_rect)
'				If _temp_rect.Contains(x, y) Then
					point.Set(x-_temp_rect.origin.x, y-_temp_rect.origin.y)
					Local view:NView = subview.MousePressed(button, point.x, point.y)
					If view Then
						Return view
					EndIf
'				EndIf
				top = top.PrevLink()
			Wend
			
			top = _subviews.LastLink()
			While top
				subview = NView(top.Value())
				
				If subview.Hidden() Or NWindow(subview) Then
					top = top.PrevLink()
					Continue
				EndIf
				
				subview.Frame(_temp_rect)
'				If _temp_rect.Contains(x, y) Then
					point.Set(x-_temp_rect.origin.x, y-_temp_rect.origin.y)
					Local view:NView = subview.MousePressed(button, point.x, point.y)
					If view Then
						Return view
					EndIf
'				EndIf
				top = top.PrevLink()
			Wend
'		EndIf
		
		Return Null
	End Method
	
	Method MouseMoved:NView(x%, y%, dx%, dy%)
		Bounds(_temp_rect)
		x :- _temp_rect.origin.x
		y :- _temp_rect.origin.y
		Local point:NPoint = New NPoint
		' TODO: reverse order of iteration to hit top-most first and bottom-most last
		Local subview:NView
		Local top:TLink = _subviews.LastLink()
		While top
			subview = NView(top.Value())
			If subview.Hidden() Or Not NWindow(subview) Then
				top = top.PrevLink()
				Continue
			EndIf
			
			subview.Frame(_temp_rect)
			point.Set(x-_temp_rect.origin.x, y-_temp_rect.origin.y)
			Local view:NView = subview.MouseMoved(point.x, point.y, dx, dy)
			If view Then
				Return view
			EndIf
			top = top.PrevLink()
		Wend
		
		top = _subviews.LastLink()
		While top
			subview = NView(top.Value())
			If subview.Hidden() Or NWindow(subview) Then
				top = top.PrevLink()
				Continue
			EndIf
			
			subview.Frame(_temp_rect)
			point.Set(x-_temp_rect.origin.x, y-_temp_rect.origin.y)
			Local view:NView = subview.MouseMoved(point.x, point.y, dx, dy)
			If view Then
				Return view
			EndIf
			top = top.PrevLink()
		Wend
		
		Local frame:NRect = Frame(_temp_rect)
		frame.origin.Set(0, 0)
		If frame.Contains(x, y) Then
			Return Self
		EndIf
		
		Return Null
	End Method
	
	Method MouseReleased%(button%, x%, y%)
		Return False
	End Method
	
	Method MouseEntered%()
		Return False
	End Method
	
	Method MouseLeft%()
		Return False
	End Method
	
	' Draws the view.  Origin is set to the control's position on screen and the viewport is set to clip the view when drawing.
	Method Draw()
	End Method
	
	Method DrawSubwindows()
		Local clip:NRect = New NRect
		
		Local tvx%, tvy%, tvw%, tvh%
		GetViewport(tvx, tvy, tvw, tvh)
		
		Local ox#, oy#
		GetOrigin(ox, oy)
		Local vx%,vy%,vw%,vh%
		GetViewport(vx,vy,vw,vh)
		Local bx#,by#
		Local bounds:NRect = Bounds(_temp_rect)
		bx = ox+bounds.origin.x
		by = oy+bounds.origin.y
		
		Local gx%, gy%
		gx = GraphicsWidth()
		gy = GraphicsHeight()
		
		Local clipsub:Int = ClipsSubviews()
		
		For Local subview:NView = EachIn _subviews
			If subview.Hidden() Then
				Continue
			EndIf
			
			SetViewport(0, 0, gx, gy)
			
			If NWindow(subview) Then
				Local frame:NRect = subview.Frame(_temp_rect)
				frame.origin.Set(0, 0)
				subview.ConvertPointToScreen(frame.origin, frame.origin)
				SetOrigin(Floor(frame.origin.x), Floor(frame.origin.y))
				
				' draw view
				subview.Draw()
			
				_ClipSubview(subview, vx, vy, vw, vh)
				' draw subviews
				subview.DrawSubviews()
			EndIf
			subview.DrawSubwindows()
		Next
		' undo clipping changes
		SetOrigin(ox, oy)
		SetViewport(tvx, tvy, tvw, tvh)
	End Method
	
	Method DrawSubviews()
		Local clip:NRect = New NRect
		
		Local tvx%, tvy%, tvw%, tvh%
		GetViewport(tvx, tvy, tvw, tvh)
		
		If _superview = Null And ClipsSubviews() Then
			Frame(_temp_rect)
			ClippingRect(clip)
			SetViewport(_temp_rect.origin.x+clip.origin.x, _temp_rect.origin.y+clip.origin.y, clip.size.width, clip.size.height)
		EndIf
		
		Local ox#, oy#
		GetOrigin(ox, oy)
		Local vx%,vy%,vw%,vh%
		GetViewport(vx,vy,vw,vh)
		Local bx#,by#
		Local bounds:NRect = Bounds(_temp_rect)
		bx = ox+bounds.origin.x
		by = oy+bounds.origin.y
		
		Local clipsub:Int = ClipsSubviews()
		
		For Local subview:NView = EachIn _subviews
			If subview.Hidden() Then
				Continue
			EndIf
			
			If NWindow(subview) Then
				Continue
			EndIf
			
			_ClipSubview(subview, vx, vy, vw, vh)
			' draw view
			subview.Draw()
			' draw subviews
			subview.DrawSubviews()
		Next
		' undo clipping changes
		SetOrigin(ox, oy)
		SetViewport(tvx, tvy, tvw, tvh)
	End Method
	
	Method _ClipSubview(subview:NView, vx%, vy%, vw%, vh%)
		Local clip:NRect
		' construct clipped viewport
		subview.Frame(_temp_rect)
		_temp_rect.origin.Set(0, 0)
		subview.ConvertPointToScreen(_temp_rect.origin, _temp_rect.origin)
		
		' set the screen origin of the view
		SetOrigin(Floor(_temp_rect.origin.x), Floor(_temp_rect.origin.y))
		
		' clip the subview's drawing if the superview clips subviews
		If subview.ClipsSubviews() Then
			clip = subview.ClippingRect(clip)
			subview.ConvertPointToScreen(clip.origin, clip.origin)
			clip.origin.x = Floor(clip.origin.x)
			clip.origin.y = Floor(clip.origin.y)
			_temp_rect.Set(vx, vy, vw, vh)
			clip.Intersection(_temp_rect, clip)
			SetViewport(clip.origin.x, clip.origin.y, clip.size.width, clip.size.height)
		Else
			SetViewport(vx, vy, vw, vh)
		EndIf
	End Method
	
	Method Frame:NRect(out:NRect=Null)
		If out Then
			out.CopyValues(_frame)
			Return out
		EndIf
		Return _frame.Clone()
	End Method
	
	Method SetFrame(frame:NRect)
		If _frame <> frame Then
			_frame.CopyValues(frame)
		EndIf
	End Method
	
	' Returns the relative bounds - this is where content is placed (usually just 0,0,width,height)
	Method Bounds:NRect(out:NRect=Null)
		If Not out Then
			out = New NRect
		EndIf
		If _bounds Then
			out.CopyValues(_bounds)
		Else
			out.CopyValues(_frame)
			out.origin.Set(0, 0)
		EndIf
		Return out
	End Method
	
	Method SetBounds(bounds:NRect)
		If _bounds <> bounds Then
			If _bounds = Null Then
				_bounds = bounds.Clone()
			ElseIf bounds
				_bounds.CopyValues(bounds)
			Else
				bounds = Null
			EndIf
		EndIf
	End Method
	
	' Returns the relative clipping rect (this is usually just 0,0,width,height)
	Method ClippingRect:NRect(out:NRect)
		If Not out Then
			out = New NRect
		EndIf
		out.origin.Set(0, 0)
		out.size.CopyValues(_frame.size)
		Return out
	End Method
	
	' Lays out subviews if necessary, by default does nothing
	Method PerformLayout()
	End Method
	
	' Returns the minimum possible size of the view
	Method MinimumSize:NRect(out:NRect=Null)
		If Not out Then
			out = New NRect
		EndIf
		out.CopyValues(_min_size)
		Return out
	End Method
	
	Method Superview:NView()
		Return _superview
	End Method
	
	Method AddSubview(view:NView, position:Int=NVIEW_ABOVE)
		Assert view.Superview() = Null Else "View already has a superview"
		If position = NVIEW_ABOVE Then
			_subviews.AddLast(view)
		ElseIf position = NVIEW_BELOW Then
			_subviews.AddFirst(view)
		End If
		view._superview = Self
	End Method
	
	Method RemoveFromSuperview()
		Assert _superview Else "View does not have a superview"
		_superview._subviews.Remove(Self)
		_superview = Null
	End Method
	
	Method Window:NWindow()
		Local sv:NView = _superview
		While sv
			If NWindow(sv) Then
				Return NWindow(sv)
			EndIf
			sv = sv._superview
		Wend
		Return Null
	End Method
	
	Method Root:NView()
		Local sv:NView
		sv = Self
		While sv._superview
			sv = sv._superview
		Wend
		Return sv
	End Method
	
	Method ConvertPointFromView:NPoint(point:NPoint, from:NView=Null, out:NPoint=Null)
		If Not out Then
			out = New NPoint
		EndIf
		
		Local ox#, oy#
		ox = point.x
		oy = point.y
		
		If Not from Then
			from = Root()
		EndIf
		
		Local frame:NRect = from.Frame(_temp_rect)
	
		ox :+ frame.origin.x
		oy :+ frame.origin.y
	
		from = from.Superview()
	
		Local bounds:NRect
	
		While from
			frame = from.Frame(_temp_rect)
			ox :+ frame.origin.x
			oy :+ frame.origin.y
			bounds = from.Bounds(_temp_rect)
			ox :+ bounds.origin.x
			oy :+ bounds.origin.y
			from = from.Superview()
		Wend
		
		ox :- _frame.origin.x
		oy :- _frame.origin.y
		
		Local sv:NView = Superview()
		While sv
			frame = sv.Frame(_temp_rect)
			ox :- frame.origin.x
			oy :- frame.origin.y
			bounds = sv.Bounds(_temp_rect)
			ox :- bounds.origin.x
			oy :- bounds.origin.y
			sv = sv.Superview()
		Wend
	End Method
	
	Method ConvertPointToScreen:NPoint(point:NPoint, out:NPoint=Null)
		If Not out Then
			out = New NPoint
		EndIf
		
		Local ox#, oy#
		ox = point.x
		oy = point.y
		
		Local rect:NRect
		Local sv:NView = Superview()
		While sv
			rect = sv.Frame(rect)
			ox :+ rect.origin.x
			oy :+ rect.origin.y
			rect = sv.Bounds(rect)
			ox :+ rect.origin.x
			oy :+ rect.origin.y
			sv = sv.Superview()
		Wend
		
		rect = Frame(_temp_rect)
		ox :+ rect.origin.x
		oy :+ rect.origin.y
		
		out.x = ox
		out.y = oy
		Return out
	End Method
	
	Method ConvertPointFromScreen:NPoint(point:NPoint, out:NPoint=Null)
		If Not out Then
			out = New NPoint
		EndIf
		
		Local ox#, oy#
		ox = point.x
		oy = point.y
		
		Local rect:NRect = Frame(_temp_rect)
		ox :- rect.origin.x
		oy :- rect.origin.y
		
		Local sv:NView = Superview()
		While sv
			rect = sv.Frame(rect)
			ox :- rect.origin.x
			oy :- rect.origin.y
			rect = sv.Bounds(rect)
			ox :- rect.origin.x
			oy :- rect.origin.y
			sv = sv.Superview()
		Wend
		
		out.x = ox
		out.y = oy
		Return out
	End Method
	
	Method ClipsSubviews:Int()
		Return True
	End Method
	
	Method SetText(text$)
		_text = text
	End Method

	Method Text$()
		Return _text
	End Method
	
	Method SetHidden(hidden%)
		_hidden = hidden
	End Method
	
	Method Hidden%()
		Return _hidden
	End Method
	
	Method SetDisabled(disabled%)
		_disabled = disabled
	End Method
	
	Method Disabled%()
		Return _disabled
	End Method
	
	Method Subviews:TList()
		Return _subviews.Copy()
	End Method
	
	Method SetEventHandler(eventname$, handler:NEventHandler)
		_eventhandlers.Insert(eventname, handler)
	End Method
	
	Method RemoveEventHandler(eventname$, handler:NEventHandler)
		_eventhandlers.Remove(eventname)
	End Method
	
	Method FireEvent(name$, eventdata:TMap)
		Local handler:NEventHandler = NEventHandler(_eventhandlers.ValueForKey(name))
		If handler Then handler.Fire(Self, eventdata)
	End Method
End Type
