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
Import "ImageDrawable.bmx"
Import "NinePatch.bmx"
Import "GraphicsContext.bmx"
Import "Max2DGraphicsState.bmx"

Const WINDOW_RAISEDMAIN%=2
Const WINDOW_RAISED%=1
Const WINDOW_BELOWMAIN%=0
Const WINDOW_BELOWALL%=-1

Global ActiveGUI:NGUI = Null

Rem
bbdoc: Main NUIT class, handles event propagation and rendering of windows.
EndRem
Type NGUI
	Field _active:Int=False
	
	Field _windows:TList = New TList
	Field _mainWindow:NWindow=Null
	Field _mouseWindow:NView=Null
	Field _focalView:NView=Null
	Field _temp_rect:NRect = New NRect
	
	Field _mouse_btn%[16,2] ' button (16 because I'm paranoid and it's a nice number), 0=cur, 1=last
	Field _mouse_prev:NPoint = New NPoint
	Field _mouse_cur:NPoint = New NPoint
	
	Field _overView:NView
	Field _popup:NPopup
	
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
		If ActiveGUI = Null Then
			ActiveGUI = Self
		EndIf
	End Method
	
	Rem
	bbdoc: Makes this the active instance #NGUI.  This <strong>must</strong> be done before you can work with controls for a given GUI instance.
	EndRem
	Method MakeActive()
		ActiveGUI = Self
	End Method
	
	Rem
	bbdoc: Makes this #NGUI instance inactive.  It can be reactivated by calling #MakeActive.
	EndRem
	Method Dispose()
		Assert ActiveGUI=Self
		ActiveGUI = Null
		DisableEventHook()
	End Method
	
	Rem
	bbdoc: Enables a hook for the #EmitEventHook that automates propagation of events (instead of sending them into the NGUI instance via #PushEvent).  By default, the hook is disabled.
	EndRem
	Method EnableEventHook()
		If _active = False Then
			_active = True
			AddHook(EmitEventHook, EventHook, Self)
		EndIf
	End Method
	
	Rem
	bbdoc: Disables the hook that was previously enabled by #EnableEventHook.
	EndRem
	Method DisableEventHook()
		If _active Then
			_active = False
			RemoveHook(EmitEventHook, EventHook, Self)
		EndIf
	End Method
	
	Rem
	bbdoc: Pushes an event to the GUI and propagates it through the view hierarchy.  Only accepts EVENT_MOUSEDOWN, EVENT_MOUSEUP, EVENT_MOUSERELEASE events.
	EndRem
	Method PushEvent(evt:TEvent)
		Select evt.id
			Case EVENT_MOUSEDOWN
				Local point:NPoint = Null
				Local view:NView = Null
				Local top:TLink = _windows.LastLink()
				_mouse_prev.CopyValues(_mouse_cur)
				_mouse_cur.x = evt.x
				_mouse_cur.y = evt.y
				
				If _popup And Not _popup.Hidden() Then
					point = _popup.ConvertPointFromScreen(_mouse_cur, point)
					view = _popup.ViewForPoint(point)
					If view = Null Then
						_popup.Hide()
						_popup = Null
					EndIf
				ElseIf _popup And _popup.Hidden() Then
					_popup = Null
				EndIf
				
				While top And Not view
					Local window:NWindow = NWindow(top.Value())
					If window.Hidden() Then
						top = top.PrevLink()
						Continue
					EndIf
					point = window.ConvertPointFromScreen(_mouse_cur, point)
					view = window.ViewForPoint(point)
					top = top.PrevLink()
				Wend
				
				_mouseWindow = view
				
				If _overView <> view Then
					If _overView Then _overView.MouseLeft()
					_overView = view
					If _overView Then _overView.MouseEntered()
				EndIf
				
				If view <> _focalView Then
					If _focalView Then _focalView.FocusLost()
					_focalView = view
					If view Then view.FocusGained()
				EndIf
				
				If view And Not view.Disabled(True) Then
					_mouseWindow = view
					point = view.ConvertPointFromScreen(_mouse_cur, point)
					view.MousePressed(evt.data, point.x, point.y)
'					view.MouseMoved(point.x, point.y, evt.x - _mouse_prev.x, evt.y - _mouse_prev.y)
					Local window:NWindow = NWindow(view.Root())
					If window Then
						SetMainWindow(window)
					EndIf
				EndIf
			Case EVENT_MOUSEUP
				_mouse_btn[evt.data, 1] = True
				_mouse_btn[evt.data, 0] = False
				_mouse_prev.CopyValues(_mouse_cur)
				_mouse_cur.x = evt.x
				_mouse_cur.y = evt.y
				If _mouseWindow And Not _mouseWindow.Hidden() And Not _mouseWindow.Disabled(True) Then
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
				If _mouseWindow And Not _mouseWindow.Hidden() And Not _mouseWindow.Disabled(True) Then
					Local point:NPoint = _mouseWindow.ConvertPointFromScreen(_mouse_cur)
					_mouseWindow.MouseMoved(point.x, point.y, evt.x-_mouse_prev.x, evt.y-_mouse_prev.y)
				Else
					_mouseWindow = Null
					Local dx# = evt.x-_mouse_prev.x
					Local dy# = evt.y-_mouse_prev.y
					Local set% = False
					Local point:NPoint
					
					Local view:NView
					If _popup And Not _popup.Hidden() Then
						point = _popup.ConvertPointFromScreen(_mouse_cur, point)
						view = _popup.ViewForPoint(point)
					ElseIf _popup And _popup.Hidden() Then
						_popup = Null
					EndIf
					
					Local window:NWindow = _mainWindow
					If Not view And window And Not window.Hidden() And Not window.Disabled(True) Then
						point = window.ConvertPointFromScreen(_mouse_cur, point)
						view = window.ViewForPoint(point)
					EndIf
					
					If _overView <> view Then
						If _overView Then
							_overView.MouseLeft()
						EndIf
						_overView = view
						If view Then
							view.MouseEntered()
						EndIf
					EndIf
					
					If view And Not view.Disabled(True) Then
						view.MouseMoved(point.x, point.y, dx, dy)
					EndIf
				EndIf
		End Select
	End Method
	
	Rem
	bbdoc: Draws all root windows, subwindows, and popups and their associated view hierarchies.
	EndRem
	Method Draw()
		Local gw% = GraphicsWidth()
		Local gh% = GraphicsHeight()
		
		Local ctx:NGraphicsContext = New NGraphicsContext.InitWithGraphicsStateType(NMax2DGraphicsStateTypeID)
		ctx.SaveState()
		
		For Local window:NWindow = EachIn _windows
			If window.Hidden() Then
				Continue
			EndIf
			Local frame:NRect = window.Frame(_temp_rect)
			ctx.MoveToPoint(Floor(frame.origin.x), Floor(frame.origin.y))
			ctx.SetClipping(0, 0, gw, gh)
			ctx.SaveState()
			window.Draw()
			ctx.RestoreState()
			ctx.SaveState()
			window.DrawSubviews()
			ctx.RestoreState()
			ctx.SaveState()
			window.DrawSubwindows()
			ctx.RestoreState()
		Next
		
		If _popup Then
			If _popup.Hidden() Then
				_popup = Null
			Else
				Local point:NPoint = _temp_rect.origin
				point.Set(0, 0)
				_popup.ConvertPointToScreen(point, point)
				ctx.MoveToPoint(Floor(point.x), Floor(point.y))
				ctx.SetClipping(0, 0, gw, gh)
				ctx.SaveState()
				_popup.Draw()
				ctx.RestoreState()
				ctx.SaveState()
				_popup.DrawSubviews()
				ctx.RestoreState()
				ctx.SaveState()
				_popup.DrawSubWindows()
				ctx.RestoreState()
			EndIf
		EndIf
		
		ctx.RestoreState()
	End Method
	
	Rem
	bbdoc: Adds a root window to the GUI, optionally specifying its position relative to other windows.
	
	Windows can specify their position as one of the following:
	
	[ @{Position value} | @{Window position}
	
	* @WINDOW_BELOWMAIN | Places the window just below the main window.
	
	* @WINDOW_RAISED | Places the window above all windows without making it the main window.
	
	* @WINDOW_RAISEDMAIN | Places the window above all windows and makes it the main window.
	
	* @WINDOW_BELOWALL | Places the window below all other windows.
	]
	EndRem
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
		
		If _mainWindow = Null And position <> WINDOW_RAISEDMAIN Then
			SetMainWindow(window)
		EndIf
	End Method
	
	Rem
	bbdoc: Removes a root window.  If the window is the main window, no window will be main window afterward.
	EndRem
	Method RemoveWindow(window:NWindow)
		If _mainWindow = window Then
			_mainWindow = Null
		EndIf
	End Method
	
	Rem
	bbdoc: Sets the current main window.  Can be Null.
	EndRem
	Method SetMainWindow(window:NWindow)
		If window = _mainWindow Then
			Return
		EndIf
		If window And window.CanBecomeMainWindow() Then
			If _mainWindow Then
				_mainWindow.LostMainWindow()
			EndIf
			
			If window.Superview() = Null And _windows.Contains(window) Then
				_windows.Remove(window)
				_windows.AddLast(window)
			EndIf
			_mainWindow = window
			_mainWindow.BecameMainWindow()
			PushEvent(TEvent.Create(EVENT_MOUSEMOVE, Self, 0, 0, _mouse_cur.x, _mouse_cur.y))
		ElseIf window = Null And _mainWindow Then
			_mainWindow.LostMainWindow()
			_mainWindow = Null
			PushEvent(TEvent.Create(EVENT_MOUSEMOVE, Self, 0, 0, _mouse_cur.x, _mouse_cur.y))
		EndIf
	End Method
	
	Method SetPopup(popup:NPopup)
		Local differs:Int = _popup <> popup
		If _popup And differs Then
			_popup.Hide()
		EndIf
		_popup = popup
		If popup And differs Then
			popup.Show()
			PushEvent(TEvent.Create(EVENT_MOUSEMOVE, Self, 0, 0, _mouse_cur.x, _mouse_cur.y))
		EndIf
	End Method
End Type

Type NPopup Extends NView
End Type

Type NWindow Extends NView
	Field _modal:Int = False
	Field _contentView:NView
	
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
	
	Method LostMainWindow()
	End Method
	
	Method BecameMainWindow()
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
		If _contentView Then
			Local bounds:NRect = Bounds(_temp_rect)
			bounds.origin.Set(0, 0)
			_contentView.SetFrame(bounds)
		EndIf
	End Method
	
	Method SetFrame(frame:NRect)
		Super.SetFrame(frame)
		PerformLayout()
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
	Method Fire(sender:NView, eventname$, eventdata:TMap) Abstract
End Type

Type NEventHandlerCallback Extends NEventHandler
	Field _callback%(sender:NView, eventname$, eventdata:TMap)
	
	Method InitWithCallback:NEventHandler(callback%(sender:NView, eventname$, eventdata:TMap))
		_callback = callback
		Return Self
	End Method
	
	Method Fire(sender:NView, eventname$, eventdata:TMap)
		If _callback Then _callback(sender, eventname, eventdata)
	End Method
End Type

Function MakeEventHandler:NEventHandler(callback%(sender:NView, eventname$, eventdata:TMap))
	Return New NEventHandlerCallback.InitWithCallback(callback)
End Function

Const NFrameChangedEvent$="FrameChanged"
Const NBoundsChangedEvent$="BoundsChanged"
Const NMousePressedEvent$="MousePressed"
Const NMouseReleasedEvent$="MouseReleased"
Const NMouseMovedEvent$="MouseMoved"
Const NMouseEnteredEvent$="MouseEntered"
Const NMouseLeftEvent$="MouseLeft"
Const NFocusGainedEvent$="FocusGained"
Const NFocusLostEvent$="FocusLost"
Const NDisabledChangedEvent$="DisabledChanged"
Const NVisibilityChangedEvent$="VisibilityChanged"
Const NTextChangedEvent$="TextChanged"

Type NView
	Field _name$=""
	Field _tag:Object=Null
	Field _id%=0
	Field _superview:NView
	Field _subviews:TList = New TList
	Field _frame:NRect = New NRect
	Field _bounds:NRect = Null
	Field _min_size:NSize = New NSize
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
	
	Method FindSubviewWithName:NView(name$, searchSubviews%=True)
		Local bottom:TLink = _subviews.FirstLink()
		Local view:NView = Null
		If searchSubviews Then
			While bottom And view = Null
				Local subview:NView = NView(bottom.Value())
				If subview._name = name Then
					Return subview
				EndIf
				view = subview.FindSubviewWithName(name, True)
				bottom = bottom.NextLink()
			Wend
		EndIf
		While bottom
			Local subview:NView = NView(bottom.Value())
			If subview._name = name Then
				Return subview
			EndIf
			bottom = bottom.NextLink()
		Wend
		
		Return view
	End Method
	
	Method FindSubviewWithID:NView(id%, searchSubviews%=True)
		Local bottom:TLink = _subviews.FirstLink()
		Local view:NView = Null
		If searchSubviews Then
			While bottom And view = Null
				Local subview:NView = NView(bottom.Value())
				If subview._id = id Then
					Return subview
				EndIf
				view = subview.FindSubviewWithID(id, True)
				bottom = bottom.NextLink()
			Wend
		EndIf
		While bottom
			Local subview:NView = NView(bottom.Value())
			If subview._id = id Then
				Return subview
			EndIf
			bottom = bottom.NextLink()
		Wend
		
		Return view
	End Method
	
	Method IsSubviewOf:Int(view:NView)
		Local sv:NView = _superview
		While sv
			If sv = view Then
				Return True
			EndIf
			sv = sv.Superview()
		Wend
		Return False
	End Method
	
	
	Method MousePressed(button%, x%, y%)
		If _superview Then
			Local origin:NPoint = New NPoint
			origin.Set(x, y)
			origin.Add(_superview.Bounds(_temp_rect).origin, origin)
			origin.Add(_frame.origin, origin)
			_superview.MousePressed(button, origin.x, origin.y)
		EndIf
	End Method
	
	Method MouseMoved(x%, y%, dx%, dy%)
		If _superview Then
			Local origin:NPoint = New NPoint
			origin.Set(x, y)
			origin.Add(_superview.Bounds(_temp_rect).origin, origin)
			origin.Add(_frame.origin, origin)
			_superview.MouseMoved(origin.x, origin.y, dx, dy)
		EndIf
	End Method
	
	Method MouseReleased%(button%, x%, y%)
		If _superview Then
			Local origin:NPoint = New NPoint
			origin.Set(x, y)
			origin.Add(_superview.Bounds(_temp_rect).origin, origin)
			origin.Add(_frame.origin, origin)
			_superview.MouseReleased(button, origin.x, origin.y)
		EndIf
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
				frame.origin = subview.ConvertPointToScreen(frame.origin, frame.origin)
				SetOrigin(Floor(frame.origin.x), Floor(frame.origin.y))
				
				' draw view
				subview.Draw()
			
				clip = subview.Bounds(clip)
				clip.origin.x :+ frame.origin.x
				clip.origin.y :+ frame.origin.y
				SetViewport(clip.origin.x, clip.origin.y, clip.size.width, clip.size.height)
				
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
		
		If (_superview = Null Or NPopup(Self)) And ClipsSubviews() Then
			Frame(_temp_rect)
			ClippingRect(clip)
			Local point:NPoint = _temp_rect.origin
			point.Set(0, 0)
			point = ConvertPointToScreen(point, point)
			SetViewport(point.x+clip.origin.x, point.y+clip.origin.y, clip.size.width, clip.size.height)
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
			
			If NWindow(subview) Or NPopup(subview) Then
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
	
	Method FocusGained()
		FireEvent(NFocusGainedEvent, Null)
	End Method
	
	Method FocusLost()
		FireEvent(NFocusLostEvent, Null)
	End Method
	
	Method IsFocused%() Final
		Return (ActiveGUI._focalView = Self)
	End Method
	
	Method Frame:NRect(out:NRect=Null)
		If out Then
			out.CopyValues(_frame)
			Return out
		EndIf
		Return _frame.Clone()
	End Method
	
	Method SetFrame(frame:NRect)
		Local copy:NRect = Self.Frame()
		frame.size.Maximum(_min_size, frame.size)
		If _frame <> frame Then
			_frame.CopyValues(frame)
		EndIf
		If Not copy.Equals(_frame) Then
			FireEvent(NFrameChangedEvent)
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
		Local copy:NRect = Self.Bounds()
		If _bounds <> bounds Then
			If _bounds And bounds Then
				_bounds.CopyValues(bounds)
			ElseIf bounds
				_bounds = bounds.Clone()
			Else
				_bounds = Null
			EndIf
		EndIf
		FireEvent(NBoundsChangedEvent, Null)
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
	Method MinimumSize:NSize(out:NSize=Null)
		If Not out Then
			out = New NSize
		EndIf
		out.CopyValues(_min_size)
		Return out
	End Method
	
	Method SetMinimumSize:NSize(size:NSize)
		If _min_size <> size Then
			_min_size.CopyValues(size)
			SetFrame(Frame(_temp_rect))
		EndIf
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
		Local sv:NView = _superview
		sv._subviews.Remove(Self)
		_superview = Null
		sv.SubviewWasRemoved(Self)
	End Method
	
	Method SubviewWasRemoved(subview:NView)
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
		
		Return out
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
	
	Method ViewForPoint:NView(point:NPoint)
		Local temppoint:NPoint = New NPoint
		Local top:TLink = _subviews.LastLink()
		Local boundsOrigin:NPoint = Bounds(_temp_rect).origin.Clone()
		Bounds(_temp_rect)
		While top
			Local subview:NView = NView(top.Value())
			If Not subview.Hidden() Then
				temppoint.CopyValues(point)
				subview.Frame(_temp_rect)
				temppoint.Subtract(_temp_rect.origin, temppoint)
				temppoint.Subtract(boundsOrigin, temppoint)
				subview = subview.ViewForPoint(temppoint)
				If subview Then Return subview
			EndIf
			top = top.PrevLink()
		Wend
		Frame(_temp_rect)
		_temp_rect.origin.Set(0, 0)
		If _temp_rect.ContainsPoint(point) Then
			Return Self
		EndIf
		Return Null
	End Method
	
	Method ClipsSubviews:Int()
		Return False
	End Method
	
	Method SetText(text$)
		If text <> _text Then
			_text = text
			FireEvent(NTextChangedEvent, Null)
		EndIf
	End Method

	Method Text$()
		Return _text
	End Method
	
	Method SetHidden(hidden%)
		Local prev:Int = _hidden
		_hidden = 0<hidden
		If _hidden <> prev Then FireEvent(NVisibilityChangedEvent, Null)
	End Method
	
	Method Hidden%()
		Return _hidden
	End Method
	
	Method Show() Final
		SetHidden(False)
	End Method
	
	Method Hide() Final
		SetHidden(True)
	End Method
	
	Method SetDisabled(disabled%)
		Local prev:Int = _disabled
		_disabled = 0<disabled
		If _disabled <> prev Then FireEvent(NDisabledChangedEvent, Null)
	End Method
	
	Method Disabled%(_recurse:Int=False)
		Return _disabled Or (_recurse And (_superview And _superview.Disabled()))
	End Method
	
	Method Disable() Final
		SetDisabled(True)
	End Method
	
	Method Enable() Final
		SetDisabled(False)
	End Method
	
	Method Subviews:TList()
		Return _subviews.Copy()
	End Method
	
	Method AddEventHandler(eventname$, handler:NEventHandler)
		Assert handler Else "Event handler is Null"
		Local handlers:TList = TList(_eventhandlers.ValueForKey(eventname))
		If handlers = Null Then
			handlers = New TList
			_eventhandlers.Insert(eventname, handlers)
		EndIf
		handlers.AddLast(handler)
	End Method
	
	Method RemoveEventHandler(eventname$, handler:NEventHandler=Null)
		Local handlers:TList = TList(_eventhandlers.ValueForKey(eventname))
		If handlers = Null Then Return
		If handler Then
			handlers.Remove(handler)
		Else
			handlers.Clear()
		EndIf
	End Method
	
	Method FireEvent(eventname$, eventdata:TMap=Null)
		Local handlers:TList = TList(_eventhandlers.ValueForKey(eventname))
		If handlers = Null Then Return
		For Local handler:NEventHandler = EachIn handlers
			handler.Fire(Self, eventname, eventdata)
		Next
	End Method
End Type

' Drawables accessible to all controls

Type NGlobalDrawables Final
	Global ShadowPatch:NNinePatchDrawable = New NNinePatchDrawable.InitWithImageAndBorders(LoadImage("res/shadow.png"), 14, 14, 14, 14, 1)
End Type

' Auxiliary functions for drawing text

Function FitTextToWidth$(str$, width%)
	If width <= 0 Then
		Return ""
	EndIf
	
	Local trunc$=str
	Local twidth% = TextWidth(trunc)

	If width < twidth Then
		Repeat
			str = str[..str.Length-2]
			trunc = str+"..."
			twidth = TextWidth(trunc)
		Until str.Length=0 Or twidth<width
	EndIf
	
	If width < twidth Then
		trunc = ""
	EndIf
	
	Return trunc
End Function

