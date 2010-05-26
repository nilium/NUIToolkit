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

Import "Drawable.bmx"

Const NImageNoScaling%=0			' Causes the image to be drawn without scaling and will be clipped to the drawing rectangle
Const NImageFillHorizontal%=1		' Causes the image to be drawn such that it will be stretched to fill the entire width of the drawing rectangle
Const NImageFillVertical%=2			' Causes the image to be drawn such that it will be stretched to fill the entire height of the drawing rectangle
Const NImageFill%=3					' Causes the image to be drawn such that it will be stretched to fill the drawing rectangle
Const NImageFillAspect%=4			' Causes the image to be scaled such that it will be stretched to fill the drawing rectangle while maintaining its aspect ratio.

Type NImageDrawable Extends NDrawable
	Field _img:TImage
	Field _width%, _height%
	
	Field _scale%=NImageFill
	
	Method DrawRect(x#, y#, width#, height#, state%=0)
		Select _scale
		Case NImageFillAspect
			Local w# = _width
			Local h# = _height
			If width < height Then
				w = width
				h = width * (Float(_height)/Float(_width))
				
				If height < h Then
					h = height
					w = height * (Float(_width)/Float(_height))
				EndIf
			Else
				h = height
				w = height * (Float(_width)/Float(_height))
				
				If width < w Then
					w = width
					h = width * (Float(_height)/Float(_width))
				EndIf
			EndIf
			
			DrawImageRect(_img, x, y, w, h)
			
			Return
		
		Case NImageFill
			DrawImageRect(_img, x, y, width, height, state)
			Return
			
		Case NImageFillHorizontal
			height = Min(height, _height)
			
		Case NImageFillVertical
			width = Min(width, _width)
			
		Case NImageNoScaling
			height = Min(height, _height)
			width = Min(width, _width)
		End Select
		
		DrawSubImageRect(_img, x, y, width, height, 0, 0, width, height, 0, 0, state)
	End Method
	
	Method InitWithImage:NImageDrawable(img:TImage)
		_img = img
		_width = ImageWidth(img)
		_height = ImageHeight(img)
		Return Self
	End Method
	
	Method SetScaling(mode%)
		Assert NImageNoScaling <= mode <= NImageFillAspect
		_scale = mode
	End Method
End Type
