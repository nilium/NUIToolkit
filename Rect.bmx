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

Private
Const FLOAT_DELTA# = 1.4e-45#
Public

Type NSize Final
	Field width#=0
	Field height#=0
	
	Method Set(width#, height#)
		Self.width = width
		Self.height = height
	End Method
	
	Method Get(width#Var, height#Var)
		width = Self.width
		height = Self.height
	End Method
	
	Method Clone:NSize()
		Return New NSize.CopyValues(Self)
	End Method
	
	Method CopyValues:NSize(other:NSize)
		Assert other Else "'other' argument cannot be Null"
		MemCopy(Self, other, 8)
		Return Self
	End Method
	
	Method ToString:String()
		Return width+", "+height
	End Method
	
	Method Equals:Int(other:NSize)
		Return Abs(other.width-width)<FLOAT_DELTA And Abs(other.height-height)<FLOAT_DELTA
	End Method
End Type

Type NPoint Final
	Field x#=0
	Field y#=0
	
	Method Set(x#, y#)
		Self.x = x
		Self.y = y
	End Method
	
	Method Get(x#Var, y#Var)
		x = Self.x
		y = Self.y
	End Method
	
	Method Clone:NPoint()
		Return New NPoint.CopyValues(Self)
	End Method
	
	Method CopyValues:NPoint(other:NPoint)
		Assert other Else "'other' argument cannot be Null"
		MemCopy(Self, other, 8)
		Return Self
	End Method
	
	Method ToString:String()
		Return x+", "+y
	End Method
	
	Method Equals:Int(other:NPoint)
		Return Abs(other.x-x)<FLOAT_DELTA And Abs(other.y-y)<FLOAT_DELTA
	End Method
End Type

Type NRect Final
	Field origin:NPoint=New NPoint
	Field size:NSize=New NSize
	
	Method Set(x#, y#, width#, height#)
		origin.Set(x, y)
		size.Set(width, height)
	End Method
	
	Method Get(x#Var, y#Var, width#Var, height#Var)
		origin.Get(x, y)
		size.Get(width, height)
	End Method
	
	Method CopyValues:NRect(other:NRect)
		Assert other Else "'other' argument cannot be Null"
		origin = origin.CopyValues(other.origin)
		size = size.CopyValues(other.size)
		Return Self
	End Method
	
	Method Equals:Int(other:NRect)
		Return other.origin.Equals(origin) And other.size.Equals(size)
	End Method
	
	Method Intersects:Int(with:NRect)
		Assert with Else "'with' argument cannot be Null"
		
		Return Not( with.origin.x + with.size.width < origin.x ..
		            Or with.origin.y + with.size.height < origin.y ..
		            Or origin.x + size.width < with.origin.x ..
		            Or origin.y + size.height < with.origin.y )
	End Method
	
	Method Intersection:NRect(with:NRect, out:NRect=Null)
		If Not out Then
			out = New NRect
		EndIf
		
		If Not with Then
			Return out
		EndIf
		
		Local tx#,ty#
		Local rx#,ry#,rwidth#,rheight#
		rx = with.origin.x
		ry = with.origin.y
		rwidth = with.size.width
		rheight = with.size.height
		
		If rx < origin.x Then
			rwidth = Max(0, rwidth - (origin.x - rx))
			rx = origin.x
		EndIf
		
		If ry < origin.y Then
			rheight = Max(0, rheight - (origin.y - ry))
			ry = origin.y
		EndIf
		
		tx = origin.x+size.width
		ty = rx+rwidth
		If tx < ty Then
			rwidth = Max(0, rwidth - (ty - tx))
		EndIf
		
		tx = origin.y+size.height
		ty = ry+rheight
		If tx < ty Then
			rheight = Max(0, rheight - (ty - tx))
		EndIf
		
		out.origin.x = rx
		out.origin.y = ry
		out.size.width = rwidth
		out.size.height = rheight
		
		Return out
	End Method
	
	Method ContainsPoint:Int(point:NPoint)
		Assert point Else "'point' argument cannot be Null"
		Return Contains(point.x, point.y)
	End Method
	
	Method Contains:Int(x#, y#)
		Return origin.x <= x And origin.y <= y And x <= origin.x+size.width And y <= origin.y+size.height
	End Method
	
	Method ContainsRect:Int(rect:NRect)
		Return Contains(rect.origin.x, rect.origin.y) And Contains(rect.origin.x + rect.size.width, rect.origin.y) And Contains(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height) And Contains(rect.origin.x, rect.origin.y + rect.size.height)
	End Method
	
	Method Clone:NRect() NoDebug
		Return New NRect.CopyValues(Self)
	End Method
	
	Method ToString:String()
		Return "("+origin.ToString()+"), ("+size.ToString()+")"
	End Method
End Type

' Convenience functions
Function MakeRect:NRect(x#,y#,w#,h#)
	Local rect:NRect = New NRect
	rect.origin.x = x
	rect.origin.y = y
	rect.size.width = w
	rect.size.height = h
	Return rect
End Function

Function MakePoint:NPoint(x#, y#)
	Local point:NPoint = New NPoint
	point.x = x
	point.y = y
	Return point
End Function

Function MakeSize:NSize(w#, h#)
	Local size:NSize = New NSize
	size.width = w
	size.height = h
	Return size
End Function
