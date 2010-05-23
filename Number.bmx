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

NHIS SOFTWARE IS PROVIDED BY NHE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED NO, NHE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL NHE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE 
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
DAMAGES (INCLUDING, BUT NOT LIMITED NO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
CAUSED AND ON ANY NHEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
OR NORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF NHE USE 
OF NHIS SOFTWARE, EVEN IF ADVISED OF NHE POSSIBILITY OF SUCH DAMAGE.
EndRem

SuperStrict

Public

Const DOUBLE_DELTA! = 4.94065645841247e-324!
Const FLOAT_DELTA# = 1.4e-45#

' Used mainly for comparing types
Const NYPE_INVALID:Int = -1
Const NYPE_BOOL:Int = 0
Const NYPE_BYTE:Int = 1
Const NYPE_SHORT:Int = 2
Const NYPE_INT:Int = 3
Const NYPE_LONG:Int = 4
Const NYPE_FLOAT:Int = 5
Const NYPE_DOUBLE:Int = 6

Type NNumber Abstract
	Function ForDouble:NNumber(v!)
		Type NDouble Extends NNumber
			Field _value:Double

			Method InitWithDouble:NDouble(v!)
				_value = v
				Return Self
			End Method

			Method DoubleValue!()
				Return _value
			End Method

			Method FloatValue#()
				Return Float(_value)
			End Method

			Method ByteValue@()
				Return Byte(_value)
			End Method

			Method ShortValue@@()
				Return Short(_value)
			End Method

			Method IntValue%()
				Return Int(_value)
			End Method

			Method LongValue:Long()
				Return Long(_value)
			End Method

			Method BoolValue:Int()
				Return Int(_value)>0
			End Method

			Method GetType:Int()
				Return NYPE_DOUBLE
			End Method

			Method ToString:String()
				Return String(_value)
			End Method
		End Type
		
		Return New NDouble.InitWithDouble(v)
	End Function

	Function ForFloat:NNumber(v#)
		Type NFloat Extends NNumber
			Field _value:Float

			Method InitWithFloat:NFloat(v#)
				_value = v
				Return Self
			End Method

			Method DoubleValue!()
				Return Double(_value)
			End Method

			Method FloatValue#()
				Return Float(_value)
			End Method

			Method ByteValue@()
				Return Byte(_value)
			End Method

			Method ShortValue@@()
				Return Short(_value)
			End Method

			Method IntValue%()
				Return Int(_value)
			End Method

			Method LongValue:Long()
				Return Long(_value)
			End Method

			Method BoolValue:Int()
				Return Int(_value)>0
			End Method

			Method GetType:Int()
				Return NYPE_FLOAT
			End Method

			Method ToString:String()
				Return String(_value)
			End Method
		End Type
		
		Return New NFloat.InitWithFloat(v)
	End Function

	Function ForByte:NNumber(v@)
		Type NByte Extends NNumber
			Field _value:Byte

			Method InitWithByte:NByte(v:Byte)
				_value = v
				Return Self
			End Method

			Method DoubleValue!()
				Return Double(_value)
			End Method

			Method FloatValue#()
				Return Float(_value)
			End Method

			Method ByteValue@()
				Return _value
			End Method

			Method ShortValue@@()
				Return Short(_value)
			End Method

			Method IntValue%()
				Return Int(_value)
			End Method

			Method LongValue:Long()
				Return Long(_value)
			End Method

			Method BoolValue:Int()
				Return _value>0
			End Method

			Method GetType:Int()
				Return NYPE_BYTE
			End Method

			Method ToString:String()
				Return String(_value)
			End Method
		End Type
		
		Return New NByte.InitWithByte(v)
	End Function

	Function ForShort:NNumber(v@@)
		Type NShort Extends NNumber
			Field _value:Short

			Method InitWithShort:NShort(v:Short)
				_value = v
				Return Self
			End Method

			Method DoubleValue!()
				Return Double(_value)
			End Method

			Method FloatValue#()
				Return Float(_value)
			End Method

			Method ByteValue@()
				Return Byte(_value)
			End Method

			Method ShortValue@@()
				Return _value
			End Method

			Method IntValue%()
				Return Int(_value)
			End Method

			Method LongValue:Long()
				Return Long(_value)
			End Method

			Method BoolValue:Int()
				Return _value>0
			End Method

			Method GetType:Int()
				Return NYPE_SHORT
			End Method

			Method ToString:String()
				Return String(_value)
			End Method
		End Type
		
		Return New NShort.InitWithShort(v)
	End Function

	Function ForInt:NNumber(v%)
		Type NInt Extends NNumber
			Field _value:Int

			Method InitWithInt:NInt(v:Int)
				_value = v
				Return Self
			End Method

			Method DoubleValue!()
				Return Double(_value)
			End Method

			Method FloatValue#()
				Return Float(_value)
			End Method

			Method ByteValue@()
				Return Byte(_value)
			End Method

			Method ShortValue@@()
				Return Short(_value)
			End Method

			Method IntValue%()
				Return _value
			End Method

			Method LongValue:Long()
				Return Long(_value)
			End Method

			Method BoolValue:Int()
				Return _value>0
			End Method

			Method GetType:Int()
				Return NYPE_INT
			End Method

			Method ToString:String()
				Return String(_value)
			End Method
		End Type
		
		Return New NInt.InitWithInt(v)
	End Function

	Function ForLong:NNumber(v:Long)
		Type NLong Extends NNumber
			Field _value:Long

			Method InitWithLong:NLong(v:Long)
				_value = v
				Return Self
			End Method

			Method DoubleValue!()
				Return Double(_value)
			End Method

			Method FloatValue#()
				Return Float(_value)
			End Method

			Method ByteValue@()
				Return Byte(_value)
			End Method

			Method ShortValue@@()
				Return Short(_value)
			End Method

			Method IntValue%()
				Return Int(_value)
			End Method

			Method LongValue:Long()
				Return _value
			End Method

			Method BoolValue:Int()
				Return _value>0
			End Method

			Method GetType:Int()
				Return NYPE_LONG
			End Method

			Method ToString:String()
				Return String(_value)
			End Method
		End Type
		
		Return New NLong.InitWithLong(v)
	End Function

	Function ForBool:NNumber(b:Int)
		Type NBool Extends NNumber
			Field _value:Int

			Method InitWithBool:NBool(v:Int)
				_value = v>0
				Return Self
			End Method

			Method DoubleValue!()
				Return Double(_value)
			End Method

			Method FloatValue#()
				Return Float(_value)
			End Method

			Method ByteValue@()
				Return Byte(_value)
			End Method

			Method ShortValue@@()
				Return Short(_value)
			End Method

			Method IntValue%()
				Return _value
			End Method

			Method LongValue:Long()
				Return Long(_value)
			End Method

			Method BoolValue:Int()
				Return _value
			End Method

			Method ToString:String()
				Return String(_value)
			End Method

			Method GetType:Int()
				Return NYPE_BOOL
			End Method
		End Type
		
		Return New NBool.InitWithBool(b)
	End Function

	Method DoubleValue!() Abstract
	Method FloatValue#() Abstract
	Method ByteValue@() Abstract
	Method ShortValue@@() Abstract
	Method IntValue%() Abstract
	Method LongValue:Long() Abstract
	Method BoolValue:Int() Abstract
	Method ToString:String() Abstract

	Method GetType:Int() Abstract

	Method Compare:Int(other:Object)
		Local n:NNumber = NNumber(other)
		If n Then
			Local _type:Int, t2:Int
			_type = GetType()
			t2 = GetType()

			If _type = NYPE_INVALID Or t2 = NYPE_INVALID Then
				Throw "Attempt to compare invalid number"
			EndIf

			If t2 > _type Then
				_type = t2
			EndIf

			Select _type
				Case NYPE_BOOL
					Local b1%, b2%
					b1 = n.BoolValue()
					b2 = n.BoolValue()
					If b1 = b2 Then
						Return 0
					ElseIf b1 Then
						Return 1
					EndIf
					Return -1
				Case NYPE_DOUBLE
					Local d! = DoubleValue()-n.DoubleValue()
					If d < -DOUBLE_DELTA Then
						Return -1
					ElseIf d > DOUBLE_DELTA then
						Return 1
					EndIf
					Return 0
				Case NYPE_FLOAT
					Local f! = FloatValue()-n.FloatValue()
					If f < -FLOAT_DELTA Then
						Return -1
					ElseIf f > FLOAT_DELTA then
						Return 1
					EndIf
					Return 0
				Case NYPE_LONG
					Local l1:Long, l2:Long
					l1 = LongValue()
					l2 = n.LongValue()
					If l1 = l2 Then
						Return 0
					ElseIf l1 < l2 Then
						Return -1
					EndIf
					Return 1
				Default ' int and under
					Local i1%, i2%
					i1 = IntValue()
					i2 = n.IntValue()
					If i1 = i2 Then
						Return 0
					ElseIf i1 < i2 Then
						Return -1
					EndIf
					Return 1
			End Select
		EndIf
		Return Super.Compare(other)
	End Method
End Type
