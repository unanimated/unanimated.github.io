-- If you have several signs on the same screen, and the whole screen is moving, 
-- and you need to apply the same amount of \move to all signs, this is what you use.
-- Adjust \move on the first line, select lines so that the one with \move is the first, and the rest have \pos tags.
-- The script will change \pos tags to \move and calculate the coordinates from the first line.

script_name = "Multimove"
script_description = "Apply movement from one line to other lines with position tags"
script_author = "unanimated"
script_version = "1.1"

function move(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
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
		p1,p2=text:match("\\pos%(([%d%.]+)%,([%d%.]+)%)")
		    if t~=nil then
		    text=text:gsub("\\pos%(([%d%.]+)%,([%d%.]+)%)","\\move%(%1,%2,"..p1+m1..","..p2+m2..","..t.."%)")
		    else
		    text=text:gsub("\\pos%(([%d%.]+)%,([%d%.]+)%)","\\move(%1,%2,"..p1+m1..","..p2+m2..")")
		    end
		end
	    end
	    
	end
	    line.text = text
	    subs[i] = line
    end
	if poscheck==1 then aegisub.dialog.display({{class="label",
		label="Some lines are missing \\pos tags",x=0,y=0,width=1,height=2}},{"OK"}) end
	x1,y1,x2,y2,t,m1,m2=nil
	poscheck=0 
end

function multimove(subs, sel)
    move(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, multimove)