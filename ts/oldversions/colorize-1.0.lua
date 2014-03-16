-- Alternates betwen 2-4 colours character by character, like 121212, 123123123, or 123412341234.
-- Works for primary/border/shadow/secondary (only one of those).
-- Nukes all comments and inline tags. Only first block of tags is kept.

script_name = "Colorize"
script_description = "Alternates between 2-4 colours"
script_author = "unanimated"
script_version = "1.0"

function colors(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=line.text
	
	    col1=res.c1:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col2=res.c2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col3=res.c3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col4=res.c4:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    
	    if res.kol=="primary" then k="\\c" end
	    if res.kol=="border" then k="\\3c" end
	    if res.kol=="shadow" then k="\\4c" end
	    if res.kol=="secondary" then k="\\2c" end
	    
	    kcol1=k..col1
	    kcol2=k..col2
	    kcol3=k..col3
	    kcol4=k..col4
	    
	    tags=""
	    if text:match("^{\\[^}]*}") then tags=text:match("^({\\[^}]*})") end
	    text=text:gsub("{[^}]*}","")
	    text=text:gsub("%s*$","")
	    
	    if res.clrs=="2" then text=text:gsub("%s","  ")
		text=text:gsub("([%w%p%s])([%w%p%s])","{"..kcol1.."}%1{"..kcol2.."}%2")
		if text:match("[^}][%w%p]$") then text=text:gsub("([%w%p])$","{"..kcol1.."}%1") end
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
	    end
	    
	    if res.clrs=="3" then text=text:gsub("%s","   ")
		text=text:gsub("([%w%p%s])([%w%p%s])([%w%p%s])","{"..kcol1.."}%1{"..kcol2.."}%2{"..kcol3.."}%3")
		if text:match("[^}][^}][%w%p]$") then text=text:gsub("([^}])([%w%p])$","{"..kcol1.."}%1{"..kcol2.."}%2") end
		if text:match("[^}][%w%p]$") then text=text:gsub("([%w%p])$","{"..kcol1.."}%1") end
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
	    end
	    
	    if res.clrs=="4" then text=text:gsub("%s","    ")
		text=text:gsub("([%w%p%s])([%w%p%s])([%w%p%s])([%w%p%s])","{"..kcol1.."}%1{"..kcol2.."}%2{"..kcol3.."}%3{"..kcol4.."}%4")
		if text:match("[^}][^}][^}][%w%p]$") then 
			text=text:gsub("([^}])([^}])([%w%p])$","{"..kcol1.."}%1{"..kcol2.."}%2{"..kcol3.."}%3") end
		if text:match("[^}][^}][%w%p]$") then text=text:gsub("([^}])([%w%p])$","{"..kcol1.."}%1{"..kcol2.."}%2") end
		if text:match("[^}][%w%p]$") then text=text:gsub("([%w%p])$","{"..kcol1.."}%1") end
		text=text:gsub("{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s{\\[1234]?c&H%x+&}%s"," ")
	    end
	
	text=text:gsub("{\\[1234]?c&H%x+&}\\{\\[1234]?c&H%x+&}N","\\N")
	text=tags..text
	text=text:gsub("}{","")
	line.text=text
        subs[i] = line
    end
end

function colorize(subs, sel)
	dialog_config=
	{
	{x=0,y=0,width=2,height=1,class="label",label="Colours"},
	{x=0,y=1,width=2,height=1,class="dropdown",name="clrs",items={"2","3","4"},value="2"},
	{x=0,y=2,width=2,height=1,class="label",label="Apply to"},
	{x=0,y=3,width=2,height=1,class="dropdown",name="kol",items={"primary","border","shadow","secondary"},value="primary"},
	    
	{x=2,y=0,width=1,height=1,class="label",label="1"},
	{x=2,y=1,width=1,height=1,class="label",label="2"},
	{x=2,y=2,width=1,height=1,class="label",label="3"},
	{x=2,y=3,width=1,height=1,class="label",label="4"},
	
	{x=3,y=0,width=1,height=1,class="color",name="c1" },
	{x=3,y=1,width=1,height=1,class="color",name="c2" },
	{x=3,y=2,width=1,height=1,class="color",name="c3" },
	{x=3,y=3,width=1,height=1,class="color",name="c4" },
	} 	
	pressed, res = aegisub.dialog.display(dialog_config,{"Colorize","Cancel"},{cancel='Cancel'})
	if pressed=="Cancel" then    aegisub.cancel() end
	if pressed=="Colorize" then    colors(subs, sel) end
    
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, colorize)