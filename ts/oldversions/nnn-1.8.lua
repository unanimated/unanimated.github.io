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
script_version = "1.8"

--	SETTINGS	--	-- options are either numbers or true/false							[default value]

min_characters=0		-- minimum characters needed to insert a linebreak (ie no breaks in lines under X characters)	[42]
min_words=3			-- minimum words needed to insert a linebreak							[3]
put_break_in_the_middle=true	-- put a linebreak in the middle with the insert function if all else fails			[true]
middle_min_characters=40	-- minimum of characters needed to insert a linebreak in the middle				[45]
force_breaks_in_middle=false	-- force breaks in the middle of the line rather than after commas etc. (not recommended because stupid)
enable_shift_backwards=true	-- enables shifting backwards (adds a new item to the automation menu)				[false]
disable_dialog=false		-- if no break is placed with the insert function, a dialog lets you choose it manually.	[false]
allow_break_between_two=true	-- allow a break if there are only 2 words. good for TS, not much for editing (overrides min_ settings)	[false]
do_balance_checks=true		-- enable checking the ratio between top and bottom line (only for lines with over 4 words)	[true]
max_ratio=2.2			-- maximum ratio between top and bottom line allowed (if previous setting enabled)		[2.2]

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
	tags=text:match("^{\\[^}]-}")
	if tags==nil then tags="" end
	stekst=text:gsub("{[^\\}]-%s[^\\}]-}","")	:gsub("^{\\[^}]-}","")
	tekst=stekst

	-- count words
	wrd=0	for word in nocom:gmatch("[^%s]+") do wrd=wrd+1 end

	-- count commas [not at the end]
	com=0	for brk in nocom:gmatch("(, )") do com=com+1 end
	
	--aegisub.log("text - "..stekst)

	    -- put breaks after . , ? ! that are not at the end
	    tekst=tekst:gsub("([^%.])%.%s","%1. \\N")
	    :gsub("([^%.])%.({\\[^}]-})%s","%1.%2 \\N")
	    :gsub("([,!%?:])%s","%1 \\N")
	    :gsub("([,!%?:])({\\[^}]-})%s","%1%2 \\N")
	    :gsub(",\"%s",",\" \\N")
	    :gsub("%.%.%.%s","... \\N")
	    :gsub("([DM]r%.) \\N","%1 ")
	    --aegisub.log("\ntext "..tekst)

	    -- remove comma breaks if . or ? or !
	    if tekst:match("[%.%?!] \\N") and tekst:match(", \\N") then tekst=tekst:gsub(", \\N",", ") end
	    
	    -- remove breaks if there are more than one; leave the one closer to the centre, round 1
	    if tekst:match("\\N.+\\N") then repeat
		beforespace,afterspace=tekst:match("^(.-)\\N.*\\N(.-)$")	
		beforespace=beforespace:gsub("{[^}]-}","")	beforelength=beforespace:len()
		afterspace=afterspace:gsub("{[^}]-}","")	afterlength=afterspace:len()
		if beforelength>afterlength then tekst=tekst:gsub("^(.*)\\N(.-)$","%1%2") else tekst=tekst:gsub("^(.-)\\N","%1") end
	    until not tekst:match("\\N.+\\N") end

	    -- balance of lines - ratio check 1
	    if do_balance_checks and tekst:match("\\N") and not tekst:match("\\N%-") and wrd>4 then
		beforespace=tekst:match("^(.-)\\N")	beforespace=beforespace:gsub("{[^}]-}","")	beforelength=beforespace:len()
		afterspace=tekst:match("\\N(.-)$")	afterspace=afterspace:gsub("{[^}]-}","")	afterlength=afterspace:len()
		if beforelength>afterlength then ratio=beforelength/afterlength else ratio=afterlength/beforelength end
		difflength=math.abs(beforelength-afterlength)
		if ratio>max_ratio then tekst=tekst:gsub("\\N","") end
		if nocomlength>80 and ratio>(max_ratio*0.9) then tekst=tekst:gsub("\\N","") end
		-- aegisub.log("\nratio "..ratio)		aegisub.log("\ndifflength "..difflength)
	    end
	    
	    -- if breaks removed and there's a comma
	    if not tekst:match("\\N") then tekst=tekst:gsub(",%s",", \\N")	    :gsub(",({\\[^}]-})%s",",%1 \\N") end
	    if tekst:match("\\N.+\\N") then repeat
		beforespace,afterspace=tekst:match("^(.-)\\N.*\\N(.-)$")	
		beforespace=beforespace:gsub("{[^}]-}","")	beforelength=beforespace:len()
		afterspace=afterspace:gsub("{[^}]-}","")	afterlength=afterspace:len()
		if beforelength>afterlength then tekst=tekst:gsub("^(.*)\\N(.-)$","%1%2") else tekst=tekst:gsub("^(.-)\\N","%1") end
	    until not tekst:match("\\N.+\\N") end

	    -- if no linebreak in line, put breaks before but, and, if, because - unless they're the 2nd word
	    if not tekst:match("\\N") and wrd>4 then 
		if not tekst:match("^%a+,?%sbut ") then tekst=tekst:gsub(" but "," \\Nbut ") end
		if not tekst:match("^%a+,?%sand ") then tekst=tekst:gsub(" and "," \\Nand ") end
		if not tekst:match("^%a+,?%sif ") and not tekst:match("\\N") then tekst=tekst:gsub(" if "," \\Nif ")  end
		if not tekst:match("^%a+,?%swhen ") and not tekst:match("^%a+,?%s%a+[%s%p]when") then tekst=tekst:gsub(" when "," \\Nwhen ") end
		if not tekst:match("^%a+,?%sbecause ") then tekst=tekst:gsub(" because "," \\Nbecause ")  end
		if not tekst:match("^%a+,?%sunless ") and not tekst:match("\\N") then tekst=tekst:gsub(" unless "," \\Nunless ")  end
		if not tekst:match("^%a+,?%swith ") and not tekst:match("\\N") then tekst=tekst:gsub(" with "," \\Nwith ")  end
		if not tekst:match("^%a+,?%swithout ") and not tekst:match("\\N") then tekst=tekst:gsub(" without "," \\Nwithout ")  end
		if not tekst:match("^%a+,?%sor ") and not tekst:match("\\N") then tekst=tekst:gsub(" or "," \\Nor ")  end
		if not tekst:match("^%a+,?%snor ") and not tekst:match("\\N") then tekst=tekst:gsub(" nor "," \\Nnor ")  end
		if not tekst:match("^%a+,?%sfor ") and not tekst:match("\\N") then tekst=tekst:gsub(" for "," \\Nfor ")  end
		if not tekst:match("^%a+,?%sfrom ") and not tekst:match("\\N") then tekst=tekst:gsub(" from "," \\Nfrom ")  end
		if not tekst:match("^%a+,?%sat ") and not tekst:match("\\N") then tekst=tekst:gsub(" at "," \\Nat ")  end
		if not tekst:match("^%a+,?%sthat ") and not tekst:match("\\N") then tekst=tekst:gsub(" that "," \\Nthat ")  end
		if not tekst:match("^%a+,?%sbefore ") and not tekst:match("\\N") then tekst=tekst:gsub(" before "," \\Nbefore ")  end
		if not tekst:match("^%a+,?%ssince ") and not tekst:match("\\N") then tekst=tekst:gsub(" since "," \\Nsince ")  end
		if not tekst:match("^%a+,?%suntil ") and not tekst:match("\\N") then tekst=tekst:gsub(" until "," \\Nuntil ")  end
		if not tekst:match("^%a+,?%swhile ") and not tekst:match("\\N") then tekst=tekst:gsub(" while "," \\Nwhile ")  end
		if not tekst:match("^%a+,?%sinto ") and not tekst:match("\\N") then tekst=tekst:gsub(" into "," \\Ninto ")  end
		if not tekst:match("^%a+,?%sto ") and not tekst:match("\\N") then tekst=tekst:gsub(" to "," \\Nto ")  end
		if not tekst:match("^%a+,?%sis ") and not tekst:match("\\N") then tekst=tekst:gsub(" is "," \\Nis ")  end
		if not tekst:match("^%a+,?%swas ") and not tekst:match("\\N") then tekst=tekst:gsub(" was "," \\Nwas ")  end
		if not tekst:match("^%a+,?%sare ") and not tekst:match("\\N") then tekst=tekst:gsub(" are "," \\Nare ")  end
		if not tekst:match("^%a+,?%swere ") and not tekst:match("\\N") then tekst=tekst:gsub(" were "," \\Nwere ")  end
	    end
	    --aegisub.log("\ntext "..tekst)

	    -- remove breaks if there are more than one; leave the one closer to the centre, round 2
	    if tekst:match("\\N.+\\N") then repeat
		beforespace,afterspace=tekst:match("^(.-)\\N.*\\N(.-)$")	
		beforespace=beforespace:gsub("{[^}]-}","")	beforelength=beforespace:len()
		afterspace=afterspace:gsub("{[^}]-}","")	afterlength=afterspace:len()
		if beforelength>afterlength then tekst=tekst:gsub("^(.*)\\N(.-)$","%1%2") else tekst=tekst:gsub("^(.-)\\N","%1") end
	    until not tekst:match("\\N.+\\N") end
	    
	    -- balance of lines - ratio check 2
	    if do_balance_checks and tekst:match("\\N") and not tekst:match("\\N%-") and wrd>4 then
		beforespace=tekst:match("^(.-)\\N")	beforespace=beforespace:gsub("{[^}]-}","")	beforelength=beforespace:len()
		afterspace=tekst:match("\\N(.-)$")	afterspace=afterspace:gsub("{[^}]-}","")	afterlength=afterspace:len()
		if beforelength>afterlength then ratio=beforelength/afterlength else ratio=afterlength/beforelength end
		difflength=math.abs(beforelength-afterlength)
		--aegisub.log("\n ratio "..ratio)		aegisub.log("\ntekst "..tekst)		aegisub.log("\n l "..nocomlength)
		if ratio>max_ratio then tekst=tekst:gsub("\\N","") end
		if nocomlength>80 and ratio>(max_ratio*0.9) then tekst=tekst:gsub("\\N","") end
	    end
	    

	    -- insert break in the middle of the line
	    if force_breaks_in_middle then tekst=tekst:gsub("\\N","") end
	    if put_break_in_the_middle and nocomlength>=middle_min_characters and not tekst:match("\\N") then
		tekst="\\N"..tekst
		diff=250	stop=0
		while stop==0 do
		  last=tekst
		  repeat tekst=tekst:gsub("\\N({[^}]-})","%1\\N") tekst=tekst:gsub("\\N([^%s{}]+)","%1\\N")
		  until not tekst:match("\\N{[^}]-}") and not tekst:match("\\N([^%s{}]+)")
		  tekst=tekst:gsub("\\N%s"," \\N")
		  beforespace=tekst:match("^(.-)\\N")	beforelength=beforespace:len()
		  afterspace=tekst:match("\\N(.-)$")	afterlength=afterspace:len()
		  tdiff=math.abs(beforelength-afterlength)
		  if tdiff<diff then diff=tdiff else stop=1 tekst=last end
		end
	    end
	    
	    tekst=tekst
	    :gsub(" a \\N([%a\']+) "," \\Na %1 ")
	    :gsub(" an \\N([%a\']+) "," \\Nan %1 ")
	    :gsub(" by \\N([%a\']+) "," \\Nby %1 ")
	    :gsub(" I \\N([%a\']+) "," \\NI %1 ")
	    :gsub(" the \\N([%a\']+) "," \\Nthe %1 ")
	    :gsub(" for \\N([%a\']+) "," \\Nfor %1 ")
	    :gsub(" that \\N([%a\']+) "," \\Nthat %1 ")
	    :gsub(" (M[rs]%.) \\N([%a\']+) "," \\N%1 %2 ")
	    
	    :gsub(" ([oi][fn]) \\N([%a\']+) "," \\N%1 %2 ")
	    
	    --:gsub(" (%a%a) \\Nthe "," \\N%1 the ")
	    --:gsub(" (%a%a) \\Na "," \\N%1 a ")
	    
	    :gsub(" who \\N([%a\']+) "," \\Nwho %1 ")
	    :gsub(" to \\N([%a\']+) "," \\Nto %1 ")
	    :gsub(" out \\Nof "," \\Nout of ")
	    :gsub(" lot(s?) \\Nof "," lot%1 of \\N")
	    :gsub(" going \\Nto "," going to \\N")
	    :gsub(" have \\Nto "," have to \\N")
	    :gsub(" used \\Nto "," used to \\N")
	    :gsub(" supposed \\Nto "," supposed to \\N")
	    :gsub(" no \\None "," \\Nno one ")
	    :gsub(" as \\Nto "," \\Nas to ")
	    :gsub("^ ","")
	    if tekst:match(" so \\Nthat ") or tekst:match(" now \\Nthat ") then
		beforethat=tekst:match("^(.-)%a+ \\Nthat")	beforethat=beforethat:gsub("{[^}]-}","")	befrlgth=beforethat:len()
		afterthat=tekst:match("%a+ \\Nthat(.-)$")	afterthat=afterthat:gsub("{[^}]-}","")		afterlgth=afterthat:len()
		if befrlgth>afterlgth then tekst=tekst:gsub(" (%a+) \\Nthat "," \\N%1 that ") 
		else tekst=tekst:gsub(" (%a+) \\Nthat "," %1 that \\N") end
	    end
	    if tekst:match(" by %a+ing \\N") then
		beforethat=tekst:match("^(.-)by %a+ing \\N")	beforethat=beforethat:gsub("{[^}]-}","")	befrlgth=beforethat:len()
		afterthat=tekst:match("by %a+ing \\N(.-)$")	afterthat=afterthat:gsub("{[^}]-}","")		afterlgth=afterthat:len()
		if befrlgth>afterlgth then tekst=tekst:gsub(" (by %a+ing) \\N"," \\N%1 ") end
	    end

	    -- character/word restrictions
	    if nocomlength<min_characters or wrd<min_words then tekst=tekst:gsub("%s?\\N%s?"," ") end

	    -- break if there are only 2 words in the line
	    if wrd==2 and allow_break_between_two then tekst=tekst:gsub("(%w+%p?)%s(%w+%p?)%s?","%1 \\N%2") end

	-- apply changes
	stekst=escape(stekst)
	text=text:gsub(stekst,tekst)
	after=text:gsub("^{\\[^}]-}","")
	
	    -- GUI for manual breaking
	    if disable_dialog==false and not text:match("\\N") then
		dialog=
		{
		    {x=0,y=0,width=25,height=4,class="textbox",name="txt",value=after},
		    {x=0,y=4,width=25,height=1,class="label",label="Use 'Enter' to make linebreaks"},
		} 
		buttons={"OK","All spaces","Cancel"}
		pressed, res = aegisub.dialog.display(dialog,buttons,{cancel='Cancel'})
		if pressed=="OK" then
		res.txt=res.txt:gsub("\n","\\N") :gsub("\\N "," \\N")
		text=tags..res.txt
		end
		if pressed=="All spaces" then res.txt=res.txt:gsub("%s+"," \\N") text=tags..res.txt end
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
	text=text:gsub("([%a%p])\\N([%a%p])","%1 \\N%2") 
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
	text=text:gsub("([%a%p])\\N([%a%p])","%1 \\N%2") 
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