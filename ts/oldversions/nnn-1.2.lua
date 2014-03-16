script_name = "Insert Linebreak"
script_description = "insert linebreaks in suitable places if possible"	-- bind this to a single key under Subtitle Grid
script_author = "unanimated"
script_version = "1.2"

function escape(str)
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

function nnn(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text

	stekst=text:gsub("{[^}]-}","")
	tekst=stekst

	-- count words
	wrd=0	for word in stekst:gmatch("([%a\']+)[%s%p]") do wrd=wrd+1 end
	if stekst:match("%a$") then wrd=wrd+1 end

	-- count commas [not at the end]
	com=0	for brk in stekst:gmatch("(, )") do com=com+1 end
	
	if not tekst:match("\\N") then
	--aegisub.log("start"..com)

	    -- put breaks after . , ? ! that are not at the end, unless the line is 7 words or shorter
	    if wrd>7 then
	    tekst=tekst:gsub("([^%.])%.%s","%1. \\N")
	    tekst=tekst:gsub(",%s",", \\N")
	    tekst=tekst:gsub("%!%s","! \\N")
	    tekst=tekst:gsub("%?%s","? \\N")
	    tekst=tekst:gsub("%.\"%s",".\" \\N")
	    tekst=tekst:gsub(",\"%s",",\" \\N")
	    tekst=tekst:gsub("%.%.%.%s","... \\N")
	    end

	    if com==3 then tekst=tekst:gsub("\\N(.+\\N.+)\\N","%1") end

	    if com==4 then tekst=tekst:gsub("\\N(.+)\\N(.+\\N.+)\\N","%1%2") end

	    -- break if there are only 2 words in the line
	    if tekst:match("^%a+%s%a+%p?$") then tekst=tekst:gsub("(%a+)%s(%a+)","%1 \\N%2") end
	    if tekst:match("^{[^}]+}%w+%s%w+%p?$") then tekst=tekst:gsub("({[^}]+})(%w+)%s(%w+)","%1%2 \\N%3") end

	    -- remove comma breaks if . or ? or !
	    if tekst:match("%. \\N") and tekst:match(", \\N") then tekst=tekst:gsub(", \\N",", ") end
	    if tekst:match("%! \\N") and tekst:match(", \\N") then tekst=tekst:gsub(", \\N",", ") end
	    if tekst:match("%? \\N") and tekst:match(", \\N") then tekst=tekst:gsub(", \\N",", ") end

	    -- remove breaks from after first word of the line
	    tekst=tekst:gsub("^([%a\']+[%.,%?!]%s)\\N","%1")

	    -- remove breaks from after first 2 words if line has more than 9
	    if wrd>9 then tekst=tekst:gsub("^([%a\']+[%s%p][%a\']+[%.,%?!]%s)\\N","%1") end

	    -- remove breaks from before last word of the line
	    tekst=tekst:gsub(",%s\\N(%a+%p?)$",", %1")
	    tekst=tekst:gsub(",%s\\N(%a+%.%.%.)$",", %1")
	    tekst=tekst:gsub(",%s\\N(%a+%?!)$",", %1")

	    -- remove breaks from before last 2 words if line has more than 9
	    if wrd>9 then
	    tekst=tekst:gsub(",%s\\N(%a+%s%a+%p?)$",", %1")
	    tekst=tekst:gsub(",%s\\N(%a+%s%a+%.%.%.)$",", %1")
	    end

	    -- if no linebreak in line, put breaks before but, and, if, because - unless they're the 2nd word
	    if not tekst:match("\\N") and wrd>7 then 
		if not tekst:match("^%a+,?%sbut") then tekst=tekst:gsub(" but "," \\Nbut ") end
		if not tekst:match("^%a+,?%sand") then tekst=tekst:gsub(" and "," \\Nand ") end
		if not tekst:match("^%a+,?%sif") then tekst=tekst:gsub(" if "," \\Nif ")  end
		if not tekst:match("^%a+,?%swhen") and not tekst:match("^%a+,?%s%a+[%s%p]when") then tekst=tekst:gsub(" when "," \\Nwhen ") end
		if not tekst:match("^%a+,?%sbecause") then tekst=tekst:gsub(" because "," \\Nbecause ")  end
	    end

	    -- linebreak before to when suitable
	    if not tekst:match("\\N") and wrd>7 then 
		if not tekst:match("used to") and not tekst:match("going to") and not tekst:match("have to") and not tekst:match("^%a+%sto") 
		and not tekst:match("^%a+[%s%p]%a+[%s%p]to") and not tekst:match("to%s%a+%p?$") then
		tekst=tekst:gsub(" to "," \\Nto ")
		end
	    end

	    -- remove breaks near the beginning/end if there are 2 or more breaks
	    if tekst:match("^%a+,%s") and com>=2 then tekst=tekst:gsub("^(%a+),%s\\N","%1, ") end
	    if tekst:match("^%a+%s%a+,%s") and com>=2 then tekst=tekst:gsub("^(%a+%s%a+),%s\\N","%1, ") end
	    if tekst:match(",%s\\N%a+[%p]?$") and com>=2 then tekst=tekst:gsub(",%s\\N(%a+[%p]?)$",", %1") end

	    -- if there are 2 comma breaks, remove the first one
	    if com==2 then tekst=tekst:gsub("\\N(.+\\N)","%1") end

	    -- if there are still 2 breaks, remove first (or second if it's before last word)
	    repeat
	    if tekst:match("\\N.+\\N") then tekst=tekst:gsub("\\N(.+\\N)","%1") end
	    until tekst:match("\\N.+\\N")==nil

	stekst=escape(stekst)
	text=text:gsub(stekst,tekst)	

	line.text=text
	subs[i]=line
	end	    
    end
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, nnn)