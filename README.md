## About

NUI Toolkit, NUIT for short (pronounced [nut] as in 'newt'),
is my graphical user interface module-of-sorts written for
BlitzMax.  Many moons ago (about 5 years' worth) I wrote a,
GUI called CowerGUI, and it was a stinking heap of garbage.
I should know, I wrote it and recently updated it so it would
actually run again - but this isn't CowerGUI, this is atonement
for that abomination against his Noodliness.

NUIT's aim is to make fairly complex operations involving GUIs
fairly painless while looking #@$%ing gorgeous.  The latter
goal is easier to achieve than the former, thankfully.  Its
design, in terms of structure and how you work with it, is
something of a mish-mash between the ideas of Cocoa and Android
OS.  A lot of the terms and ideas are borrowed from Cocoa
because, as far as I'm concerned, they nailed that.  The idea
for how layout and such works is borrowed somewhat from Android,
although it's much simpler (because Max2D in BlitzMax is
unfortunately very simple itself and doesn't allow for a lot of
things that Android would).

## Using NUIT

Fairly simple: import ngui.bmx, like so: `Import "ngui.bmx"`

After that, you can use NGUI however you want.  This typically
involves instantiating an instance of NGUI and then adding
windows to it and views to those windows.

There is no documentation at present, since various design flaws
are still being discovered and fixed/swept under the rug.  As a
result, the best thing you can do is get familiar with the methods
in GUI.bmx for NView, NWindow, and NGUI.  All other views are
derived from one of those first two types, so there's not too much
to learn.

## License

NUI Toolkit is licensed under a two-clause BSD license:

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
