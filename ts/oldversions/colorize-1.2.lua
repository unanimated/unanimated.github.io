--[[
 Alternates between 2-4 colours character by character, like 121212, 123123123, or 123412341234.
 Works for primary/border/shadow/secondary (only one of those).
 Nukes all comments and inline tags. Only first block of tags is kept.
 Shift can be used on an already colorized line to shift the colours by one letter.
 You have to set the right number of colours for it to work correctly.
 "Don't join with other tags" will keep {initial tags}{colour} separated (ie won't nuke the "}{"). 
 This helps some other scripts to keep the colour as part of the "text" without initial tags.
 "Continuous shift line by line" - If you select a bunch of the same colorized lines, this shifts the colours line by line.
 This kind of requires that no additional weird crap is done to the lines, otherwise malfunctioning can be expected.
--]]

script_name = "Colorize"
script_description = "Alternates between 2-4 colours"
script_author = "unanimated"
script_version = "1.2"

function colors(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=line.text
	
	    col1=res.c1:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col2=res.c2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col3=res.c3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col4=res.c4:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    
	    if res.kol=="primary" then k="\\c" text=text:gsub("\\1?c&H%x+&","") end
	    if res.kol=="border" then k="\\3c" text=text:gsub("\\3c&H%x+&","") end
	    if res.kol=="shadow" then k="\\4c" text=text:gsub("\\4c&H%x+&","") end
	    if res.kol=="secondary" then k="\\2c" text=text:gsub("\\2c&H%x+&","") end
	    
	    k1=k..col1
	    k2=k..col2
	    k3=k..col3
	    k4=k..col4
	    
	    tags=""
	    if text:match("^{\\[^}]*}") then tags=text:match("^({\\[^}]*})") end
	    text=text:gsub("{[^}]*}","")
	    text=text:gsub("%s*$","")
	    
	    if res.clrs=="2" then text=text:gsub("%s","  ") text=text.."*"
		text=text:gsub("([%w%p%s])([%w%p%s])","{"..k1.."}%1{"..k2.."}%2")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
	    end
	    
	    if res.clrs=="3" then text=text:gsub("%s","   ") text=text:gsub("\\N","~~~") text=text.."**"
		text=text:gsub("([%w%p%s])([%w%p%s])([%w%p%s])","{"..k1.."}%1{"..k2.."}%2{"..k3.."}%3")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
		text=text:gsub("{\\[1234]?c&H%x+&}~{\\[1234]?c&H%x+&}~{\\[1234]?c&H%x+&}~","\\N")
	    end
	    
	    if res.clrs=="4" then text=text:gsub("%s","    ") text=text:gsub("\\N","\\N\\N") text=text.."***"
		text=text:gsub("([%w%p%s])([%w%p%s])([%w%p%s])([%w%p%s])","{"..k1.."}%1{"..k2.."}%2{"..k3.."}%3{"..k4.."}%4")
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
	    end

	    text=text:gsub("{\\[1234]?c&H%x+&}%*","")
	    text=text:gsub("%*+$","")
	
	text=text:gsub("{\\[1234]?c&H%x+&}\\{\\[1234]?c&H%x+&}N","\\N")
	text=text:gsub("\\N\\N","\\N")
	text=tags..text
	if res.join==false then text=text:gsub("}{","") end
	line.text=text
        subs[i] = line
    end
end

function shift(subs, sel)
	klrs=tonumber(res.clrs)	-- how many colours we're dealing with
	count=1				-- start line counter
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=line.text

	    -- check if line looks colorized
	    if not text:match("{(\\[1234]?c)&H%x+&}[%w%p]$") then aegisub.dialog.display({{class="label",
		label="Line "..x.." does not \nappear to be colorized",x=0,y=0,width=1,height=2}},{"OK"}) aegisub.cancel()
	    end

	    -- determine which colour has been used to colorize - 1c, 2c, 3c, 4c
	    ctype=text:match("{(\\[1234]?c)&H%x+&}[%w%p]$")

	    -- this wasn't needed in the end but just in case
	    c1="{"..text:match("^{.-("..ctype.."&H%x+&)").."}"

	    -- get colours 2, 3, 4, and create sequences for shifting
	    a,c2,b,c3,c,c4=text:match("([%w%p]%s?)({"..ctype.."&H%x+&})([%w%p]%s?)({"..ctype.."&H%x+&})([%w%p]%s?)({"..ctype.."&H%x+&})")
	    if klrs==2 then first=c2 end
	    if klrs==3 then first=c3 second=c2 end
	    if klrs==4 then first=c4 second=c3 third=c2 end

	    -- don't run for 1st lines in sequences
	    if count>1 or not res.cont then

		-- separate first colour tag from other tags, save initial tags
		tags=""
		if text:match("^{\\[^}]*"..ctype.."&") then text=text:gsub("^({\\[^}]*)("..ctype.."&H%x+&)([^}]*})","%1%3{%2}") end
		if not text:match("^{\\[1234]?c&H%x+&}") then tags=text:match("^({\\[^}]*})") text=text:gsub("^{\\[^}]*}","") end

		-- shifting colours happens here
		switch=1
		repeat 
		text=text:gsub("({\\[1234]?c&H%x+&})([%w%p])","%2%1")
		text=text:gsub("({\\[1234]?c&H%x+&})(%s)","%2%1")
		text=text:gsub("({\\[1234]?c&H%x+&})(\\N)","%2%1")
		text=text:gsub("({\\[1234]?c&H%x+&})$","")
		text=first..text
		switch=switch+1
		if switch==2 then first=second end
		if switch==3 then first=third end
		until switch>=count

		text=tags..text
		if res.join==false then text=text:gsub("}{","") end
	    end

	-- line counter
	if res.cont then count=count+1 end
	if count>klrs then count=1 end
	line.text=text
        subs[i] = line
    end
end	

function colorize(subs, sel)
	dialog_config=
	{
	{x=0,y=0,width=1,height=1,class="label",label="Colours"},
	{x=1,y=0,width=1,height=1,class="dropdown",name="clrs",items={"2","3","4"},value="2"},
	{x=0,y=2,width=1,height=1,class="label",label="Apply to  "},
	{x=1,y=2,width=1,height=1,class="dropdown",name="kol",items={"primary","border","shadow","secondary"},value="primary"},
	    
	{x=2,y=0,width=1,height=1,class="label",label="  1"},
	{x=2,y=1,width=1,height=1,class="label",label="  2"},
	{x=2,y=2,width=1,height=1,class="label",label="  3"},
	{x=2,y=3,width=1,height=1,class="label",label="  4"},
	
	{x=4,y=0,width=1,height=1,class="color",name="c1" },
	{x=4,y=1,width=1,height=1,class="color",name="c2" },
	{x=4,y=2,width=1,height=1,class="color",name="c3" },
	{x=4,y=3,width=1,height=1,class="color",name="c4" },
	
	{x=0,y=3,width=2,height=1,class="checkbox",name="join",label="Don't join with other tags",value=false },
	{x=0,y=1,width=2,height=1,class="label",label="Use this ^ for Shift too."},
	{x=0,y=4,width=4,height=1,class="checkbox",name="cont",label="Continuous shift line by line",value=false },
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,{"Colorize","Shift","Cancel"},{cancel='Cancel'})
	if pressed=="Cancel" then    aegisub.cancel() end
	if pressed=="Colorize" then    colors(subs, sel) end
	if pressed=="Shift" then    shift(subs, sel) end
    
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, colorize)