-- First function inserts a linebreak where it seems logical - after periods, commas, before "and," etc. If the line has one, it removes it.
--   This will not always produce the desired result, but mostly it works fairly well.
--   There's a limit for how unevenly a line can be split, so if it's over the ratio, it nukes the \N and goes to the next step.
--   If the stuff above didn't work out, a linebreak is inserted in the middle of the line if restrictions in settings allow it.
--   If it doesn't pass set restrictions, it opens a small GUI. Click where you want the break, hit enter, click OK.
--   The "All spaces" option is useful for typesetters when they want each word on a new line.
--   If there are inline tags/comments, only the GUI will work.
-- Second function puts a linebreak after the first word. Every new run of the function puts the linebreak one word further.
--   When it reaches the last word, it removes the break.
-- Third function shifts linebreaks back and is disabled by default.
-- You can bind each function to a different hotkey and combine them as needed.

script_name = "Line Breaker"
script_description = "insert/shift linebreaks"
script_author = "unanimated"
script_version = "1.6"

--	SETTINGS	--	-- all except min_words is true/false

min_characters=0		-- minimum characters needed to insert a linebreak (ie no breaks in lines under X characters)
min_words=2			-- minimum words needed to insert a linebreak
put_break_in_the_middle=true	-- put a linebreak in the middle with the insert function if all else fails
middle_min_characters=45	-- minimum of characters needed to insert a linebreak in the middle
force_breaks_in_middle=false	-- force breaks in the middle of the line rather than after commas etc. (not recommended because stupid)
enable_shift_backwards=false	-- enables shifting backwards (adds a new item to the automation menu)
disable_dialog=false		-- if no break is placed with the insert function, a dialog lets you choose it manually. this disables it.
allow_break_between_two=true	-- allow putting a break if there are only 2 words - good for TS, not so much for editing (overrides min_words)

--	--	--	--

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
	
	nocom=text:gsub("{[^}]-}","")	nocomlength=nocom:len()
	stekst=text:gsub("{[^}]-}","")
	tekst=stekst

	-- count words
	wrd=0	for word in nocom:gmatch("([%a\']+)[%s%p]") do wrd=wrd+1 end
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

	    -- remove comma breaks if . or ? or !
	    if tekst:match("%. \\N") and tekst:match(", \\N") then tekst=tekst:gsub(", \\N",", ") end
	    if tekst:match("%! \\N") and tekst:match(", \\N") then tekst=tekst:gsub(", \\N",", ") end
	    if tekst:match("%? \\N") and tekst:match(", \\N") then tekst=tekst:gsub(", \\N",", ") end

	    -- remove breaks from after first word of the line
	    if wrd>5 then tekst=tekst:gsub("^([%a\']+[%.,%?!]%s)\\N","%1") end

	    -- remove breaks from after first 2 words if line has more than 9
	    if wrd>9 then tekst=tekst:gsub("^([%a\']+[%s%p][%a\']+[%.,%?!]%s)\\N","%1") end

	    -- balance of lines - ratio check 1
	    if tekst:match("\\N") and wrd>5 then
		beforespace=tekst:match("^(.-)\\N")	beforelength=beforespace:len()
		afterspace=tekst:match("\\N(.-)$")	afterlength=afterspace:len()
		if beforelength>afterlength then ratio=beforelength/afterlength else ratio=afterlength/beforelength end
		difflength=math.abs(beforelength-afterlength)
		-- aegisub.log("\n"..tekst)
		if ratio>2.2 then tekst=tekst:gsub("\\N","") end
		-- aegisub.log("\nratio "..ratio)		aegisub.log("\ndifflength "..difflength)
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
		if not tekst:match("used to") and not tekst:match("going to") and not tekst:match("have to") 
		 and not tekst:match("supposed to") and not tekst:match("^%a+%sto") 
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
	    
	    -- balance of lines - ratio check 2
	    if tekst:match("\\N") and wrd>5 then
		beforespace=tekst:match("^(.-)\\N")	beforelength=beforespace:len()
		afterspace=tekst:match("\\N(.-)$")	afterlength=afterspace:len()
		if beforelength>afterlength then ratio=beforelength/afterlength else ratio=afterlength/beforelength end
		difflength=math.abs(beforelength-afterlength)
		-- aegisub.log("\n"..tekst)
		if ratio>2.2 then tekst=tekst:gsub("\\N","") end
		-- aegisub.log("\nratio "..ratio)		aegisub.log("\ndifflength "..difflength)
	    end
	    

	    -- insert break in the middle of the line
	    if force_breaks_in_middle then tekst=tekst:gsub("\\N","") end
	    if put_break_in_the_middle and nocomlength>=middle_min_characters and not tekst:match("\\N") then
		tekst="\\N"..tekst
		diff=150	stop=0
		while stop==0 do
		  last=tekst
		  repeat tekst=tekst:gsub("\\N({[^}]-})","%1\\N") tekst=tekst:gsub("\\N([^%s{}]+)","%1\\N")
		  until not tekst:match("\\N{[^}]-}") and not tekst:match("\\N([^%s{}]+)")
		  tekst=tekst:gsub("\\N%s"," \\N")
		  beforespace=tekst:match("^(.-)\\N")	beforelength=beforespace:len()
		  afterspace=tekst:match("\\N(.-)$")	afterlength=afterspace:len()
		  tdiff=math.abs(beforelength-afterlength)
		  if tdiff<diff then diff=tdiff else stop=1 tekst=last end	--aegisub.log("\ntekst "..tekst)
		end
	    end

	    -- character/word restrictions
	    if nocomlength<min_characters or wrd<min_words then text=text:gsub("%s?\\[Nn]%s?"," ") end
	    
	    -- break if there are only 2 words in the line
	    if wrd==2 and allow_break_between_two then tekst=tekst:gsub("(%w+%p?)%s(%w+%p?)%s?","%1 \\N%2") end

	-- apply changes
	stekst=escape(stekst)
	text=text:gsub(stekst,tekst)
	
	    -- GUI for manual breaking
	    if disable_dialog==false and not text:match("\\N") then
		dialog=
		{
		    {x=0,y=0,width=25,height=4,class="textbox",name="txt",value=text},
		    {x=0,y=4,width=25,height=1,class="label",label="Use 'Enter' to make linebreaks"},
		} 
		buttons={"OK","All spaces","Cancel"}
		pressed, res = aegisub.dialog.display(dialog,buttons,{cancel='Cancel'})
		if pressed=="OK" then
		res.txt=res.txt:gsub("\n","\\N") :gsub("\\N "," \\N")
		text=res.txt
		end
		if pressed=="All spaces" then res.txt=res.txt:gsub("%s","\\N") text=res.txt end
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
	    if not text:match("\\N") then text="\\N"..text end
		text=text:gsub("\\N([^%s{}]+%s?)$","%1")		-- end
		text=text:gsub("\\N([^%s{}]+%s?{[^}]-}%s?)$","%1") 	-- end
		text=text:gsub("\\N%s"," \\N")
		repeat text=text:gsub("\\N({[^}]-})","%1\\N") text=text:gsub("\\N([^%s{}]+)","%1\\N")
		until not text:match("\\N{[^}]-}") and not text:match("\\N([^%s{}]+)")
		text=text:gsub("\\N%s"," \\N")
		text=text:gsub("\\N$","")
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end	

function backshift(subs, sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	    if not text:match("\\N") then text=text.."\\N" end
		text=text:gsub("^({[^}]-}%s?[^%s{}]+%s?)\\N","%1")	-- start
		text=text:gsub("^([^%s{}]+%s?)\\N","%1")		-- start
		text=text:gsub("%s\\N","\\N ")
		repeat text=text:gsub("({[^}]-})\\N","\\N%1") text=text:gsub("([^%s{}]+)\\N","\\N%1")
		until not text:match("({[^}]-})\\N") and not text:match("([^%s{}]+)\\N")
		text=text:gsub("^\\N","")
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end	

aegisub.register_macro("Insert Linebreak", script_description, nnn)
aegisub.register_macro("Shift Linebreak", script_description, nshift)
if enable_shift_backwards then aegisub.register_macro("Shift Linebreak Back", script_description, backshift) end