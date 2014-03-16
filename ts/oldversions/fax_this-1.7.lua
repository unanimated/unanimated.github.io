-- multimove takes \move from first selected line and applies it to the other lines (if they have \pos)
-- all the "copy" things copy things from first selected line and paste them to the other lines
-- clip shift coordinates will shift the clip by that amount each line

script_name="Copyfax This"
script_description="Copyfax This"
script_author="unanimated"
script_version="1.7"

copy_style=true

function fucks(subs, sel)
	for z, i in ipairs(sel) do
	    local l=subs[i]
	    if res["fay"]==false then
		l.text=l.text:gsub("\\fax[%d%.%-]-([\\}])","%1")	:gsub("{}","")
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
	    subs[i]=l
	end
end

function multimove(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
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
	    line.text=text
	    subs[i]=line
    end
	if poscheck==1 then aegisub.dialog.display({{class="label",
		label="Some lines are missing \\pos tags",x=0,y=0,width=1,height=2}},{"OK"}) end
	x1,y1,x2,y2,t,m1,m2=nil
	poscheck=0 
end

function copytags(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	    if x==1  then
	      tags=text:match("^({\\[^}]*})")
	      if res.cpstyle then style=line.style end
	    end
	    if x~=1 then
	      if text:match("^({\\[^}]*})") then
	      text=text:gsub("^{\\[^}]*}",tags) else
	      text=tags..text
	      end
	      if res.cpstyle then line.style=style end
	    end
	    line.text=text
	    subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function copytext(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	    if x==1  then
	      tekst=text:gsub("^{\\[^}]*}","")
	    end
	    if x~=1 then
	      if text:match("^{\\[^}]*}") then
	      text=text:gsub("^({\\[^}]*}).*","%1"..tekst) else
	      text=tekst
	      end
	    end
	    line.text=text
	    subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function copyclip(subs, sel)
	xc=res.xlip
	yc=res.ylip
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	    if x==1  then
	      if text:match("\\i?clip") then -- read clip
	      klipstart=text:match("\\i?clip%(([^%)]+)%)")
	      end
	    end
	    
	    if x~=1 then
	      if not text:match("^{\\") then text="{\\}"..text end
	      if not text:match("\\i?clip") then text=addtag("\\clip()",text) end
	      
		-- calculations
		if xc~=0 and yc~=0 then factor=x-1
		    klip=klipstart:gsub("([%d%.%-]+),([%d%.%-]+),([%d%.%-]+),([%d%.%-]+)",
		    function(a,b,c,d) return a+xc*factor.. "," ..b+yc*factor.. "," ..c+xc*factor.. "," ..d+yc*factor end)
		    
		    if klipstart:match("m [%d%a%s%-]+") then
		    klip=klipstart:match("m ([%d%a%s%-]+)")
		    klip2=klip:gsub("([%d%-]+)%s([%d%-]+)",function(a,b) return a+xc*factor.." "..b+yc*factor end)
		    klip=klip:gsub("%-","%%-")
		    klip=klip:gsub(klip,klip2)
		    klip="m "..klip
		    end
		end
	      -- set clip
	      text=text:gsub("(\\i?clip)%([^%)]-%)","%1("..klip..")")
	      text=text:gsub("\\\\","\\")
	    end
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function copycolours(subs, sel)
if not res.c1 and not res.c2 and not res.c3 and not res.c4 then aegisub.cancel() end
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	styleref=stylechk(subs,line.style)
	sr=styleref
	text=text:gsub("\\1c","\\c")
	
	    -- copy from line 1
	    if x==1  then
	      if res.c1 then
	        if text:match("\\c&") then col1=text:match("\\c(&H%x+&)") 
		else col1=sr.color1:gsub("H%x%x","H") end
	      end
	      if res.c3 then
	        if text:match("\\3c&") then col3=text:match("\\3c(&H%x+&)") 
		else col3=sr.color3:gsub("H%x%x","H") end
	      end
	      if res.c4 then
	        if text:match("\\4c&") then col4=text:match("\\4c(&H%x+&)") 
		else col4=sr.color4:gsub("H%x%x","H") end
	      end
	      if res.c2 then
	        if text:match("\\2c&") then col2=text:match("\\2c(&H%x+&)") 
		else col2=sr.color2:gsub("H%x%x","H") end
	      end
	    end

	    -- paste to other liens
	    if x~=1 then if not text:match("^{\\") then text=text:gsub("^","{\\}") end
	      if res.c1 then
	        if text:match("\\c&") then text=text:gsub("\\c(&H%x+&)","\\c"..col1)
		else text=addtag("\\c"..col1,text) end
	      end
	      if res.c3 then
	        if text:match("\\3c&") then text=text:gsub("\\3c(&H%x+&)","\\3c"..col3)
		else text=addtag("\\3c"..col3,text) end
	      end
	      if res.c4 then
	        if text:match("\\4c&") then text=text:gsub("\\4c(&H%x+&)","\\4c"..col4)
		else text=addtag("\\4c"..col4,text) end
	      end
	      if res.c2 then
	        if text:match("\\2c&") then text=text:gsub("\\2c(&H%x+&)","\\2c"..col2)
		else text=addtag("\\2c"..col2,text) end
	      end
	    end
	    
	text=text:gsub("\\\\","\\")
	text=text:gsub("\\}","}")
	text=text:gsub("{}","")
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function addtag(tag,text) text=text:gsub("^({\\[^}]-)}","%1"..tag.."}") return text end
function despace(txt) txt=txt:gsub("%s","_sp_") return txt end
function debreak(txt) txt=txt:gsub("\\N","_break_") return txt end

function splitbreak(subs, sel)		-- 1.3
	for i=#sel,1,-1 do
	  line=subs[sel[i]]
	  text=subs[sel[i]].text
	    text=text:gsub("({[^}]-})",function (a) return debreak(a) end)
	    
	    if not text:match("\\N") then
	    pressed=aegisub.dialog.display({{class="label",
	    label="Selection line "..i.." has no \\N. \nSplit by spaces?",x=0,y=0,width=1,height=2}},{"Yes","No","Cancel"})
	      if pressed=="Cancel" then aegisub.cancel() end
	      
	      -- split by spaces
	      if pressed=="Yes" then 
		line2=line
		    text=text:gsub("({[^\\}]-})",function (a) return despace(a) end)
		if text:match("^{\\") then				-- lines 2+, with initial tags
		    tags=text:match("^({\\[^}]*})")			-- initial tags
		    if tags==nil then tags="" end
		    count=0
		    text=text:gsub("^({\\[^}]*})","%1 ")		-- add space
		    for aftern in text:gmatch("%s+([^%s]+)") do	-- part after \N [*]
		     aftern=aftern:gsub("_sp_"," ")
		      aftern=aftern:gsub("_break_","\\N")
		      count=count+1
		      line2.text=tags..aftern			-- every new line=initial tags + part after one \N
		      --line2.effect=count
		      line2.text=line2.text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
		      line2.text=duplikill(line2.text)
		      tags=line2.text:match("^({\\[^}]*})")
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
	  
	    -- split by \N
	    if text:match("\\N")then
	    line2=line
		if text:match("%*")then text=text:gsub("%*","_asterisk_") end
		if text:match("^{\\") then				-- lines 2+, with initial tags
		    tags=text:match("^({\\[^}]*})")			-- initial tags
		    tags2=""
		    count=0
		    text=text:gsub("\\N","*")				-- switch \N for *
		    for aftern in text:gmatch("%*%s*([^%*]*)") do	-- part after \N [*]
		      aftern=aftern:gsub("_break_","\\N")	:gsub("%s*$","")
		      if aftern~="" then
		        count=count+1
		        line2.text=tags..aftern				-- every new line=initial tags + part after one \N
		        --line2.effect=count+1
		        line2.text=line2.text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
		        line2.text=duplikill(line2.text)
		        tags=line2.text:match("^({\\[^}]*})")
		        subs.insert(sel[i]+count,line2)		-- insert each match one line further 
		      end
		    end
		else							-- lines 2+, without initial tags
		    count=0
		    text=text:gsub("\\N","*")
		    for aftern in text:gmatch("%*%s*([^%*]*)") do
		      aftern=aftern:gsub("_break_","\\N")	:gsub("%s*$","")
		      if aftern~="" then
		        count=count+1
		        line2.text=aftern
		        subs.insert(sel[i]+count,line2)
		      end
		    end
		end
		if text:match("^{\\") then				-- line 1, with initial tags
		    text=text:gsub("^({\\[^}]-})(.-)%*(.*)","%1%2")
		    text=text:gsub("_break_","\\N")	:gsub("%s*$","")
		    --line.effect=1
		else							-- line 1, without initial tags
		    text=text:gsub("^(.-)%*(.*)","%1")
		    text=text:gsub("_break_","\\N")	:gsub("%s*$","")
		end
		text=text:gsub("_asterisk_","*")
		
	    line.text=text
	    subs[sel[i]]=line
	    end
	end
	aegisub.set_undo_point(script_name)
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
	    tag=tags2[i]
	    text=text:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%1%2")
	end	
	return text
end

function stylechk(subs,stylename)
  for i=1, #subs do
    if subs[i].class=="style" then
      local st=subs[i]
      if stylename==st.name then styleref=st end
    end
  end
  return styleref
end

function konfig(subs, sel)
	if lastfax==nil then lastfax="0.05" end
	if lastxlip==nil then lastxlip=0 end
	if lastylip==nil then lastylip=0 end
	dialog_config=
	{
	    {x=0,y=0,width=1,height=1,class="label",label="\\fax",},
	    {x=1,y=0,width=1,height=1,class="edit",name="fax",value=lastfax},
	    {x=0,y=1,width=1,height=1,class="checkbox",name="fay",label="\\fay",value=false},
	    {x=1,y=1,width=1,height=1,class="checkbox",name="right",label="to the right",value=false},
	    
	    {x=2,y=0,width=2,height=1,class="checkbox",name="cpstyle",label="copy style with tags",value=copy_style},
	    
	    {x=4,y=0,width=1,height=1,class="label",label="  copy colours:  ",},
	    {x=5,y=0,width=1,height=1,class="checkbox",name="c1",label="c",value=false},
	    {x=6,y=0,width=1,height=1,class="checkbox",name="c3",label="3c ",value=false},
	    {x=7,y=0,width=1,height=1,class="checkbox",name="c4",label="4c  ",value=false},
	    {x=8,y=0,width=1,height=1,class="checkbox",name="c2",label="2c",value=false},
	    
	    {x=2,y=1,width=1,height=1,class="label",label="shift clip every frame by:",},
	    {x=4,y=1,width=2,height=1,class="floatedit",name="xlip",value=lastxlip},
	    {x=6,y=1,width=3,height=1,class="floatedit",name="ylip",value=lastylip},
	    
	    --{	x=4,y=1,width=1,height=1,class="dropdown",name="inn",items={"0","45","80","120"},value="45" },
	    --{	x=5,y=1,width=1,height=1,class="dropdown",name="ut",items={"0","45","80","120"},value="45" },
	} 	
	pressed, res=aegisub.dialog.display(dialog_config,
	{"fax it","multimove","copy tags","copy text","copy clip","copy colours","split by \\N","cancel"},{cancel='cancel'})
	if pressed=="cancel" then aegisub.cancel() end
	if pressed=="fax it" then fucks(subs, sel) end
	if pressed=="multimove" then multimove(subs, sel) end
	if pressed=="copy tags" then copytags(subs, sel) end
	if pressed=="copy text" then copytext(subs, sel) end
	if pressed=="copy clip" then copyclip(subs, sel) end
	if pressed=="copy colours" then copycolours(subs, sel) end
	if pressed=="split by \\N" then splitbreak(subs, sel) end
	lastfax=res.fax
	lastxlip=res.xlip
	lastylip=res.ylip
end

function fax_this(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, fax_this)