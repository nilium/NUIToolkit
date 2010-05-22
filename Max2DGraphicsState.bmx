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

Import "GraphicsContext.bmx"

Type NMax2DGraphicsState Extends NGraphicsState
	Field clip:NRect = New NRect
	Field origin:NPoint = New NPoint
	Field scale:NSize = New NSize
	Field rotation:Float
	Field handle:NPoint = New NPoint
	Field font:TImageFont
	Field blend:Int
	Field red%, green%, blue%, alpha#
	Field clear_red%, clear_green%, clear_blue%
	
	Method SetClipping(x#, y#, w#, h#)
		clip.Set(x, y, w, h)
		SetViewport(x, y, w, h)
	End Method
	
	Method MoveToPoint(x#, y#)
		origin.x = x
		origin.y = y
		SetOrigin(origin.x, origin.y)
	End Method
	
	Method Translate(x#, y#)
		origin.x :+ x
		origin.y :+ y
		SetOrigin(origin.x, origin.y)
	End Method
	
	Method Rotate(a#)
		rotation :+ a
		SetRotation(rotation)
	End Method
	
	Method SetClearColor(r#, g#, b#)
		clear_red = r
		clear_green = g
		clear_blue = b
		SetClsColor(r, g, b)
	End Method
	
	Method SetDrawingAlpha(a#)
		alpha = a
		SetAlpha(a)
	End Method
	
	Method SetDrawingColor(r#, g#, b#)
		red = r
		green = g
		blue = b
		SetColor(r,g,b)
	End Method
	
	Method SetBlendingMode(b%)
		blend = b
		SetBlend(b)
	End Method
	
	Method SetFont(font:NFont)
		Assert NMax2DFont(font) Else "Invalid font type, must use NMax2DFonts when using Max2D"
		SetImageFont(NMax2DFont(font)._imageFont)
	End Method
	
	Method Acquire()
		Local vx%, vy%, vw%, vh%
		GetViewport(vx, vy, vw, vh)
		clip.Set(vx, vy, vw, vh)
		GetOrigin(origin.x, origin.y)
		GetHandle(handle.x, handle.y)
		GetScale(scale.width, scale.height)
		rotation = GetRotation()
		font = GetImageFont()
		blend = GetBlend()
		GetColor(red, green, blue)
		alpha = GetAlpha()
		GetClsColor(clear_red, clear_green, clear_blue)
	End Method
	
	Method Restore()
		SetViewport(clip.origin.x, clip.origin.y, clip.size.width, clip.size.height)
		SetOrigin(origin.x, origin.y)
		SetTransform(rotation, scale.width, scale.height)
		SetHandle(handle.x, handle.y)
		SetImageFont(font)
		SetBlend(blend)
		SetColor(red, green, blue)
		SetAlpha(alpha)
		SetClsColor(clear_red, clear_green, clear_blue)
	End Method
	
	Method Clone:NMax2DGraphicsState()
		Local state:NMax2DGraphicsState = New NMax2DGraphicsState
		state.clip.CopyValues(clip)
		state.origin.CopyValues(origin)
		state.scale.CopyValues(scale)
		state.rotation = rotation
		state.handle.CopyValues(handle)
		state.font = font
		state.red = red
		state.green = green
		state.blue = blue
		state.alpha = alpha
		state.clear_red = clear_red
		state.clear_green = clear_green
		state.clear_blue = clear_blue
		state.blend = blend
		Return state
	End Method
End Type

Global NMax2DGraphicsStateTypeID:TTypeID = TTypeID.ForName("NMax2DGraphicsState")
