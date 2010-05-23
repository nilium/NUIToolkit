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

Private

Type NLayoutRule Extends NEventHandler Abstract
	Field owner:NRelativeLayout
	
	Method Fire(sender:NView, name$, data:TMap)
		owner.PerformLayout()
	End Method
End Type

Type NRelativeLayoutRule Extends NLayoutRule Final
	Field param:String
	Field base:NView
	Field margin:Int
End Type

Public

Const NLFillHorizontal$ = "FillHorizontal"				' Make the view's X and width match the base's X and width
Const NLFillVertical$ = "FillVertical"                  ' Make the view's Y and height match the base's Y and height
Const NLAlignTop$ = "AlignTop"                          ' Align the top of the view with the top of the base
Const NLAlignBottom$ = "AlignBottom"                    ' Align the bottom edge of the view with the bottom edge of the base
Const NLAlignLeft$ = "AlignLeft"                        ' Align the left edge of the view with the left edge of the base
Const NLAlignRight$ = "AlignRight"                      ' Align the right edge of the view with the right edge of the base
Const NLCenterTop$ = "CenterTop"                        ' Align the top edge of the view with the vertical center of the base
Const NLCenterBottom$ = "CenterBottom"                  ' Align the bottom edge of the view with the vertical center of the base
Const NLCenterLeft$ = "CenterLeft"                      ' Align the left edge of the view with the horizontal center of the base
Const NLCenterRight$ = "CenterRight"                    ' Align the right edge of the view with the horizontal center of the base
Const NLBelow$ = "Below"                                ' Align the top edge of the view with the bottom edge of the base
Const NLAbove$ = "Above"                                ' Align the bottom edge of the view with the top edge of the base
Const NLLeftOf$ = "LeftOf"                              ' Align the right edge of the view with the left edge of the base
Const NLRightOf$ = "RightOf"                            ' Align the left edge of the view with the right edge of the base
Const NLCenterVertical$ = "CenterVertical"              ' Vertically center the view inside the base's frame
Const NLCenterHorizontal$ = "CenterHorizontal"          ' Horizontally center the view inside the base's frame

Const NLGravityTop%=1
Const NLGravityBottom%=2
Const NLGravityLeft%=4
Const NLGravityRight%=8
Const NLGravityHorizontalCenter%=16
Const NLGravityVerticalCenter%=32

Type NLayoutView Extends NView Abstract
	Field _layoutQueued:Int = True
	
	Method PerformLayout()
		_layoutQueued = True
	End Method
	
	Method _performLayout()
		_layoutQueued = False
	End Method
	
	Method ViewForPoint:NView(point:NPoint)
		If _layoutQueued Then _performLayout()
		Return Super.ViewForPoint(point)
	End Method
	
	Method DrawSubviews()
		If _layoutQueued Then _performLayout()
		Super.DrawSubviews()
	End Method
	
	Method SetFrame(frame:NRect)
		Super.SetFrame(frame)
		PerformLayout()
	End Method
	
	Method SetBounds(bounds:NRect)
		Super.SetBounds(bounds)
		PerformLayout()
	End Method
End Type

Type NRelativeLayout Extends NLayoutView
	Field _relations:TMap = New TMap
	
	Method InitWithFrame:NRelativeLayout(frame:NRect)
		Super.InitWithFrame(frame)
		Return Self
	End Method
	
	Method _performLayout()
		Local viewframe:NRect
		For Local view:NView = EachIn _subviews
			
			Local rules:TList = TList(_relations.ValueForKey(view))
			If Not rules Then Continue
			
			viewframe = view.Frame(viewframe)
			
			Local leftSet%, rightSet%, topSet%, bottomSet%
			leftSet = 0
			rightSet = 0
			topSet = 0
			bottomSet = 0
			
			For Local rule:NRelativeLayoutRule = EachIn rules
				Local param:String = rule.param
				Local base:NView = rule.base
				Local baseframe:NRect
				If base = Self Then
					baseframe = base.Bounds(_temp_rect)
					baseframe.origin.Set(0, 0)
				Else
					baseframe = base.Frame(_temp_rect)
				EndIf
				Local margin:Int = rule.margin
				
				Select param
					Case NLAlignTop
						If bottomSet Then
							Local bottom# = viewframe.origin.y+viewframe.size.height
							viewframe.origin.y = baseframe.origin.y + margin
							viewframe.size.height = bottom-viewframe.origin.y
						Else
							viewframe.origin.y = baseframe.origin.y + margin
						EndIf
						topSet = True
						
					Case NLAlignBottom
						If topSet Then
							viewframe.size.height = (baseframe.origin.y + baseframe.size.height) - viewframe.origin.y - margin
						Else
							viewframe.origin.y = (baseframe.origin.y + baseframe.size.height) - viewframe.size.height - margin
						Endif
						bottomSet = True
					
					Case NLAlignLeft
						If rightSet Then
							Local right# = viewframe.origin.x+viewframe.size.width
							viewframe.origin.x = baseframe.origin.x + margin
							viewframe.size.width = right-viewframe.origin.x
						Else
							viewframe.origin.x = baseframe.origin.x + margin
						EndIf
						leftSet = True
					
					Case NLAlignRight
						If leftSet Then
							viewframe.size.width = (baseframe.origin.x + baseframe.size.width) - viewframe.origin.x - margin
						Else
							viewframe.origin.x = (baseframe.origin.x + baseframe.size.width) - viewframe.size.width - margin
						Endif
						rightSet = True
					
					Case NLFillHorizontal
						viewframe.size.width = baseframe.size.width - margin*2
						viewframe.origin.x = baseframe.origin.x + margin
						leftSet = True
						rightSet = True
					
					Case NLFillVertical
						viewframe.size.height = baseframe.size.height - margin*2
						viewframe.origin.y = baseframe.origin.y + margin
						topSet = True
						bottomSet = True
					
					Case NLCenterVertical
						If Not (topSet Or bottomSet) Then
							viewframe.origin.y = baseframe.origin.y + (baseframe.size.height - viewframe.size.height) * .5 + margin
							topSet = True
							bottomSet = True
						EndIf
					
					Case NLCenterHorizontal
						If Not (rightSet Or leftSet) Then
							viewframe.origin.x = baseframe.origin.x + (baseframe.size.width - viewframe.size.width) * .5 + margin
							leftSet = True
							rightSet = True
						EndIf
					
					Case NLAbove
						If topSet Then
							viewframe.size.height = viewframe.origin.y - baseframe.origin.y - margin
						Else
							viewframe.origin.y = baseframe.origin.y - viewframe.size.height - margin
						EndIf
						bottomSet = True
					
					Case NLBelow
						If bottomSet Then
							Local bottom# = viewframe.origin.y + viewframe.size.height
							viewframe.origin.y = baseframe.origin.y + baseframe.size.height + margin
							viewframe.size.height = bottom - viewframe.origin.y
						Else
							viewframe.origin.y = baseframe.origin.y + baseframe.size.height + margin
						EndIf
						topSet = True
					
					Case NLLeftOf
						If topSet Then
							viewframe.size.width = viewframe.origin.x - baseframe.origin.x - margin
						Else
							viewframe.origin.x = baseframe.origin.x - viewframe.size.width - margin
						EndIf
						rightSet = True

					Case NLRightOf
						If rightSet Then
							Local right# = viewframe.origin.x + viewframe.size.width
							viewframe.origin.x = baseframe.origin.x + baseframe.size.width + margin
							viewframe.size.width = right - viewframe.origin.x
						Else
							viewframe.origin.x = baseframe.origin.x + baseframe.size.width + margin
						EndIf
						leftSet = True
					
					Case NLCenterTop
						If bottomSet Then
							Local bottom# = viewframe.origin.y+viewframe.size.height
							viewframe.origin.y = baseframe.origin.y + baseframe.size.width*.5 + margin
							viewframe.size.height = bottom-viewframe.origin.y
						Else
							viewframe.origin.y = baseframe.origin.y + baseframe.size.width*.5 + margin
						EndIf
						topSet = True

					Case NLCenterBottom
						If topSet Then
							viewframe.size.height = (baseframe.origin.y + baseframe.size.height*.5) - viewframe.origin.y - margin
						Else
							viewframe.origin.y = (baseframe.origin.y + baseframe.size.height*.5) - viewframe.size.height - margin
						Endif
						bottomSet = True

					Case NLCenterLeft
						If rightSet Then
							Local right# = viewframe.origin.x+viewframe.size.width
							viewframe.origin.x = baseframe.origin.x + baseframe.size.width*.5 + margin
							viewframe.size.width = right-viewframe.origin.x
						Else
							viewframe.origin.x = baseframe.origin.x + baseframe.size.width*.5 + margin
						EndIf
						leftSet = True

					Case NLCenterRight
						If leftSet Then
							viewframe.size.width = (baseframe.origin.x + baseframe.size.width*.5) - viewframe.origin.x - margin
						Else
							viewframe.origin.x = (baseframe.origin.x + baseframe.size.width*.5) - viewframe.size.width - margin
						Endif
						rightSet = True
				End Select
				
			Next
			
			If Not view.Frame(_temp_rect).Equals(viewframe) Then
				view.SetFrame(viewframe)
			EndIf
			
		Next
		
		Super._performLayout()
	End Method
	
	Method SetLayoutParam(param:String, forSubview:NView, base:NView=Null, margin:Int=0)
		If base = Null Then
			base = Self
		EndIf
		
		Assert forSubview <> base Else "Views cannot use themselves as bases"
		Assert base = Self Or _subviews.Contains(base) Else "Base view must be the layout view or one of its subviews"
		Assert _subviews.Contains(forSubview) Else "View to assign the layout parameter to must be a subview of the layout view"
		
		Local rule:NRelativeLayoutRule = New NRelativeLayoutRule
		rule.param = param
		rule.base = base
		rule.margin = margin
		rule.owner = Self
		Local rules:TList = TList(_relations.ValueForKey(forSubview))
		If Not rules Then
			rules = New TList
			_relations.Insert(forSubview, rules)
		EndIf
		rules.AddLast(rule)
		If base <> Self Then
			base.AddEventHandler(NFrameChangedEvent, rule)
		EndIf
		PerformLayout()
	End Method
	
	Method SubviewWasRemoved(exsubview:NView)
		If _relations.Contains(exsubview) Then
			_relations.Remove(exsubview)
		EndIf
		For Local rules:TList = EachIn _relations.Values()
			For Local rule:NRelativeLayoutRule = EachIn rules.ToArray()
				If rule.base = exsubview Then rules.Remove(rule)
				exsubview.RemoveEventHandler(NFrameChangedEvent, rule)
			Next
		Next
		PerformLayout()
		Super.SubviewWasRemoved(exsubview)
	End Method
End Type

Const NLinearLayoutVertical:Int = 0
Const NLinearLayoutHorizontal:Int = 1

Private

Type NLinearLayoutRule Extends NLayoutRule
	Field gravity:Int
	Field fill_width%
	Field fill_height%
End Type

Public

Type NLinearLayout Extends NLayoutView
	Field _orientation:Int = NLinearLayoutVertical
	Field _rules:TMap
	
	Method _performLayout()
		
		
		Super._performLayout()
	End Method
	
	Method _performLayout_H()
	End Method
	
	Method _performLayout_V()
	End Method
End Type
