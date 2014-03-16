script_name = "Fax This"
script_description = "Fax This"
script_author = "unanimated"
script_version = "1.5"		-- added 'copy text'

include("karaskel.lua")

function fucks(subs, sel)
	for z, i in ipairs(sel) do
	    local l = subs[i]
	    if res["fay"]==false then
		l.text=l.text:gsub("\\fax[%d%.%-]-([\\}])","%1")
		if res["right"]==false then
		l.text="{\\fax" .. res["fax"] .. "}".. l.text
		else
		l.text="{\\fax" .. "-" .. res["fax"] .. "}".. l.text
		end
		l.text=l.text:gsub("^({\\[^}]-)}{\\","%1\\")
	    else
		l.text=l.text:gsub("\\fay[%d%.%-]-([\\}])","%1")
		if res["right"]==false then
		l.text="{\\fay" .. res["fax"] .. "}".. l.text
		else
		l.text="{\\fay" .. "-" .. res["fax"] .. "}".. l.text
		end
		l.text=l.text:gsub("^({\\[^}]-)}{\\","%1\\")
	    end	
	    subs[i] = l
	end
end

function blpha(subs, sel)
	local meta,styles=karaskel.collect_head(subs,false)
	zerocheck=0
	fadecheck=0
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
	    karaskel.preproc_line(sub,meta,styles,line)
		if line.text:match("\\fad%(") then
		fadin,fadout = line.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.inn .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout .."," .. line.duration-fadout+res.ut .. ",\\1a&HFF&)}")
		    end
		  if fadin=="0" and fadout=="0" then zerocheck=1 end
		else
		fadecheck=1
		end
	    line.text = text
	    subs[i] = line
	end
	if zerocheck==1 then aegisub.log("Some lines were skipped because they contain \\fad(0,0)")  end
	if fadecheck==1 then aegisub.log("Some lines were skipped because they don't contain \\fad")  end
end

function multimove(subs, sel)
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
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\move%(%1,%2,"..p1+m1..","..p2+m2..","..t.."%)")
		    else
		    text=text:gsub("\\pos%(([%d%.%-]+)%,([%d%.%-]+)%)","\\move(%1,%2,"..p1+m1..","..p2+m2..")")
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

function copytags(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	    if x==1  then
	      tags=text:match("^({\\[^}]*})")
	    end
	    if x~=1 then
	      if text:match("^({\\[^}]*})") then
	      text=text:gsub("^{\\[^}]*}",tags) else
	      text=tags..text
	      end
	    end
	    line.text = text
	    subs[i] = line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function copytext(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	    if x==1  then
	      tekst=text:gsub("^{\\[^}]*}","")
	    end
	    if x~=1 then
	      if text:match("^{\\[^}]*}") then
	      text=text:gsub("^({\\[^}]*}).*","%1"..tekst) else
	      text=tekst
	      end
	    end
	    line.text = text
	    subs[i] = line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function despace(txt) txt=txt:gsub("%s","_sp_") return txt end
function debreak(txt) txt=txt:gsub("\\N","_break_") return txt end

function splitbreak(subs, sel)
	for i=#sel,1,-1 do
	  line = subs[sel[i]]
	  text = subs[sel[i]].text
	    text=text:gsub("({[^}]-})",function (a) return debreak(a) end)
	    
	    if not text:match("\\N") then
	    pressed=aegisub.dialog.display({{class="label",
	    label="Selection line "..i.." has no \\N. \nSplit by spaces?",x=0,y=0,width=1,height=2}},{"Yes","No","Cancel"})
	      if pressed=="Cancel" then aegisub.cancel() end
	      if pressed=="Yes" then 
		line2=line
		    text=text:gsub("({[^\\}]-})",function (a) return despace(a) end)
		if text:match("^{\\") then				-- lines 2+, with initial tags
		    tags=text:match("^{(\\[^}]*)}")			-- initial tags
		    count=0
		    text=text:gsub("^({\\[^}]*})","%1 ")		-- add space
		    for aftern in text:gmatch("%s+([^%s]+)") do	-- part after \N [*]
		    aftern=aftern:gsub("_sp_"," ")
		    aftern=aftern:gsub("_break_","\\N")
		    count=count+1
		    line2.text="{"..tags.."}"..aftern			-- every new line = initial tags + part after one \N
		    --line2.effect=count
		    subs.insert(sel[i]+count,line2)			-- insert each match one line further
		    end
		else							-- lines 2+, without initial tags
		    count=0
		    text=" "..text
		    for aftern in text:gmatch("%s+([^%s]+)") do
		    aftern=aftern:gsub("_sp_"," ")
		    aftern=aftern:gsub("_break_","\\N")
		    count=count+1
		    line2.text=aftern
		    --line2.effect=count
		    subs.insert(sel[i]+count,line2)
		    end
		end
		subs.delete(sel[i])
	      end
	    end
	  
	    if text:match("\\N")then
	    line2=line
		if text:match("%*")then text=text:gsub("%*","_asterisk_") end
		if text:match("^{\\") then				-- lines 2+, with initial tags
		    tags=text:match("^{(\\[^}]*)}")			-- initial tags
		    count=0
		    text=text:gsub("\\N","*")				-- switch \N for *
		    for aftern in text:gmatch("%*%s*([^%*]*)") do	-- part after \N [*]
		    aftern=aftern:gsub("_break_","\\N")
		    count=count+1
		    line2.text="{"..tags.."}"..aftern			-- every new line = initial tags + part after one \N
		    --line2.effect=count+1
		    subs.insert(sel[i]+count,line2)			-- insert each match one line further
		    end
		else							-- lines 2+, without initial tags
		    count=0
		    text=text:gsub("\\N","*")
		    for aftern in text:gmatch("%*%s*([^%*]*)") do
		    aftern=aftern:gsub("_break_","\\N")
		    count=count+1
		    line2.text=aftern
		    subs.insert(sel[i]+count,line2)
		    end
		end
		if text:match("^{\\") then				-- line 1, with initial tags
		    text=text:gsub("^({\\[^}]-})(.-)%*(.*)","%1%2")
		    text=text:gsub("_break_","\\N")
		    --line.effect=1
		else							-- line 1, without initial tags
		    text=text:gsub("^(.-)%*(.*)","%1")
		    text=text:gsub("_break_","\\N")
		end
		text=text:gsub("_asterisk_","*")
		
	    line.text = text
	    subs[sel[i]] = line
	    end
	end
	aegisub.set_undo_point(script_name)
end

function konfig(subs, sel)
	dialog_config=
	{
	    {x=0,y=0,width=1,height=1,class="label",label="\\fax",},
	    {x=1,y=0,width=2,height=1,class="edit",name="fax",value="0.05"},
	    {x=1,y=1,width=1,height=1,class="checkbox",name="right",label="to the right",value=false},
	    {x=2,y=1,width=1,height=1,class="checkbox",name="fay",label="\\fay",value=false},
	    
	    {	x=4,y=0,width=2,height=1,class="label",label="bottom alpha in/out",},
	    {	x=4,y=1,width=1,height=1,class="dropdown",name="inn",items={"0","45","80","120"},value="45" },
	    {	x=5,y=1,width=1,height=1,class="dropdown",name="ut",items={"0","45","80","120"},value="45" },
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,
	{"fax it","multimove","bottom alpha","copy tags","copy text","split by \\N","cancel"},{cancel='cancel'})
	if pressed=="cancel" then aegisub.cancel() end
	if pressed=="fax it" then fucks(subs, sel) end
	if pressed=="bottom alpha" then blpha(subs, sel) end
	if pressed=="multimove" then multimove(subs, sel) end
	if pressed=="copy tags" then copytags(subs, sel) end
	if pressed=="copy text" then copytext(subs, sel) end
	if pressed=="split by \\N" then splitbreak(subs, sel) end
end

function fax_this(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, fax_this)