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

Type NTiledDrawable Extends NDrawable
	
	Field _img:TImage
	Field _width#
	Field _height#
	
	Field _tile_horiz:Int = True
	Field _tile_vert:Int = True
	Field _xoff# = 0.0
	Field _yoff# = 0.0
	
	Method InitWithImage:NTiledDrawable(image:TImage)
		_img = image
		_width = ImageWidth(image)
		_height = ImageHeight(image)
		Return Self
	End Method
	
	Method DrawRect(x#, y#, w#, h#, state%=0)
		If _tile_vert And _tile_horiz Then
			Local xoff# = _xoff * _width
			Local yoff# = _yoff * _height
			Local xoffw# = Min(xoff, w)
			Local yoffh# = Min(yoff, h)
			
			Local ysteps# = h / _height - _xoff
			Local xsteps# = w / _width - _yoff
			
			Local xfits:Int = .02 < (_width-xoff)
			Local yfits:Int = .02 < (_height-yoff)
			
			If yfits Then
				For Local xiter:Int = 0 Until Int(xsteps)
					DrawSubImageRect(_img, x+xoff+xiter*_width, y, _width, yoffh, 0, _height-yoff, _width, yoffh, 0, 0, state)
				Next
			EndIf
			
			If xfits Then
				For Local yiter:Int = 0 Until Int(ysteps)
					DrawSubImageRect(_img, x, y+yoff+yiter*_height, xoffw, _height, _width-xoff, 0, xoffw, _height, 0, 0, state)
				Next
			EndIf
			
			If xfits And yfits Then
				DrawSubImageRect(_img, x, y, xoffw, yoffh, _width-xoff, _height-yoff, xoffw, yoffh, 0, 0, state)
			EndIf
			
			x :+ xoff
			y :+ yoff
			w :- xoff
			h :- yoff
			
			Local yfull% = Int(ysteps)
			Local xfull% = Int(xsteps)
			Local yseg# = h - yfull*_height
			Local xseg# = w - xfull*_width
			
			For Local xiter:Int = 0 Until xfull
				For Local yiter:Int = 0 Until yfull
					DrawImageRect(_img, x+xiter*_width, y+yiter*_height, _width, _height, state)
				Next
			Next
			
			xfits = .02 < xseg
			yfits = .02 < yseg
			
			If yfits Then
				For Local xiter:Int = 0 Until xfull
					DrawSubImageRect(_img, x+xiter*_width, y+yfull*_height, _width, yseg, 0, 0, _width, yseg, 0, 0, state)
				Next
				If .02 < yoffh Then
					DrawSubImageRect(_img, x-xoff, y+yfull*_height, xoffw, yseg, _width-xoff, 0, xoffw, yseg, 0, 0, state)
				EndIf
			EndIf
			
			If xfits Then
				For Local yiter:Int = 0 Until yfull
					DrawSubImageRect(_img, x+xfull*_width, y+yiter*_height, xseg, _height, 0, 0, xseg, _height, 0, 0, state)
				Next
				DrawSubImageRect(_img, x+xfull*_width, y-yoff, xseg, yoffh, 0, _height-yoff, xseg, yoffh, 0, 0, state)
			EndIf
			
			If xfits And yfits Then
				DrawSubImageRect(_img, x+xfull*_width, y+yfull*_height, xseg, yseg, 0, 0, xseg, yseg, 0, 0, state)
			EndIf
		ElseIf _tile_horiz Then
			Local xoff# = _xoff * _width
			Local xoffw# = Min(xoff, w)
			
			Local xsteps# = w / _width - _xoff
			
			If .02 < xoff Then
				DrawSubImageRect(_img, x, y, xoffw, h, _width-xoff, 0, xoffw, _height, 0, 0, state)
			EndIf
			
			x :+ xoff
			w :- xoff
			
			Local full% = Int(xsteps)
			Local seg# = w - full*_width
			
			For Local iter:Int = 0 Until full
				DrawImageRect(_img, x, y, _width, h, state)
				x :+ _width
			Next
			
			If .02 < seg Then
				DrawSubImageRect(_img, x, y, seg, h, 0, 0, seg, _height, 0, 0, state)
			EndIf
		ElseIf _tile_vert Then
			Local yoff# = _yoff * _height
			Local yoffh# = Min(yoff, h)
			
			Local ysteps# = h / _height - _yoff
			
			If .02 < yoff Then
				DrawSubImageRect(_img, x, y, w, yoffh, 0, _height-yoff, _width, yoffh, 0, 0, state)
			EndIf
			
			y :+ yoff
			h :- yoff
			
			Local full% = Int(ysteps)
			Local seg# = h - full*_height
			
			For Local iter:Int = 0 Until full
				DrawImageRect(_img, x, y, w, _height, state)
				y :+ _height
			Next
			
			If .02 < seg Then
				DrawSubImageRect(_img, x, y, w, seg, 0, 0, _width, seg, 0, 0, state)
			EndIf
		Else
			Super.DrawRect(x, y, w, h, state)
		EndIf
	End Method
	
	Method SetTiling(horizontal:Int, vertical:Int)
		_tile_horiz = 0<horizontal
		_tile_vert = 0<vertical
	End Method
	
	Method Tiling(horizontal:Int Var, vertical:Int Var)
		horizontal = _tile_horiz
		vertical = _tile_vert
	End Method
	
	Method SetOffset(xoffset#, yoffset#)
		_xoff = xoffset - Floor(xoffset)
		_yoff = yoffset - Floor(yoffset)
		Assert 0 <= _xoff
		Assert 0 <= _yoff
	End Method
	
	Method Offset(x#Var, y#Var)
		x = _xoff
		y = _yoff
	End Method
End Type
