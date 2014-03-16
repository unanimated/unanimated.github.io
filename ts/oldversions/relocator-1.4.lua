--[[	Instructions

 Position: 'Align X' means all selected \pos tags will have the same given X coordinate. Same with 'Align Y' for Y.
   useful for multiple signs on screen that need to be aligned horizontally/vertically or mocha signs that should move horizontally/vertically.
   'align with first' uses X or Y from the first line.
   
 Move: 'horizontal' means y2 will be the same as y1 so that the sign moves in a straight horizontal manner. Same principle for 'vertical.'
 Transmove: this is the real deal here. Main function: create \move from two lines with \pos.
	Duplicate your line and position the second one where you want the \move the end. Script will create \move from the two positions.
	Second line will be deleted by default; it's there just so you can comfortably set the final position.
	Extra function: to make this a lot more awesome, this can create transforms.
	Not only is the second line used for \move coordinates, but also for transforms. 
	Any tag on line 2 that's different from line 1 will be used to create a transform on line 1.
	So for a \move with transforms you can set the initial sign and then the final sign while everything is static.
	You can time line 2 to just the last frame. The script only uses timecodes from line 1. 
	Text from line 2 is also ignored (assumed to be same as line 1).
	You can time line 2 to start after line 1 and check 'keep both.' 
	That way line 1 transforms into line 2 and the sign stays like that for the duration of line 2.
	'Rotation acceleration' - like with fbf-transform, this ensures that transforms of rotations will go the shortest way,
	thus going only 4 degrees from 358 to 2 and not 356 degrees around.
	If the \pos is the same on both lines, only transforms will be applied.
	Logically, you must NOT select 2 consecutive lines when you want to run this, though you can select every other line.
 Multimove: when first line has \move and the other lines have \pos, \move is calculated from the first line for the others.
 Shiftmove: like teleporter, but only for the 2nd set of coordinates, ie x2, y2. Uses input from the Teleporter section.
 Shiftstart: similarly, this only shifts the initial \move coordinates.
 
 Modifications: 'round numbers' rounds coordinates for pos, move, org and clip depending on the 'Round' submenu.
   'reverse move' reverses the direction of \move.
 Move2fbf: splits a line frame by frame, ie makes a line for each frame. If there's \move, it calculates \pos tags for each line.
   If there are transforms, it calculates values for each line.
   Conditions: Only deals with initial block of tags. Works with only one set of transforms. Doesn't handle \fad.
		Move and transforms must be applied from first to last frame. 
		(Technically, \t would need to have the same timecodes as default \move tag, rather than zeros.)
 Joinfbflines: Select frame-by-frame lines, input numer when asked, for example 3, and each 3 lines will be joined into one 
		(same way as with "Join (keep first)" from the right-click menu)
 KillMoveTimes: nukes the timecodes from a \move tag.
 FReeZe: adds \frz with the value from the -frz- menu (the only point being that you get exact, round values).
 Rotate/flip: rotates/flips by 180 dgrees from current value.
 Negative rot: keeps the same rotation, but changes to negative number, like 350 -> -10, which helps with transforms.
 Letterbreak: creates vertical text by putting a linebreak after each letter.
 Wordbreak: replaces spaces with linebreaks.
   
 Copy Coordinates: copies from first line to the others.
 
 Teleport: shifts coordinates by given X and Y values.
   
--]]


--	SETTINGS	--

align_with_first=false
keep_both=false
rotation_acceleration=true

cc_posimove=true
cc_org=true
cc_clip=true
cc_tclip=true
cc_replicate_tags=true

tele_pos=true
tele_move=true
tele_clip=true
tele_org=true

delete_orig_line_in_move2fbf=false

--  --	--  --	--  --	--

script_name = "Hyperdimensional Relocator"
script_description = "Makes things appear different from before"
script_author = "reanimated"
script_version = "1.4"

include("karaskel.lua")
include("utils.lua")

function positron(subs,sel)
    ps=res.post
    for x, i in ipairs(sel) do
        local line=subs[i]
	local text=line.text
	    if x==1 and not text:match("\\pos") then aegisub.dialog.display({{class="label",
		    label="No \\pos tag in the first line.",x=0,y=0,width=1,height=2}},{"OK"}) aegisub.cancel()  end
		    
	    if x==1 and res.first then pxx,pyy=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") 
		if res.posi=="Align X" then ps=pxx else ps=pyy end 
	    end
	    
	    if text:match("\\pos") then
		if res.posi=="Align X" then
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\pos("..ps..",%2)")
		else
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\pos(%1,"..ps..")")
		end
	    end
	line.text=text
        subs[i]=line
    end
end

function bilocator(subs, sel)
    for i=#sel,1,-1 do
        local line = subs[sel[i]]
	local text=line.text
	
	    if res.move=="transmove" and sel[i]<#subs then
	    
	    	start=line.start_time		-- start time
		endt=line.end_time		-- end time
		nextline=subs[sel[i]+1]
		text2=nextline.text
		
		ms2fr=aegisub.frame_from_ms
		fr2ms=aegisub.ms_from_frame
		
		keyframes=aegisub.keyframes()	-- keyframes table
		startf=ms2fr(start)		-- startframe
		endf=ms2fr(endt)		-- endframe
		start2=fr2ms(startf)
		endt2=fr2ms(endf-1)
		tim=fr2ms(1)
		movt1=start2-start+tim		-- first timecode in \move
		movt2=endt2-start+tim		-- second timecode in \move
		movt=movt1..","..movt2
		
		-- failcheck
		if not text:match("\\pos") or not text2:match("\\pos") then 
		aegisub.dialog.display({{class="label",label="Missing \\pos tags.",x=0,y=0,width=1,height=2}},{"OK"}) 
		aegisub.cancel()
		end
		
		-- move
		p1=text:match("\\pos%(([^%)]+)%)")
		p2=text2:match("\\pos%(([^%)]+)%)")
		if p2~=p1 then text=text:gsub("\\pos%(([^%)]+)%)","\\move(%1,"..p2..","..movt..")") end
		
		-- transforms
		tf=""
		
		-- fstuff
		if text2:match("\\fs[%d%.]+") then fs2=text2:match("(\\fs[%d%.]+)") 
		    if text:match("\\fs[%d%.]+") then fs1=text:match("(\\fs[%d%.]+)") else fs1="" end
		    if fs1~=fs2 then tf=tf..fs2 end
		end
		if text2:match("\\fsp[%d%.%-]+") then fsp2=text2:match("(\\fsp[%d%.%-]+)") 
		    if text:match("\\fsp[%d%.%-]+") then fsp1=text:match("(\\fsp[%d%.%-]+)") else fsp1="" end
		    if fsp1~=fsp2 then tf=tf..fsp2 end
		end
		if text2:match("\\fscx[%d%.]+") then fscx2=text2:match("(\\fscx[%d%.]+)") 
		    if text:match("\\fscx[%d%.]+") then fscx1=text:match("(\\fscx[%d%.]+)") else fscx1="" end
		    if fscx1~=fscx2 then tf=tf..fscx2 end
		end
		if text2:match("\\fscy[%d%.]+") then fscy2=text2:match("(\\fscy[%d%.]+)") 
		    if text:match("\\fscy[%d%.]+") then fscy1=text:match("(\\fscy[%d%.]+)") else fscy1="" end
		    if fscy1~=fscy2 then tf=tf..fscy2 end
		end
		-- blur border shadow
		if text2:match("\\blur[%d%.]+") then blur2=text2:match("(\\blur[%d%.]+)") 
		    if text:match("\\blur[%d%.]+") then blur1=text:match("(\\blur[%d%.]+)") else blur1="" end
		    if blur1~=blur2 then tf=tf..blur2 end		
		end
		if text2:match("\\bord[%d%.]+") then bord2=text2:match("(\\bord[%d%.]+)") 
		    if text:match("\\bord[%d%.]+") then bord1=text:match("(\\bord[%d%.]+)") else bord1="" end
		    if bord1~=bord2 then tf=tf..bord2 end
		end
		if text2:match("\\shad[%d%.]+") then shad2=text2:match("(\\shad[%d%.]+)") 
		    if text:match("\\shad[%d%.]+") then shad1=text:match("(\\shad[%d%.]+)") else shad1="" end
		    if shad1~=shad2 then tf=tf..shad2 end
		end
		-- colours
		if text2:match("\\1?c&H%x+&") then c12=text2:match("(\\1?c&H%x+&)") 
		    if text:match("\\1?c&H%x+&") then c11=text:match("(\\1?c&H%x+&)") else c11="" end
		    if c11~=c12 then tf=tf..c12 end
		end
		if text2:match("\\2c&H%x+&") then c22=text2:match("(\\2c&H%x+&)") 
		    if text:match("\\2c&H%x+&") then c21=text:match("(\\2c&H%x+&)") else c21="" end
		    if c21~=c22 then tf=tf..c22 end
		end
		if text2:match("\\3c&H%x+&") then c32=text2:match("(\\3c&H%x+&)") 
		    if text:match("\\3c&H%x+&") then c31=text:match("(\\3c&H%x+&)") else c31="" end
		    if c31~=c32 then tf=tf..c32 end
		end
		if text2:match("\\4c&H%x+&") then c42=text2:match("(\\4c&H%x+&)") 
		    if text:match("\\4c&H%x+&") then c41=text:match("(\\4c&H%x+&)") else c41="" end
		    if c41~=c42 then tf=tf..c42 end
		end
		-- alphas
		if text2:match("\\alpha&H%x+&") then alpha2=text2:match("(\\alpha&H%x+&)") 
		    if text:match("\\alpha&H%x+&") then alpha1=text:match("(\\alpha&H%x+&)") else alpha1="" end
		    if alpha1~=alpha2 then tf=tf..alpha2 end
		end
		if text2:match("\\1a&H%x+&") then a12=text2:match("(\\1a&H%x+&)") 
		    if text:match("\\1a&H%x+&") then a11=text:match("(\\1a&H%x+&)") else a11="" end
		    if a11~=a12 then tf=tf..a12 end
		end
		if text2:match("\\2a&H%x+&") then a22=text2:match("(\\2a&H%x+&)") 
		    if text:match("\\2a&H%x+&") then a21=text:match("(\\2a&H%x+&)") else a21="" end
		    if a21~=a22 then tf=tf..a22 end
		end
		if text2:match("\\3a&H%x+&") then a32=text2:match("(\\3a&H%x+&)") 
		    if text:match("\\3a&H%x+&") then a31=text:match("(\\3a&H%x+&)") else a31="" end
		    if a31~=a32 then tf=tf..a32 end
		end
		if text2:match("\\4a&H%x+&") then a42=text2:match("(\\4a&H%x+&)") 
		    if text:match("\\4a&H%x+&") then a41=text:match("(\\4a&H%x+&)") else a41="" end
		    if a41~=a42 then tf=tf..a42 end
		end
		-- rotations
		if text2:match("\\frz[%d%.%-]+") then frz2=text2:match("(\\frz[%d%.%-]+)") zz2=tonumber(text2:match("\\frz([%d%.%-]+)"))
		    if text:match("\\frz[%d%.%-]+") then frz1=text:match("(\\frz[%d%.%-]+)") zz1=tonumber(text:match("\\frz([%d%.%-]+)"))
		    else frz1="" zz1="0" end
		    if frz1~=frz2 then 
			if res.rot and math.abs(zz2-zz1)>180 then
			    if zz2>zz1 then zz2=zz2-360 frz2="\\frz"..zz2 else 
			    zz1=zz1-360 text=text:gsub("\\frz[%d%.%-]+","\\frz"..zz1)
			    end
			end
		    tf=tf..frz2 end
		end
		if text2:match("\\frx[%d%.%-]+") then frx2=text2:match("(\\frx[%d%.%-]+)") xx2=tonumber(text2:match("\\frx([%d%.%-]+)"))
		    if text:match("\\frx[%d%.%-]+") then frx1=text:match("(\\frx[%d%.%-]+)") xx1=tonumber(text:match("\\frx([%d%.%-]+)"))
		    else frx1="" xx1="0" end
		    if frx1~=frx2 then 
			if res.rot and math.abs(xx2-xx1)>180 then
			    if xx2>xx1 then xx2=xx2-360 frx2="\\frx"..xx2 else 
			    xx1=xx1-360 text=text:gsub("\\frx[%d%.%-]+","\\frx"..xx1)
			    end
			end
		    tf=tf..frx2 end
		end
		if text2:match("\\fry[%d%.%-]+") then fry2=text2:match("(\\fry[%d%.%-]+)") yy2=tonumber(text2:match("\\fry([%d%.%-]+)"))
		    if text:match("\\fry[%d%.%-]+") then fry1=text:match("(\\fry[%d%.%-]+)") yy1=tonumber(text:match("\\fry([%d%.%-]+)"))
		    else fry1="" yy1="0"  end
		    if fry1~=fry2 then 
			if res.rot and math.abs(yy2-yy1)>180 then
			    if yy2>yy1 then yy2=yy2-360 fry2="\\fry"..yy2 else 
			    yy1=yy1-360 text=text:gsub("\\fry[%d%.%-]+","\\fry"..yy1)
			    end
			end
		    tf=tf..fry2 end
		end
		-- shearing
		if text2:match("\\fax[%d%.%-]+") then fax2=text2:match("(\\fax[%d%.%-]+)") 
		    if text:match("\\fax[%d%.%-]+") then fax1=text:match("(\\fax[%d%.%-]+)") else fax1="" end
		    if fax1~=fax2 then tf=tf..fax2 end
		end
		if text2:match("\\fay[%d%.%-]+") then fay2=text2:match("(\\fay[%d%.%-]+)") 
		    if text:match("\\fay[%d%.%-]+") then fay1=text:match("(\\fay[%d%.%-]+)") else fay1="" end
		    if fay1~=fay2 then tf=tf..fay2 end
		end
		-- apply transform
		if tf~="" then
		    text=text:gsub("^({\\[^}]-)}","%1\\t("..movt..","..tf..")}")
		end
		
		-- delete line 2
		if res.keep==false then subs.delete(sel[i]+1) end
		
	    end -- end of transmove
		
	    if res.move=="horizontal" then
		    text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)","\\move(%1,%2,%3,%2") end
	    if res.move=="vertical" then
		    text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)","\\move(%1,%2,%1,%4") end
	    
	    if res.move=="shiftmove" then
		xx=res.eks	yy=res.wai
		text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
		function(a,b,c,d) return "\\move("..a.. "," ..b.. "," ..c+xx.. "," ..d+yy end)
	    end
	    
	    if res.move=="shiftstart" then
		xx=res.eks	yy=res.wai
		text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
		function(a,b,c,d) return "\\move("..a+xx.. "," ..b+yy.. "," ..c.. "," ..d end)
	    end
	    
	line.text=text
        subs[sel[i]] = line
    end
end

function multimove(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text = subs[i].text
	-- error if first line's missing \move tag
	if x==1 and text:match("\\move")==nil then aegisub.dialog.display({{class="label",
		    label="Missing \\move tag on line 1",x=0,y=0,width=1,height=2}},{"OK"})
		    mc=1
	else 
	-- get coordinates from \move on line 1
	    if text:match("\\move") then
	    x1,y1,x2,y2,t,m1,m2=nil
		if text:match("\\move%([%d%.%-]+%,[%d%.%-]+%,[%d%.%-]+%,[%d%.%-]+%,[%d%.%,%-]+%)") then
		x1,y1,x2,y2,t=text:match("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%,%-]+)%)")
		else
		x1,y1,x2,y2=text:match("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%)")
		end
	    m1=x2-x1	m2=y2-y1	-- difference between start/end position
	    end
	-- error if any of lines 2+ don't have \pos tag
	    if x~=1 and text:match("\\pos")==nil then poscheck=1
	    else  
	-- apply move coordinates to lines 2+
		if x~=1 and m2~=nil then
		p1,p2=text:match("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)")
		    if t~=nil then
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\move%(%1,%2,"..p1+m1..","..p2+m2..","..t.."%)")
		    else
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\move(%1,%2,"..p1+m1..","..p2+m2..")")
		    end
		end
	    end
	    
	end
	    line.text = text
	    subs[i]=line
    end
	if poscheck==1 then aegisub.dialog.display({{class="label",
		label="Some lines are missing \\pos tags",x=0,y=0,width=1,height=2}},{"OK"}) end
	x1,y1,x2,y2,t,m1,m2=nil
	poscheck=0 
end

function shiftmove(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
	local text=line.text
	xx=res.eks
	yy=res.wai
	if res.mod=="shiftmove" then
	    text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
	    function(a,b,c,d) return "\\move("..a.. "," ..b.. "," ..c+xx.. "," ..d+yy end)
	end
	line.text=text
        subs[i]=line
    end
end

function round(a,b,c,d)
	if a-math.floor(a)>=0.5 then a=math.ceil(a) else a=math.floor(a) end
	if b-math.floor(b)>=0.5 then b=math.ceil(b) else b=math.floor(b) end
	if c-math.floor(c)>=0.5 then c=math.ceil(c) else c=math.floor(c) end
	if d-math.floor(d)>=0.5 then d=math.ceil(d) else d=math.floor(d) end
	return a,b,c,d
end

function modifier(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
	local text=line.text
	    
		start=line.start_time		-- start time
		endt=line.end_time		-- end time
		
		ms2fr=aegisub.frame_from_ms
		fr2ms=aegisub.ms_from_frame
		startf=ms2fr(start)		-- startframe
		endf=ms2fr(endt)		-- endframe
		start2=fr2ms(startf)
		endt2=fr2ms(endf-1)
		tim=fr2ms(1)
		movt1=start2-start+tim		-- first timecode in \move
		movt2=endt2-start+tim		-- second timecode in \move
		movt=movt1..","..movt2
		
	    if res.mod=="round numbers" then
		if text:match("\\pos") and res.rnd=="all" or text:match("\\pos") and res.rnd=="pos" then
		px,py=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)")
		px,py=round(px,py,0,0)
		text=text:gsub("\\pos%([%d%.%-]+,[%d%.%-]+%)","\\pos("..px..","..py..")")
		end
		if text:match("\\org") and res.rnd=="all" or text:match("\\org") and res.rnd=="org" then
		ox,oy=text:match("\\org%(([%d%.%-]+),([%d%.%-]+)%)")
		ox,oy=round(ox,oy,0,0)
		text=text:gsub("\\org%([%d%.%-]+,[%d%.%-]+%)","\\org("..ox..","..oy..")")
		end
		if text:match("\\move") and res.rnd=="all" or text:match("\\move") and res.rnd=="move" then
		mo1,mo2,mo3,mo4=text:match("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
		mo1,mo2,mo3,mo4=round(mo1,mo2,mo3,mo4)
		text=text:gsub("\\move%([%d%.%-]+,[%d%.%-]+,[%d%.%-]+,[%d%.%-]+","\\move("..mo1..","..mo2..","..mo3..","..mo4)
		end
		if text:match("\\clip%([%d%.%-]") and res.rnd=="all" or text:match("\\clip%([%d%.%-]") and res.rnd=="clip" then
		for klip in text:gmatch("(\\i?clip%([%d%.%-]+,[%d%.%-]+,[%d%.%-]+,[%d%.%-]+)") do
		cl1,cl2,cl3,cl4=klip:match("\\i?clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
		cl1,cl2,cl3,cl4=round(cl1,cl2,cl3,cl4)
		klip2=klip:gsub("(\\i?clip)%([%d%.%-]+,[%d%.%-]+,[%d%.%-]+,[%d%.%-]+","%1("..cl1..","..cl2..","..cl3..","..cl4)
		klip=esc(klip)
		text=text:gsub(klip,klip2)
		end
		end
	    end
	    
	    if res.mod=="reverse move" then
		text=text:gsub("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\move(%3,%4,%1,%2")
	    end
	    
	    if res.mod=="killmovetimes" then
		text=text:gsub("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\move(%1,%2,%3,%4")
	    end
	    
	    if res.mod=="fullmovetimes" then
		text=text:gsub("\\move%(([%d%.%-]+,[%d%.%-]+,[%d%.%-]+,[%d%.%-]+),([%d%.%-]+),([%d%.%-]+)","\\move(%1,"..movt)
		text=text:gsub("\\move%(([%d%.%-]+,[%d%.%-]+,[%d%.%-]+,[%d%.%-]+)%)","\\move(%1,"..movt..")")
	    end
	       
	    if res.mod=="FReeZe" then
		frz=res.freeze
		if text:match("^{[^}]*\\frz") then
		text=text:gsub("^({[^}]*\\frz)([%d%.%-]+)","%1"..frz) 
		else
		text=addtag("\\frz"..frz,text)
		end
	    end
	    
	    if res.mod=="rotate 180" then
		if text:match("\\frz") then rot="frz" text=flip(rot,text)
		else
		text=addtag("\\frz180",text)
		end
	    end
	    
	    if res.mod=="flip hor." then
		if text:match("\\fry") then rot="fry" text=flip(rot,text)
		else
		text=addtag("\\fry180",text)
		end
	    end
	    
	    if res.mod=="flip vert." then
		if text:match("\\frx") then rot="frx" text=flip(rot,text)
		else
		text=addtag("\\frx180",text)
		end
	    end
	    
	    if res.mod=="letterbreak" then
	      if not text:match("^({\\[^}]-})") then
		notag1=text:match("^([^{]+)")
		local notag2=notag1:gsub("([%a%s%d])","%1\\N")
		notag=esc(notag1)
		text=text:gsub(notag1,notag2)
	      end
	      for notag in text:gmatch("{\\[^}]-}([^{]+)") do
		local notag2=notag:gsub("([%a%s%d])","%1\\N")
		notag=esc(notag)
		text=text:gsub(notag,notag2)
	      end
	      text=text:gsub("\\N$","")
	    end
	    
	    if res.mod=="wordbreak" then
	      if not text:match("^({\\[^}]-})") then
		notag1=text:match("^([^{]+)")
		local notag2=notag1:gsub("%s","\\N")
		notag=esc(notag1)
		text=text:gsub(notag1,notag2)
	      end
	      for notag in text:gmatch("{\\[^}]-}([^{]+)") do
		local notag2=notag:gsub("%s","\\N")
		notag=esc(notag)
		text=text:gsub(notag,notag2)
	      end
	      text=text:gsub("\\N$","")
	    end
	    
	line.text=text
        subs[i]=line
    end
end

function flip(rot,text)
    for rotation in text:gmatch("\\"..rot.."([%d%.%-]+)") do
	rotation=tonumber(rotation)
	if rotation<180 then newrot=rotation+180 end
	if rotation>180 then newrot=rotation-180 end
	text=text:gsub(rot..rotation,rot..newrot)
    end
    return text
end

function movetofbf(subs, sel)
local meta,styles=karaskel.collect_head(subs,false)
    for i=#sel,1,-1 do
        line = subs[sel[i]]
        text = subs[sel[i]].text
	karaskel.preproc_line(subs,meta,styles,line)
		
	    start=line.start_time
	    endt=line.end_time
	    ms2fr=aegisub.frame_from_ms
	    fr2ms=aegisub.ms_from_frame
	    startf=ms2fr(start)
	    endf=ms2fr(endt)
	    frames=endf-1-startf
	    frnum=frames
	    l2=line
	    
		for frm=endf-1,startf,-1 do
		l2.text=text
			if text:match("\\move") then
			    m1,m2,m3,m4=text:match("\\move%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
			    pos1=math.floor((((m3-m1)/frames)*frnum+m1)*100)/100
			    pos2=math.floor((((m4-m2)/frames)*frnum+m2)*100)/100
			    l2.text=text:gsub("\\move%([^%)]*%)","\\pos("..pos1..","..pos2..")")
			end
		  
		    tags=l2.text:match("^{[^}]*}")
		    if tags:match("\\t") then
			text=text:gsub("^({\\[^}]-})",function(tg) return cleantr(tg) end)
			terraform(tags)
			
			l2.text=l2.text:gsub("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","")	:gsub("(\\t%([^%(%)]-%))","")
			l2.text=l2.text:gsub("^({[^}]*)}","%1"..ftags.."}")
			
			l2.text=duplikill(l2.text)
		    end
		    
		    l2.start_time=fr2ms(frm)
		    l2.end_time=fr2ms(frm+1)
		    subs.insert(sel[i]+1,l2) table.insert(sel,sel[i]+frnum)
		    frnum=frnum-1
		end
		line.end_time=endt
		line.comment=true
	line.text = text
	subs[sel[i]] = line
	if res.delfbf then subs.delete(sel[i]) end
    end
    return sel
end

function terraform(tags)
	tra=tags:match("(\\t%([^%(%)]-%))")
	if tra==nil then tra=text:match("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))") end	--aegisub.log("\ntra: "..tra)
	nontra=tags:gsub("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","")	:gsub("(\\t%([^%(%)]-%))","")
	ftags=""
	-- most tags
	for tg, valt in tra:gmatch("\\(%a+)([%d%.%-]+)") do
		val1=nil
		if nontra:match(tg) then val1=nontra:match("\\"..tg.."([%d%.%-]+)") end
		if val1==nil then
		if tg=="bord" or tg=="xbord" or tg=="ybord" then val1=line.styleref.outline end
		if tg=="shad" or tg=="xshad" or tg=="yshad" then val1=line.styleref.shadow end
		if tg=="fs" then val1=line.styleref.fontsize end
		if tg=="fsp" then val1=line.styleref.spacing end
		if tg=="frz" then val1=line.styleref.angle end
		if tg=="fscx" then val1=line.styleref.scale_x end
		if tg=="fscy" then val1=line.styleref.scale_y end
		if tg=="blur" or tg=="be" or tg=="fax" or tg=="fay" or tg=="frx" or tg=="fry" then val1=0 end
		end
		valf=math.floor((((valt-val1)/frames)*frnum+val1)*100)/100
		ftags=ftags.."\\"..tg..valf
	end
	-- clip
	if tra:match("\\clip") then
	c1,c2,c3,c4=nontra:match("\\clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
	k1,k2,k3,k4=tra:match("\\clip%(([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)")
	tc1=math.floor((((k1-c1)/frames)*frnum+c1)*100)/100
	tc2=math.floor((((k2-c2)/frames)*frnum+c2)*100)/100
	tc3=math.floor((((k3-c3)/frames)*frnum+c3)*100)/100
	tc4=math.floor((((k4-c4)/frames)*frnum+c4)*100)/100
	ftags=ftags.."\\clip("..tc1..","..tc2..","..tc3..","..tc4..")"
	end
	-- colour/alpha
	tra=tra:gsub("\\1c","\\c")
	nontra=nontra:gsub("\\1c","\\c")
	for tg, valt in tra:gmatch("\\(%w+)(&H%x+&)") do
		val1=nil
		if nontra:match(tg) then val1=nontra:match("\\"..tg.."(&H%x+&)") end
		if val1==nil then
		if tg=="c" then val1=line.styleref.color1:gsub("H%x%x","H") end
		if tg=="2c" then val1=line.styleref.color2:gsub("H%x%x","H") end
		if tg=="3c" then val1=line.styleref.color3:gsub("H%x%x","H") end
		if tg=="4c" then val1=line.styleref.color4:gsub("H%x%x","H") end
		if tg=="1a" then val1=line.styleref.color1:gsub("(H%x%x)%x%x%x%x%x%x","%1") end
		if tg=="2a" then val1=line.styleref.color2:gsub("(H%x%x)%x%x%x%x%x%x","%1") end
		if tg=="3a" then val1=line.styleref.color3:gsub("(H%x%x)%x%x%x%x%x%x","%1") end
		if tg=="4a" then val1=line.styleref.color4:gsub("(H%x%x)%x%x%x%x%x%x","%1") end
		if tg=="alpha" then val1="&H00&" end
		end
		if tg:match("c") then valf=interpolate_color(frnum/frames, val1, valt) end
		if tg:match("a") then valf=interpolate_alpha(frnum/frames, val1, valt) end
		ftags=ftags.."\\"..tg..valf
	end
end

function cleantr(tags)
	trnsfrm=""
	for t in tags:gmatch("(\\t%([^%(%)]-%))") do trnsfrm=trnsfrm..t end
	for t in tags:gmatch("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))") do trnsfrm=trnsfrm..t end
	tags=tags:gsub("(\\t%([^%(%)]+%))","")
	tags=tags:gsub("(\\t%([^%(%)]-%([^%)]-%)[^%)]-%))","")
	tags=tags:gsub("^({\\[^}]*)}","%1"..trnsfrm.."}")

	cleant=""
	for ct in tags:gmatch("\\t%((\\[^%(%)]-)%)") do cleant=cleant..ct end
	for ct in tags:gmatch("\\t%((\\[^%(%)]-%([^%)]-%)[^%)]-)%)") do cleant=cleant..ct end
	tags=tags:gsub("(\\t%(\\[^%(%)]+%))","")
	tags=tags:gsub("(\\t%(\\[^%(%)]-%([^%)]-%)[^%)]-%))","")
	if cleant~="" then tags=tags:gsub("^({\\[^}]*)}","%1\\t("..cleant..")}") end
	return tags
end

function duplikill(text)
	tags1={"blur","be","bord","shad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay"}
	for i=1,#tags1 do
	    tag=tags1[i]
	    text=text:gsub("\\"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%1%2")
	end
	text=text:gsub("\\1c&","\\c&")
	tags2={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}
	for i=1,#tags2 do
	    tag=tags1[i]
	    text=text:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%1%2")
	end
	text=text:gsub("\\i?clip%([^%)]-%)([^}]-)(\\i?clip%([^%)]-%))","%1%2")
	return text
end

function joinfbflines(subs, sel)
    -- dialog
	joindialog={
	    {x=0,y=0,width=1,height=1,class="label",label="How many lines?",},
	    {x=0,y=1,width=1,height=1,class="intedit",name="join",value=2,step=1,min=2,max=50 },
	}
	pressed, res = aegisub.dialog.display(joindialog,{"OK"},{ok='OK'})
    -- number
    count=1
    for x, i in ipairs(sel) do
        local line=subs[i]
	line.effect=count
	if x==1 then line.effect="1" end
        subs[i]=line
	count=count+1
	if count>res.join then count=1 end
    end
    -- delete & time
    for i=#sel,1,-1 do
	local line=subs[sel[i]]
	if line.effect==tostring(res.join) then endtime=line.end_time end
	if i==#sel then endtime=line.end_time end
	if line.effect=="1" then line.end_time=endtime line.effect="" subs[sel[i]]=line 
	else subs.delete(sel[i]) table.remove(sel,#sel) end
    end
    return sel
end

function negativerot(subs, sel)
	negdialog={
	{x=0,y=0,width=1,height=1,class="checkbox",name="frz",label="frz",value=true},
	{x=1,y=0,width=1,height=1,class="checkbox",name="frx",label="frx"},
	{x=2,y=0,width=1,height=1,class="checkbox",name="fry",label="fry"},
	}
	presst,rez=aegisub.dialog.display(negdialog,{"OK","Cancel"},{ok='OK',cancel='Cancel'})
	if presst=="Cancel" then aegisub.cancel() end
    for x, i in ipairs(sel) do
        local line=subs[i]
	local text=line.text
	if rez.frz then text=text:gsub("\\frz([%d%.]+)",function(r) return "\\frz"..r-360 end) end
	if rez.frx then text=text:gsub("\\frx([%d%.]+)",function(r) return "\\frx"..r-360 end) end
	if rez.fry then text=text:gsub("\\fry([%d%.]+)",function(r) return "\\fry"..r-360 end) end
	line.text=text
	subs[i]=line
    end
end

function clone(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text = subs[i].text
	if not text:match("^{\\") then text=text:gsub("^","{\\}") end

	if res.pos then
		if x==1 and text:match("\\pos") then
		posi=text:match("\\pos%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\pos") and posi~=nil	 then
		text=text:gsub("\\pos%([^%)]-%)","\\pos%("..posi.."%)")
		end
		if x~=1 and not text:match("\\pos") and not text:match("\\move") and posi~=nil and res.cre then
		text=text:gsub("^{\\","{\\pos%("..posi.."%)\\")
		end
	
		if x==1 and text:match("\\move") then
		move=text:match("\\move%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\move") and move~=nil then
		text=text:gsub("\\move%([^%)]-%)","\\move%("..move.."%)")
		end
		if x~=1 and not text:match("\\move") and not text:match("\\pos") and move~=nil and res.cre then
		text=text:gsub("^{\\","{\\move%("..move.."%)\\")
		end
	end
	
	if res.org then
		if x==1 and text:match("\\org") then
		orig=text:match("\\org%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\org") and orig~=nil then
		text=text:gsub("\\org%([^%)]-%)","\\org%("..orig.."%)")
		end
		if x~=1 and not text:match("\\org") and orig~=nil and res.cre then
		text=text:gsub("^({\\[^}]*)}","%1\\org%("..orig.."%)}")
		end
	end
	
	if res.clip then
		if x==1 and text:match("\\i?clip") then
		klip=text:match("\\i?clip%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\i?clip") and klip~=nil then
		text=text:gsub("\\(i?clip)%([^%)]-%)","\\%1%("..klip.."%)")
		end
		if x~=1 and not text:match("\\i?clip") and klip~=nil and res.cre then
		text=text:gsub("^({\\[^}]*)}","%1\\clip%("..klip.."%)}")
		end
	end
	
	if res.tclip then
		if x==1 and text:match("\\t%([%d%.%,]*\\i?clip") then
		tklip=text:match("\\t%([%d%.%,]*\\i?clip%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\i?clip") and tklip~=nil then
		text=text:gsub("\\t%(([%d%.%,]*)\\(i?clip)%([^%)]-%)","\\t%(%1\\%2%("..tklip.."%)")
		end
		if x~=1 and not text:match("\\t%([%d%.%,]*\\i?clip") and tklip~=nil and res.cre then
		text=text:gsub("^({\\[^}]*)}","%1\\t%(\\clip%("..tklip.."%)%)}")
		end
	end

	text=text
	:gsub("\\\\","\\")
	:gsub("\\}","}")
	:gsub("{}","")
	
	line.text = text
	subs[i]=line
    end
    posi, move, orig, klip, tklip=nil
end

function teleport(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text = subs[i].text
	xx=res.eks
	yy=res.wai

	if res.tppos then
	    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)",
	    function(a,b) return "\\pos(".. a+xx.. "," ..b+yy..")" end)
	end

	if res.tporg then
	    text=text:gsub("\\org%(([%d%.%-]+)%,([%d%.%-]+)%)",
	    function(a,b) return "\\org(".. a+xx.. "," ..b+yy..")" end)
	end

	if res.tpmov then
	    text=text:gsub("\\move%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
	    function(a,b,c,d) return "\\move("..a+xx.. "," ..b+yy.. "," ..c+xx.. "," ..d+yy end)
	end

	if res.tpclip then
	    text=text:gsub("clip%(([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)%,([%d%.%-]+)",
	    function(a,b,c,d) return "clip("..a+xx.. "," ..b+yy.. "," ..c+xx.. "," ..d+yy end)
	    
	    if text:match("clip%(m [%d%a%s%-]+%)") then
	    ctext=text:match("clip%(m ([%d%a%s%-]+)%)")
	    ctext2=ctext:gsub("([%d%-]+)%s([%d%-]+)",function(a,b) return a+xx.." "..b+yy end)
	    ctext=ctext:gsub("%-","%%-")
	    text=text:gsub(ctext,ctext2)
	    end
	end

	line.text = text
	subs[i]=line
    end
end

function esc(str)
	str=str:gsub("%%","%%%%")
	str=str:gsub("%(","%%%(")
	str=str:gsub("%)","%%%)")
	str=str:gsub("%[","%%%[")
	str=str:gsub("%]","%%%]")
	str=str:gsub("%.","%%%.")
	str=str:gsub("%*","%%%*")
	str=str:gsub("%-","%%%-")
	str=str:gsub("%+","%%%+")
	str=str:gsub("%?","%%%?")
	return str
end

function addtag(tag,text) text=text:gsub("^({\\[^}]-)}","%1"..tag.."}") return text end

function relocator(subs, sel)
	dialog_config=
	{
	    {x=10,y=0,width=3,height=1,class="label",label="Teleportation",},
	    {x=10,y=1,width=3,height=1,class="floatedit",name="eks",hint="X"},
	    {x=10,y=2,width=3,height=1,class="floatedit",name="wai",hint="Y"},

	    {x=0,y=0,width=2,height=1,class="label",label="Repositioning Field",},
	    {x=0,y=1,width=1,height=1,class="dropdown",name="posi",items={"Align X","Align Y"},value="Align X",},
	    {x=0,y=2,width=1,height=1,class="floatedit",name="post",value=0},
	    {x=0,y=3,width=1,height=1,class="checkbox",name="first",label="align with first",value=align_with_first,},
	    
	    {x=2,y=0,width=2,height=1,class="label",label="Soul Bilocator"},
	    {x=2,y=1,width=1,height=1,class="dropdown",name="move",
		items={"transmove","horizontal","vertical","multimove","shiftstart","shiftmove"},value="transmove",},
	    {x=2,y=2,width=1,height=1,class="checkbox",name="keep",label="keep both",value=keep_both,},
	    {x=2,y=3,width=3,height=1,class="checkbox",name="rot",label="rotation acceleration",value=rotation_acceleration,},
	    {x=2,y=4,width=3,height=1,class="checkbox",name="delfbf",label="delete m2fbf orig. line",value=delete_orig_line_in_move2fbf,},
	    
	    {x=4,y=0,width=2,height=1,class="label",label="Morphing Grounds",},
	    {x=4,y=1,width=2,height=1,class="dropdown",name="mod",
		items={"round numbers","reverse move","move2fbf","join fbf lines","killmovetimes","fullmovetimes","FReeZe","rotate 180","flip hor.","flip vert.","negative rot","letterbreak","wordbreak"},value="round numbers"},
	    {x=4,y=2,width=1,height=1,class="label",label="Round:",},
	    {x=5,y=2,width=1,height=1,class="dropdown",name="rnd",items={"all","pos","move","org","clip"},value="all"},
	    {x=5,y=3,width=1,height=1,class="dropdown",name="freeze",
		items={"-frz-","30","45","60","90","120","135","150","180","-30","-45","-60","-90","-120","-135","-150"},value="-frz-"},
	    
	    {x=6,y=0,width=3,height=1,class="label",label="Cloning Laboratory",},
	    {x=6,y=1,width=2,height=1,class="checkbox",name="pos",label="\\posimove",value=cc_posimove },
	    {x=8,y=1,width=1,height=1,class="checkbox",name="org",label="\\org",value=cc_org },
	    {x=6,y=2,width=1,height=1,class="checkbox",name="clip",label="\\[i]clip",value=cc_clip },
	    {x=7,y=2,width=2,height=1,class="checkbox",name="tclip",label="\\t(\\[i]clip)",value=cc_tclip },
	    {x=6,y=3,width=4,height=1,class="checkbox",name="cre",label="replicate missing tags",value=cc_replicate_tags },
	    
	    {x=11,y=3,width=1,height=1,class="checkbox",name="tppos",label="pos",value=tele_pos },
	    {x=11,y=4,width=1,height=1,class="checkbox",name="tpmov",label="move",value=tele_move },
	    {x=12,y=3,width=1,height=1,class="checkbox",name="tporg",label="org",value=tele_org },
	    {x=12,y=4,width=1,height=1,class="checkbox",name="tpclip",label="clip",value=tele_clip },
 	} 
	
	pressed, res = aegisub.dialog.display(dialog_config,
	{"Positron Cannon","Hyperspace Travel","Metamorphosis","Cloning Sequence","Teleportation","Disintegrate"},{cancel='Disintegrate'})
	if pressed=="Disintegrate" then aegisub.cancel() end
	if pressed=="Positron Cannon" then positron(subs, sel) end
	if pressed=="Hyperspace Travel" then
	    if res.move=="multimove" then multimove (subs, sel) else bilocator(subs, sel) end
	end
	if pressed=="Metamorphosis" then 
	    if res.mod=="move2fbf" then movetofbf(subs, sel) 
	    elseif res.mod=="join fbf lines" then joinfbflines(subs, sel)
	    elseif res.mod=="negative rot" then negativerot(subs, sel)
	    else modifier(subs, sel) end
	end
	if pressed=="Cloning Sequence" then clone(subs, sel) end
	if pressed=="Teleportation" then teleport(subs, sel) end
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, relocator)