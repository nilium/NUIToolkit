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

Type Animation
	?Threaded
	Global AnimationsLock:TMutex = TMutex.Create()
	?
	Global Animations:TList = New TList
	Global AnimationTimer:TTimer = TTimer.Create(60, Null)
	
	Field o:Object		' Object being animated, used to keep pointer to object in scope during animation
	Field f:TField
	Field duration:Double
	Field stime:Int
	Field start:Double
	Field finish:Double
	Field fn:Double(s:Double,f:Double,t:Double)
	
	Method Update(ctime%=-1)
		If ctime=-1 Then ctime = Millisecs()
		Local time! = (ctime-stime)/duration
		If time >= 1! Then
			?Threaded
			AnimationsLock.Lock
			?
			Animations.Remove(Self)
			?Threaded
			AnimationsLock.Unlock
			?
			If Not fn Then f.SetDouble(o, finish)
		Else
			Local nv!
			If fn Then
				nv = fn(start, finish, Min(time,1))
			Else
				nv = start+((finish-start)*Min(time,1))
			EndIf
			f.SetDouble(o, nv)
		EndIf
	End Method
	
	Function UpdateAnimations()
		?Threaded
		AnimationsLock.Lock
		?
		If Not Animations.IsEmpty() Then
			Local ctime% = Millisecs()
			Local anims:TList = Animations.Copy()
			For Local a:Animation = EachIn Animations
				a.Update(ctime)
			Next
		EndIf
		?Threaded
		AnimationsLock.Unlock
		?
	End Function
	
	Function tick_UpdateAnimations:Object(id%, data:Object, ctx:Object)
		Local event:TEvent = TEvent(data)
		If event And event.id = EVENT_TIMERTICK And event.source = AnimationTimer Then
			UpdateAnimations()
			Return Null ' event handled
		EndIf
		
		Return data
	End Function
	
	Function EnableAutoUpdate()
		AddHook(EmitEventHook, Animation.tick_UpdateAnimations, Null, 1000)
	End Function
	
	Function DisableAutoUpdate()
		RemoveHook(EmitEventHook, Animation.tick_UpdateAnimations, Null)
	End Function
End Type
Animation.EnableAutoUpdate()

Function Animate(obj:Object, value$, newvalue!, duration!=5000, fn:Double(start:Double, finish:Double, time:Double)=Null)
	Local a:Animation
	
	?Threaded
	Animation.AnimationsLock.Lock
	?
	
	If Not Animation.Animations.IsEmpty() Then
		For a = EachIn Animation.Animations
			If a.o = obj And a.f.Name().ToLower() = value.ToLower() Then
				a.start = a.f.GetDouble(obj)
				a.finish = newvalue
				a.duration = duration
				a.stime = Millisecs()
				?Threaded
				Animation.AnimationsLock.Unlock
				?
				Return
			EndIf
		Next
	EndIf
	
	a = New Animation
	a.o = obj
	a.f = TTypeID.ForObject(obj).FindField(value)
	a.duration = duration
	a.stime = Millisecs()
	a.start = a.f.GetDouble(obj)
	a.finish = newvalue
	a.fn = fn
	Animation.Animations.AddLast(a)
	
	?Threaded
	Animation.AnimationsLock.Unlock
	?
End Function
