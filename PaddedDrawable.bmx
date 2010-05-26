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

Type NPaddedDrawable Extends NDrawable
	Field _drawable:NDrawable
	Field _pad_left#, _pad_right#, _pad_top#, _pad_bottom#
	
	Method InitWithDrawable:NPaddedDrawable(drawable:NDrawable, left#=0, right#=0, top#=0, bottom#=0)
		_pad_left = Max(0, left)
		_pad_right = Max(0, right)
		_pad_top = Max(0, top)
		_pad_bottom = Max(0, bottom)
		_drawable = drawable
		Return Self
	End Method
	
	Method DrawRect(x#, y#, w#, h#, state%=0)
		w :- _pad_left+_pad_right
		If w < 0 Then Return
		h :- _pad_top+_pad_bottom
		If h < 0 Then Return
		x :+ _pad_left
		y :+ _pad_top
		_drawable.DrawRect(x, y, w, h, state)
	End Method
End Type
