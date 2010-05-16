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

Type NNinePatch Extends NDrawable
	Field _img:TImage
	Field _left_border#, _right_border#, _top_border#, _bottom_border#
	Field _width%, _height%
	Field _left_scale#=1.0, _right_scale#=1.0, _top_scale#=1.0, _bottom_scale#=1.0
	
	Method DrawRect(x#, y#, width#, height#, state%=0)
		Const NINEPATCH_MINIMUM#=0.5#
		Local lb%, rb%, tb%, bb%
		lb = (NINEPATCH_MINIMUM <= _left_border)
		rb = (NINEPATCH_MINIMUM <= _right_border)
		tb = (NINEPATCH_MINIMUM <= _top_border)
		bb = (NINEPATCH_MINIMUM <= _bottom_border)
		
		Local lw# = lb*_left_border
		Local rw# = rb*_right_border
		Local th# = tb*_top_border
		Local bh# = bb*_bottom_border
		
		Local dw# = width-lw*_left_scale-rw*_right_scale
		Local dh# = height-th*_top_scale-bh*_bottom_scale
		Local sw# = _width-lw-rw
		Local sh# = _height-th-bh
		
		Local handlex#, handley#
		GetHandle(handlex,handley)
		
		If tb Then
			If lb Then
				DrawSubImageRect(_img, x, y, lw*_left_scale, th*_top_scale, 0, 0, lw, th, 0, 0, state)
			EndIf
			DrawSubImageRect(_img, x+lw*_left_scale, y, dw, th*_top_scale, lw, 0, sw, th, 0, 0, state )
			If rb Then
				DrawSubImageRect(_img, x+dw+lw*_left_scale, y, rw*_right_scale, th*_top_scale, sw+lw, 0, rw, th, 0, 0, state)
			EndIf
		EndIf
		
		If lb Then
			DrawSubImageRect(_img, x, y+th*_top_scale, lw*_left_scale, dh, 0, th, lw, sh, 0, 0, state)
		EndIf
		DrawSubImageRect(_img, x+lw*_left_scale, y+th*_top_scale, dw, dh, lw, th, sw, sh, 0, 0, state )
		If rb Then
			DrawSubImageRect(_img, x+dw+lw*_left_scale, y+th*_top_scale, rw*_right_scale, dh, sw+lw, th, rw, sh, 0, 0, state)
		EndIf
		
		If tb Then
			If lb Then
				DrawSubImageRect(_img, x, y+dh+th*_top_scale, lw*_left_scale, bh*_bottom_scale, 0, sh+th, lw, bh, 0, 0, state)
			EndIf
			DrawSubImageRect(_img, x+lw*_left_scale, y+dh+th*_top_scale, dw, bh*_bottom_scale, lw, sh+th, sw, bh, 0, 0, state )
			If rb Then
				DrawSubImageRect(_img, x+dw+lw*_left_scale, y+dh+th*_top_scale, rw*_right_scale, bh*_bottom_scale, sw+lw, sh+th, rw, bh, 0, 0, state)
			EndIf
		EndIf
	End Method
	
	Method InitWithImage:NNinePatch(img:TImage, left_border#=8, right_border#=8, top_border#=8, bottom_border#=8, border_scale#=1.0)
		_img = img
		_width = ImageWidth(img)
		_height = ImageHeight(img)
		_left_border = left_border
		_right_border = right_border
		_top_border = top_border
		_bottom_border = bottom_border
		SetAllScales(border_scale)
		Return Self
	End Method
	
	Method SetAllScales(scale#)
		_top_scale=scale
		_left_scale=scale
		_bottom_scale=scale
		_right_scale=scale
	End Method
	
	Method SetScales(left#,right#,top#,bottom#)
		_left_scale=left
		_right_scale=right
		_top_scale=top
		_bottom_scale=bottom
	End Method
End Type
