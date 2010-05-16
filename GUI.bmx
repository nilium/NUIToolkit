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

Type NGUI
	Field _windows:TList = New TList
	Field _mainWindow:NWindow=Null
	Field _mouseWindow:NView=Null
	Field _temp_rect:NRect = New NRect
	
	Field _mouse_btn%[3,2] ' button, 0=cur, 1=last
	Field _mouse_prev:NPoint = New NPoint
	Field _mouse_cur:NPoint = New NPoint
	
	Field _overView:NView
	
	Function EventHook:Object(id%, data:Object, ctx:Object)
		Local gui:NGUI = NGUI(ctx)
		Local evt:TEvent = TEvent(data)
		If gui Then
			If id = EmitEventHook And evt Then
				Select evt.id
					Case EVENT_MOUSEDOWN
						Local point:NPoint
						Local top:TLink = gui._windows.LastLink()
						gui._mouse_prev.CopyValues(gui._mouse_cur)
						gui._mouse_cur.x = evt.x
						gui._mouse_cur.y = evt.y
						
						While top
							Local window:NWindow = NWindow(top.Value())
							If window.Frame(gui._temp_rect).Contains(evt.x, evt.y) Then
								Local frame:NRect = window.Frame(gui._temp_rect)
								Local view:NView = window.MousePressed(evt.x - frame.origin.x, evt.y - frame.origin.y)
								If view Then
									gui._mouseWindow = view
									If gui._overView <> gui._mouseWindow Then
										If gui._overView Then
											gui._overView.MouseLeft()
										EndIf
										gui._overView = view
										view.MouseEntered()
									EndIf
								EndIf
								Exit
							EndIf
							top = top.PrevLink()
						Wend
					Case EVENT_MOUSEUP
						gui._mouse_btn[evt.data, 1] = True
						gui._mouse_btn[evt.data, 0] = False
						gui._mouse_prev.CopyValues(gui._mouse_cur)
						gui._mouse_cur.x = evt.x
						gui._mouse_cur.y = evt.y
						If gui._mouseWindow Then
							Local point:NPoint = gui._mouseWindow.ConvertPointFromScreen(gui._mouse_cur)
							If Not gui._mouse_cur.Equals(gui._mouse_prev) Then
								gui._mouseWindow.MouseMoved(point.x, point.y, evt.x - gui._mouse_prev.x, evt.y - gui._mouse_prev.y)
							EndIf
							gui._mouseWindow.MouseReleased(point.x, point.y)
							Local frame:NRect = gui._mouseWindow.Frame(gui._temp_rect)
							frame.origin.Set(0, 0)
							If Not frame.ContainsPoint(point) Then
								gui._overView.MouseLeft()
								gui._overView = Null
							EndIf
							gui._mouseWindow = Null
						EndIf
					Case EVENT_MOUSEMOVE
						gui._mouse_prev.CopyValues(gui._mouse_cur)
						gui._mouse_cur.x = evt.x
						gui._mouse_cur.y = evt.y
						If gui._mouseWindow Then
							Local point:NPoint = gui._mouseWindow.ConvertPointFromScreen(gui._mouse_cur)
							gui._mouseWindow.MouseMoved(point.x, point.y, evt.x-gui._mouse_prev.x, evt.y-gui._mouse_prev.y)
						Else
							Local dx# = evt.x-gui._mouse_prev.x
							Local dy# = evt.y-gui._mouse_prev.y
							'Local top:TLink = gui._windows.LastLink()
							Local set%=0
							'While top
							Local window:NWindow = gui._mainWindow
							If window Then
								If window.Frame(gui._temp_rect).Contains(evt.x, evt.y) Then
									Local frame:NRect = window.Frame(gui._temp_rect)
									Local view:NView = window.MouseMoved(evt.x - frame.origin.x, evt.y - frame.origin.y, dx, dy)
									If view Then
										set=True
										If gui._overView <> view Then
											If gui._overView Then
												gui._overView.MouseLeft()
											EndIf
										EndIf
										gui._overView = view
										view.MouseEntered()
'										Exit
									EndIf
								EndIf
'								top = top.PrevLink()
							EndIf
							If gui._overView And Not set Then
								gui._overView.MouseLeft()
								gui._overView = Null
							EndIf
						EndIf
				End Select
			ElseIf id = FlipHook Then
'				_mouse_btn[0, 1] = _mouse_btn[0, 0]
'				_mouse_btn[1, 1] = _mouse_btn[1, 0]
'				_mouse_btn[2, 1] = _mouse_btn[2, 0]
'				_mouse_prev.CopyValues(_mouse_cur)
			EndIf
		EndIf
		Return data
	End Function
	
	Method New()
		_mouse_cur.x = MouseX()
		_mouse_cur.y = MouseY()
		AddHook(EmitEventHook, EventHook, Self)
		AddHook(FlipHook, EventHook, Self)
	End Method
	
	Method Draw()
		Local vx%, vy%, vw%, vh%
		GetViewport(vx, vy, vw, vh)
		Local ox#, oy#
		GetOrigin(ox, oy)
		
		Local gw% = GraphicsWidth()
		Local gh% = GraphicsHeight()
		
		For Local window:NWindow = EachIn _windows
			Local frame:NRect = window.Frame(_temp_rect)
			SetOrigin(frame.origin.x, frame.origin.y)
			SetViewport(0, 0, gw, gh)
			window.Draw()
		Next
		
		SetOrigin(ox, oy)
		SetViewport(vx, vy, vw, vh)
	End Method
	
	Method AddWindow(window:NWindow, position:Int=WINDOW_BELOWMAIN)
		Assert window Else "Window is Null"
		Assert window._gui = Null Else "Window is already attached to a GUI instance"
		window._gui = Self
		
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
End Type

Type NWindow Extends NView
	Field _gui:NGUI
	Field _modal:Int = False
	Field _contentView:NView
	
	Method GUI:NGUI()
		Return _gui
	End Method
	
	Method MousePressed:NView(x%, y%)
		If Not IsMainWindow() Then
			MakeMainWindow()
		EndIf
		
		Return Super.MousePressed(x, y)
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
	
	Method Draw() Final
		DrawFrame()
		Super.Draw()
	End Method
	
	Method ClipsSubviews:Int() Final
		Return True
	End Method
	
	Method IsMainWindow:Int() Final
		Return (_gui And _gui._mainWindow = Self)
	End Method
	
	Method MakeMainWindow:Int() Final
		_gui._mainWindow = Self
		_gui._windows.Remove(Self)
		_gui._windows.AddLast(Self)
		'TODO: Move into NGUI, ensure insertion below modal windows
	End Method
	
	Method ContentView:NView()
		Return _contentView
	End Method
	
	Method SetContentView(view:NView)
		_contentView.RemoveFromSuperview()
		_contentView = view
		Super.AddSubview(_contentView)
		PerformLayout()
	End Method
	
	Method AddSubview(view:NView, position:Int=NVIEW_ABOVE)
		_contentView.AddSubview(view, position)
	End Method
	
	Method PerformLayout()
		Local bounds:NRect = Bounds(_temp_rect)
		bounds.origin.Set(0, 0)
		_contentView.SetFrame(bounds)
	End Method
End Type

Const NVIEW_ABOVE:Int = 1
Const NVIEW_BELOW:Int = -1

Type NView
	Field _superview:NView
	Field _subviews:TList = New TList
	Field _frame:NRect = New NRect
	Field _bounds:NRect = Null
	Field _min_size:NRect = New NRect ' TODO: make use of this
	Field _temp_rect:NRect = New NRect
	Field _text$=""
	
	Method InitWithFrame:NView(frame:NRect)
		SetFrame(frame)
		Return Self
	End Method
	
	' Returns true if the event was handled, false if not (event will be passed to the next root view/window)
	' If it returns true, that view will handle all future mouse events until the mouse is released
	' The mouse coordinates are converted to this view's coordinate system before it's passed
	' Subclasses should call this first to determine whether or not a subview is more suitable for receipt of the event,
	' then if the method returns null, handle the event themselves
	Method MousePressed:NView(x%, y%)
		If Bounds(_temp_rect).Contains(x, y) Then
			x :- _temp_rect.origin.x
			y :- _temp_rect.origin.y
			Local point:NPoint = New NPoint
			For Local subview:NView = EachIn _subviews
				If subview.Frame(_temp_rect).Contains(x, y) Then
					point.Set(x-_temp_rect.origin.x, y-_temp_rect.origin.y)
					Local view:NView = subview.MousePressed(point.x, point.y)
					If view Then
						Return view
					EndIf
				EndIf
			Next
		EndIf
		
		Return Null
	End Method
	
	Method MouseMoved:NView(x%, y%, dx%, dy%)
		If Bounds(_temp_rect).Contains(x, y) Then
			x :- _temp_rect.origin.x
			y :- _temp_rect.origin.y
			Local point:NPoint = New NPoint
			For Local subview:NView = EachIn _subviews
				If subview.Frame(_temp_rect).Contains(x, y) Then
					point.Set(x-_temp_rect.origin.x, y-_temp_rect.origin.y)
					Local view:NView = subview.MouseMoved(point.x, point.y, dx, dy)
					If view Then
						Return view
					EndIf
				EndIf
			Next
		EndIf
		Return Self
	End Method
	
	Method MouseReleased%(x%, y%)
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
		DrawSubviews()
	End Method
	
	Method DrawSubviews() Final
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
			' construct clipped viewport
			subview.Bounds(_temp_rect)
			subview.ConvertPointToScreen(_temp_rect.origin, _temp_rect.origin)
			
			' set the screen origin of the view
			SetOrigin(_temp_rect.origin.x, _temp_rect.origin.y)
			
			' clip the subview's drawing if the superview clips subviews
			If subview.ClipsSubviews() Then
				subview.ClippingRect(clip)
				subview.ConvertPointToScreen(clip.origin, clip.origin)
				_temp_rect.Set(vx, vy, vw, vh)
				clip.Intersection(_temp_rect, clip)
				SetViewport(clip.origin.x, clip.origin.y, clip.size.width, clip.size.height)
			Else
				SetViewport(vx, vy, vw, vh)
			EndIf
			
			' draw view
			subview.Draw()
		Next
		' undo clipping changes
		SetOrigin(ox, oy)
		SetViewport(tvx, tvy, tvw, tvh)
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
			_bounds.CopyValues(bounds)
		EndIf
		PerformLayout()
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

	Method GetText$()
		Return _text
	End Method
End Type

