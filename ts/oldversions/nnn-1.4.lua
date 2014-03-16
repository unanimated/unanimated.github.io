-- First function inserts a linebreak where it seems logical - after periods, commas, before "and," etc. If the line has one, it removes it.
--   This will not always produce the desired result, but mostly it works fairly well.
--   If it can't find any suitable place, it opens a small GUI. Click where you want the break, hit enter, click OK.
--   The "All spaces" option is useful for typesetters when they want each word on a new line.
-- Second function puts a linebreak after the first word. Every new run of the function puts the linebreak one word further.
--   When it reaches the last word, it removes the break.
-- You can bind each function to a different hotkey and combine them as needed.

script_name = "Insert Linebreak"
script_description = "insert linebreaks in suitable places if possible"
script_author = "unanimated"
script_version = "1.4"

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

	-- remove linebreak if there is one
	if text:match("\\N") then
	text=text:gsub("%s?\\[Nn]%s?"," ") 
	else
	
	text=text:gsub("([%.,%?!])%s$","%1") 
	
	stekst=text:gsub("{[^}]-}","")
	tekst=stekst

	-- count words
	wrd=0	for word in stekst:gmatch("([%a\']+)[%s%p]") do wrd=wrd+1 end
	if stekst:match("%a$") then wrd=wrd+1 end

	-- count commas [not at the end]
	com=0	for brk in stekst:gmatch("(, )") do com=com+1 end
	
	
	--aegisub.log("text - "..tekst)

	    -- put breaks after . , ? ! that are not at the end
	    tekst=tekst:gsub("([^%.])%.%s","%1. \\N")
	    tekst=tekst:gsub(",%s",", \\N")
	    tekst=tekst:gsub("%!%s","! \\N")
	    tekst=tekst:gsub("%?%s","? \\N")
	    tekst=tekst:gsub(":%s",": \\N")
	    tekst=tekst:gsub("%.\"%s",".\" \\N")
	    tekst=tekst:gsub(",\"%s",",\" \\N")
	    tekst=tekst:gsub("%.%.%.%s","... \\N")

	    if com==3 then tekst=tekst:gsub("\\N(.+\\N.+)\\N","%1") end

	    if com==4 then tekst=tekst:gsub("\\N(.+)\\N(.+\\N.+)\\N","%1%2") end

	    -- break if there are only 2 words in the line
	    if wrd==2 then tekst=tekst:gsub("(%w+%p?)%s(%w+%p?)%s?","%1 \\N%2") end

	    -- remove comma breaks if . or ? or !
	    if tekst:match("%. \\N") and tekst:match(", \\N") then tekst=tekst:gsub(", \\N",", ") end
	    if tekst:match("%! \\N") and tekst:match(", \\N") then tekst=tekst:gsub(", \\N",", ") end
	    if tekst:match("%? \\N") and tekst:match(", \\N") then tekst=tekst:gsub(", \\N",", ") end

	    -- remove breaks from after first word of the line
	    if wrd>5 then tekst=tekst:gsub("^([%a\']+[%.,%?!]%s)\\N","%1") end

	    -- remove breaks from after first 2 words if line has more than 9
	    if wrd>9 then tekst=tekst:gsub("^([%a\']+[%s%p][%a\']+[%.,%?!]%s)\\N","%1") end

	    -- remove breaks from before last word of the line
	    if wrd>5 then
	    tekst=tekst:gsub("([%.,%?!])%s\\N(%a+%p?)$","%1 %2")
	    tekst=tekst:gsub("([%.,%?!])%s\\N(%a+%.%.%.)$","%1 %2")
	    tekst=tekst:gsub("([%.,%?!])%s\\N(%a+%?!)$","%1 %2")
	    end

	    -- remove breaks from before last 2 words if line has more than 9
	    if wrd>9 then
	    tekst=tekst:gsub(",%s\\N(%a+%s%a+%p?)$",", %1")
	    tekst=tekst:gsub(",%s\\N(%a+%s%a+%.%.%.)$",", %1")
	    end

	    -- if no linebreak in line, put breaks before but, and, if, because - unless they're the 2nd word
	    if not tekst:match("\\N") and wrd>7 then 
		if not tekst:match("^%a+,?%sbut") then tekst=tekst:gsub(" but "," \\Nbut ") end
		if not tekst:match("^%a+,?%sand") then tekst=tekst:gsub(" and "," \\Nand ") end
		if not tekst:match("^%a+,?%sif") and not tekst:match("\\N") then tekst=tekst:gsub(" if "," \\Nif ")  end
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
	
	    if not text:match("\\N") then
	    
		dialog=
		{
		    {x=0,y=0,width=25,height=4,class="textbox",name="txt",value=text},
		    {x=0,y=4,width=25,height=1,class="label",label="Use 'Enter' to make linebreaks"},
		} 
		buttons={"OK","All spaces","Cancel"}
		pressed, res = aegisub.dialog.display(dialog,buttons,{cancel='Cancel'})
		if pressed=="OK" then
		res.txt=res.txt:gsub("\n","\\N")
		res.txt=res.txt:gsub("\\N "," \\N")
		text=res.txt
		end
		if pressed=="All spaces" then
		res.txt=res.txt:gsub("%s","\\N")
		text=res.txt
		end
	
	    end
	
	end	    

	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function nshift(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	    if not text:match("\\N") then
		if text:match("^{") then 
		    text=text:gsub("^({[^}]-}%s?)","%1\\N") 
		    text=text:gsub("\\N([%w%-\'\"]+%p?%p?%p?)$","%1")
		    text=text:gsub("\\N([%w%-\'\"]+%p?%p?%p?%s)","%1\\N") 
		end
		text=text:gsub("^([%w%-\'\"]+%p?%p?%p?%s)","%1\\N")
	    else
		text=text:gsub("\\N([%w%-\'\"]+%p?%p?%p?)$","%1")
		text=text:gsub("\\N([%w%-\'\"]+%p?%p?%p?{[^}]-})$","%1")
		text=text:gsub("\\N({[^}]-}%s?)","%1\\N")
		text=text:gsub("\\N([%w%-\'\"]+%p?%p?%p?%s)","%1\\N")
		text=text:gsub("\\N([%w%-\'\"]+%p?%p?%p?{[^}]-}%p?%p?%p?%s?)","%1\\N")
	    end
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end	

aegisub.register_macro(script_name, script_description, nnn)
aegisub.register_macro("Shift Linebreak", script_description, nshift)