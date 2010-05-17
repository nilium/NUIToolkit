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
Import "Scrollbar.bmx"

Private

Type _NSVHScrollbar Extends NHScrollbar
	Field _scrollview:NScrollView
	Method OnScroll:Int(value!,prev!)
		Local frame:NRect = _temp_rect
		Local clipWidth# = _scrollview._clipView.Bounds(frame).size.width
		Local contentWidth# = _scrollview._contentView.Frame(frame).size.width
		
		frame.origin.x = GetPercentage()*-(contentWidth-clipWidth)
		_scrollview._contentView.SetFrame(frame)
'		_scrollview.PerformLayout()
	End Method
End Type

Type _NSVVScrollbar Extends NVScrollbar
	Field _scrollview:NScrollView
	Method OnScroll:Int(value!,prev!)
		Local frame:NRect = _temp_rect
		Local clipHeight# = _scrollview._clipView.Bounds(frame).size.height
		Local contentHeight# = _scrollview._contentView.Frame(frame).size.height
		
		frame.origin.y = GetPercentage()*-(contentHeight-clipHeight)
		_scrollview._contentView.SetFrame(frame)
'		_scrollview.PerformLayout()
	End Method
End Type

Public

Type NScrollView Extends NView
	Field _hbar:NHScrollbar
	Field _vbar:NVScrollbar
	Field _clipView:NView
	Field _contentView:NView
	
	Method _AddSubview(view:NView, position:Int=NVIEW_ABOVE) NoDebug
		Super.AddSubview(view, position)
	End Method
	
	Method InitWithFrame:NScrollView(frame:NRect)
		_contentView = New NView.InitWithFrame(frame)
		_hbar = New _NSVHScrollbar.InitWithFrame(frame)
		_vbar = New _NSVVScrollbar.InitWithFrame(frame)
		
		_NSVHScrollbar(_hbar)._scrollview = Self
		_NSVVScrollbar(_vbar)._scrollview = Self
		
		_clipView = New NView.InitWithFrame(frame)
		_clipView.AddSubview(_contentView)
		_AddSubview(_clipView)
		_AddSubview(_hbar)
		_AddSubview(_vbar)
		
		Super.InitWithFrame(frame)
		
		Return Self
	End Method
	
	Method PerformLayout()
		Local barWidth#=_vbar.Frame(_temp_rect).size.width
		Local barHeight#=_hbar.Frame(_temp_rect).size.height
		Local frame:NRect = Bounds(_temp_rect)
		
		frame.origin.Set(0,0)
		frame.size.height :- barHeight
		frame.size.width :- barWidth
		
		_hbar.SetHidden(False)
		_vbar.SetHidden(False)
		
		Local contentFrame:NRect = _contentview.Frame()
		If contentFrame.origin.x + contentFrame.size.width < frame.size.width Then
			contentFrame.origin.x = Min(0, contentFrame.origin.x + (frame.size.width - (contentFrame.origin.x + contentFrame.size.width)))
			_hbar.SetValue(contentFrame.size.width)
		EndIf

		If contentFrame.size.width <= frame.size.width Then
			frame.size.height :+ barHeight
			contentFrame.origin.x = 0
			_hbar.SetValue(0)
			_hbar.SetHidden(True)
		EndIf
		
		If contentFrame.origin.y + contentFrame.size.height < frame.size.height Then
			contentFrame.origin.y = Min(0, contentFrame.origin.y + (frame.size.height - (contentFrame.origin.y + contentFrame.size.height)))
			_vbar.SetValue(contentFrame.size.width)
		EndIf

		If contentFrame.size.height <= frame.size.height Then
			frame.size.width :+ barWidth
			contentFrame.origin.y = 0
			_vbar.SetValue(0)
			_vbar.SetHidden(True)
		EndIf
		
		If _hbar.Hidden() And Not _vbar.Hidden() And contentFrame.size.height <= frame.size.height Then
			frame.size.width :+ barWidth
			contentFrame.origin.y = 0
			_vbar.SetValue(0)
			_vbar.SetHidden(True)
		EndIf
		
		If _vbar.Hidden() And Not _hbar.Hidden() And contentFrame.size.width <= frame.size.width Then
			frame.size.height :+ barHeight
			contentFrame.origin.x = 0
			_hbar.SetValue(0)
			_hbar.SetHidden(True)
		EndIf
		
		_contentView.SetFrame(contentFrame)
		_clipView.SetFrame(frame)
		
		_vbar.SetMaximum(contentFrame.size.height)
		_vbar.SetStep(frame.size.height)
		_vbar.SetPercentage(-contentFrame.origin.y/(contentFrame.size.height-frame.size.height))
		
		_hbar.SetMaximum(contentFrame.size.width)
		_hbar.SetStep(frame.size.width)
		_hbar.SetPercentage(-contentFrame.origin.x/(contentFrame.size.width-frame.size.width))
		
		If Not _vbar.Hidden() Then
			frame = Bounds(frame)
			frame.origin.Set(frame.size.width-barWidth, 0)
			frame.size.width = barWidth
			frame.size.height :- barHeight*(Not _hbar.Hidden())
			_vbar.SetFrame(frame)
		EndIf
		
		If Not _hbar.Hidden() Then
			frame = Bounds(frame)
			frame.origin.Set(0, frame.size.height-barHeight)
			frame.size.width :- barWidth*(Not _vbar.Hidden())
			frame.size.height = barHeight
			_hbar.SetFrame(frame)
		EndIf
		
		frame = _clipView.Frame(frame)
	End Method
	
	Method AddSubview(view:NView, position:Int=NVIEW_ABOVE)
		_contentview.AddSubview(view, position)
	End Method
	
	Method ContentView:NView()
		Return _contentView
	End Method
	
	Method SetContentView(view:NView)
		_contentView.RemoveFromSuperview()
		_contentView = view
		_contentView.Frame(_temp_rect)
		_temp_rect.origin.Set(0,0)
		_clipView.AddSubview(_contentView)
		_contentView.SetFrame(_temp_rect)
		PerformLayout()
	End Method
	
	Method SetContentSize(size:NSize)
		_contentView.Frame(_temp_rect)
		_temp_rect.size.CopyValues(size)
		_contentView.SetFrame(_temp_rect)
		PerformLayout()
		_clipView.Frame(_temp_rect)
	End Method
	
	Method SetFrame(frame:NRect)
		Super.SetFrame(frame)
		PerformLayout()
	End Method
End Type

