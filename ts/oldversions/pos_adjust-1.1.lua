-- Position: Align X means all selected \pos tags will have the same given X coordinate. Same with Align Y for Y.
--   useful for multiple signs on screen that need to be aligned horizontally/vertically or mocha signs that should move horizontally/vertically.
-- Move: horizontal means y2 will be the same as y1 so that the sign moves in a straight horizontal manner. Same principle for vertical.
-- Modifications: 'round numbers' rounds coordinates for pos, move, org and clip depending on the 'Round' submenu.
--   'reverse move' reverses the direction of \move.

script_name = "Position Adjuster"
script_description = "Does things and stuff"
script_author = "unanimated"
script_version = "1.1"

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
	    {x=2,y=1,width=1,height=1,class="dropdown",name="move",items={"horizontal","vertical"},value="horizontal",},
	    
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