--[[	Instructions

 Position: Align X means all selected \pos tags will have the same given X coordinate. Same with Align Y for Y.
   useful for multiple signs on screen that need to be aligned horizontally/vertically or mocha signs that should move horizontally/vertically.
   
 Move: horizontal means y2 will be the same as y1 so that the sign moves in a straight horizontal manner. Same principle for vertical.
 Transmove: this is the real deal here. Main function: create \move from two lines with \pos.
	Duplicate your line and position the second one where you want the \move the end. Script will create \move from the two positions.
	Second line will be deleted by default; it's there just so you can comfortably set the final position.
	Extra function: to make this a lot more awesome, this can create transforms.
	Not only is the second line used for \move coordinates, but also for transforms. 
	Any tag on line 2 that's different from line 1 will be used to create a transform on line 1.
	So for a \move with transforms you can set the initial sign and then the final sign while everything is static.
	You can time line 2 to just the last frame. The script only uses timecodes from line 1. 
	Text from line 2 is also ignored (assumed to be same as line 1).
	You can time line 2 to start after line 1 and check "keep line 2." 
	That way line 1 transforms into line 2 and the sign stays like that for the duration of line 2.
	"Rotation shortcut" - like with fbf-transform, this ensures that transforms of rotations will go the shortest way,
	thus going only 4 degrees from 358 to 2 and not 356 degrees around.
	If the \pos is the same on both lines, only transforms will be applied.
 
 Modifications: 'round numbers' rounds coordinates for pos, move, org and clip depending on the 'Round' submenu.
   'reverse move' reverses the direction of \move.
   
--]]


script_name = "Position Adjuster"
script_description = "Does things and stuff"
script_author = "unanimated"
script_version = "1.2"

function positron(subs,sel)
    ps=res.pos
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=line.text
	    if x==1 and not text:match("\\pos") then aegisub.dialog.display({{class="label",
		    label="No \\pos tag in the first line.",x=0,y=0,width=1,height=2}},{"OK"}) aegisub.cancel()  end
		    
	    if x==1 and res.first then xx,yy=text:match("\\pos%(([%d%.%-]+),([%d%.%-]+)%)") 
		if res.posi=="Align X" then ps=xx else ps=yy end 
	    end
	    
	    if text:match("\\pos") then
		if res.posi=="Align X" then
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\pos("..ps..",%2)")
		else
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\pos(%1,"..ps..")")
		end
	    end
	line.text=text
        subs[i] = line
    end
end

function moove(subs, sel)
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
	    
	line.text=text
        subs[sel[i]] = line
    end
end

function modify(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=line.text
	
	    if res.mod=="round numbers" then
		if text:match("\\pos") and res.rnd=="all" or text:match("\\pos") and res.rnd=="pos" then
		px,py=text:match("\\pos%(([%d%.]+),([%d%.]+)%)")
		if px-math.floor(px)>=0.5 then px=math.ceil(px) else px=math.floor(px) end
		if py-math.floor(py)>=0.5 then py=math.ceil(py) else py=math.floor(py) end
		text=text:gsub("\\pos%([%d%.]+,[%d%.]+%)","\\pos("..px..","..py..")")
		end
		if text:match("\\org") and res.rnd=="all" or text:match("\\org") and res.rnd=="org" then
		ox,oy=text:match("\\org%(([%d%.]+),([%d%.]+)%)")
		if ox-math.floor(ox)>=0.5 then ox=math.ceil(ox) else ox=math.floor(ox) end
		if oy-math.floor(oy)>=0.5 then oy=math.ceil(oy) else oy=math.floor(oy) end
		text=text:gsub("\\org%([%d%.]+,[%d%.]+%)","\\org("..ox..","..oy..")")
		end
		if text:match("\\move") and res.rnd=="all" or text:match("\\move") and res.rnd=="move" then
		mo1,mo2,mo3,mo4=text:match("\\move%(([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+)")
		if mo1-math.floor(mo1)>=0.5 then mo1=math.ceil(mo1) else mo1=math.floor(mo1) end
		if mo2-math.floor(mo2)>=0.5 then mo2=math.ceil(mo2) else mo2=math.floor(mo2) end
		if mo3-math.floor(mo3)>=0.5 then mo3=math.ceil(mo3) else mo3=math.floor(mo3) end
		if mo4-math.floor(mo4)>=0.5 then mo4=math.ceil(mo4) else mo4=math.floor(mo4) end
		text=text:gsub("\\move%([%d%.]+,[%d%.]+,[%d%.]+,[%d%.]+","\\move("..mo1..","..mo2..","..mo3..","..mo4)
		end
		if text:match("\\clip%([%d%.]+,[%d%.]+,[%d%.]+,[%d%.]+") and res.rnd=="all" or text:match("\\clip%([%d%.]+,[%d%.]+,[%d%.]+,[%d%.]+") and res.rnd=="clip" then
		mo1,mo2,mo3,mo4=text:match("\\i?clip%(([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+)")
		if mo1-math.floor(mo1)>=0.5 then mo1=math.ceil(mo1) else mo1=math.floor(mo1) end
		if mo2-math.floor(mo2)>=0.5 then mo2=math.ceil(mo2) else mo2=math.floor(mo2) end
		if mo3-math.floor(mo3)>=0.5 then mo3=math.ceil(mo3) else mo3=math.floor(mo3) end
		if mo4-math.floor(mo4)>=0.5 then mo4=math.ceil(mo4) else mo4=math.floor(mo4) end
		text=text:gsub("(\\i?clip)%([%d%.]+,[%d%.]+,[%d%.]+,[%d%.]+","%1("..mo1..","..mo2..","..mo3..","..mo4)
		end
	    end
	    
	    if res.mod=="reverse move" then
		text=text:gsub("\\move%(([%d%.]+),([%d%.]+),([%d%.]+),([%d%.]+)","\\move(%3,%4,%1,%2")
	    end
	    
	line.text=text
        subs[i] = line
    end
end

function gui(subs, sel)
	dialog_config=
	{
	    {x=0,y=0,width=2,height=1,class="label",label="Position",},
	    {x=0,y=1,width=1,height=1,class="dropdown",name="posi",items={"Align X","Align Y"},value="Align X",},
	    {x=0,y=2,width=1,height=1,class="floatedit",name="pos",value=0},
	    {x=0,y=3,width=1,height=1,class="checkbox",name="first",label="use first line",value=false,},
	    
	    {x=2,y=0,width=2,height=1,class="label",label="Move"},
	    {x=2,y=1,width=1,height=1,class="dropdown",name="move",items={"transmove","horizontal","vertical"},value="transmove",},
	    {x=2,y=2,width=1,height=1,class="checkbox",name="keep",label="keep line 2",value=false,},
	    {x=2,y=3,width=3,height=1,class="checkbox",name="rot",label="rotation shortcut",
			hint="for transforms in 'transmove' mode",value=true,},
	    
	    {x=4,y=0,width=2,height=1,class="label",label="Modifications:",},
	    {x=4,y=1,width=2,height=1,class="dropdown",name="mod",items={"round numbers","reverse move"},value="round numbers"},
	    {x=4,y=2,width=1,height=1,class="label",label="Round:",},
	    {x=5,y=2,width=1,height=1,class="dropdown",name="rnd",items={"all","pos","move","org","clip"},value="all"},
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,
		{"Position","Move","Mod","Cancel"},{cancel='Cancel'})
	if pressed=="Cancel" then    aegisub.cancel() end
	
	if pressed=="Position" then    positron(subs, sel) end
	if pressed=="Move" then    moove(subs, sel) end
	if pressed=="Mod" then    modify(subs, sel) end
end

function posadjust(subs, sel)
    gui(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, posadjust)