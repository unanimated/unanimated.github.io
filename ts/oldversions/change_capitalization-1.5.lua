-- Capitalize text or make it lowercase / uppercase. Select lines, run the script, choose from the 4 options.

script_name = "Change capitalization"
script_description = "Capitalizes text or makes it lowercase or uppercase"
script_author = "unanimated"
script_version = "1.5"

function lowercase(subs, sel)
    for x, i in ipairs(sel) do
            local line = subs[i]
	    local text = subs[i].text
	    text = text:gsub("\\n","small_break")
	    text = text:gsub("\\N","large_break")
	    text = text:gsub("\\h","hard_space")
	    text = text:gsub("^([^{]*)", function (l) return l:lower() end)
	    text = text:gsub("}([^{]*)", function (l) return "}"..l:lower() end)
	    text = text:gsub("small_break","\\n")
	    text = text:gsub("large_break","\\N")
	    text = text:gsub("hard_space","\\h")
	    line.text = text
	    subs[i] = line 
    end
end

function uppercase(subs, sel)
    for x, i in ipairs(sel) do
            local line = subs[i]
	    local text = subs[i].text
	    text = text:gsub("\\n","SMALL_BREAK")
	    text = text:gsub("\\N","LARGE_BREAK")
	    text = text:gsub("\\h","HARD_SPACE")
	    text = text:gsub("^([^{]*)", function (u) return u:upper() end)
	    text = text:gsub("}([^{]*)", function (u) return "}"..u:upper() end)
	    text = text:gsub("SMALL_BREAK","\\n")
	    text = text:gsub("LARGE_BREAK","\\N")
	    text = text:gsub("HARD_SPACE","\\h")
	    line.text = text
	    subs[i] = line 
    end
end

function capitalines(subs, sel)
    for x, i in ipairs(sel) do
            local line = subs[i]
	    local text = subs[i].text
	    text = text:gsub("^(%l)([^{]-)", function (c,d) return c:upper()..d end)
	    text = text:gsub("^({[^}]-})(%l)([^{]-)", function (e,f,g) return e..f:upper()..g end)
	    text = text:gsub(" i "," I ")
	    text = text:gsub(" i\'"," I'")
	    text = text:gsub("\\Ni ","\\NI ")
	    text = text:gsub("\\Ni\'","\\NI'")
	    line.text = text
	    subs[i] = line 
    end
end

function capitalize(subs, sel)
    for x, i in ipairs(sel) do
            local line = subs[i]
	    local text = subs[i].text
	    text = text:gsub("\\n","*small_break*")
	    text = text:gsub("\\N","*large_break*")
	    text = text:gsub("\\h","*hard_space*")
	    text = text:gsub("^(%l)(%l-)", function (c,d) return c:upper()..d end)				-- start of line
	    text = text:gsub("([%s\"}%(%-])(%l)(%l-)", function (e,f,g) return e..f:upper()..g end)		-- after: space " } ( -
	    text = text:gsub("(\\N)(%l)(%l-)", function (h,j,k) return h..j:upper()..k end)			-- after \N
	    text = text:gsub("%s([\'])(%l)(%l-)", function (l,m,n) return " "..l..m:upper()..n end)	-- after space+'
	    text = text:gsub("^(\')(%l)(%l-)", function (l,m,n) return l..m:upper()..n end)			-- start of line+'
	    text = text:gsub("([^%.%:])%sThe%s","%1 the ")
	    text = text:gsub("([^%.%:])%sA([nts]?)%s","%1 a%2 ")
	    text = text:gsub("([^%.%:])%sO([nfr])%s","%1 o%2 ")
	    text = text:gsub("([^%.%:])%sNor%s","%1 nor ")
	    text = text:gsub("([^%.%:])%sFor%s","%1 for ")
	    text = text:gsub("([^%.%:])%sWith%s","%1 with ")
	    text = text:gsub("([^%.%:])%sWithin%s","%1 within ")
	    text = text:gsub("([^%.%:])%sWithout%s","%1 without ")
	    text = text:gsub("([^%.%:])%sTo%s","%1 to ")
	    text = text:gsub("([^%.%:])%sInto%s","%1 into ")
	    text = text:gsub("([^%.%:])%sOnto%s","%1 onto ")
	    text = text:gsub("([^%.%:])%sUnto%s","%1 unto ")
	    text = text:gsub("([^%.%:])%sAnd%s","%1 and ")
	    text = text:gsub("([^%.%:])%sBut%s","%1 but ")
	    text = text:gsub("([^%.%:])%sIn%s","%1 in ")
	    text = text:gsub("([^%.%:])%sInside%s","%1 inside ")
	    text = text:gsub("([^%.%:])%sBy%s","%1 by ")
	    text = text:gsub("([^%.%:])%sTill%s","%1 till ")
	    text = text:gsub("([^%.%:])%sFrom%s","%1 from ")
	    text = text:gsub("([^%.%:])%sOver%s","%1 over ")
	    text = text:gsub("([^%.%:])%sAbove%s","%1 above ")
	    text = text:gsub("([^%.%:])%sAbout%s","%1 about ")
	    text = text:gsub("([^%.%:])%sAround%s","%1 around ")
	    text = text:gsub("([^%.%:])%sAfter%s","%1 after ")
	    text = text:gsub("([^%.%:])%sAgainst%s","%1 against ")
	    text = text:gsub("([^%.%:])%sAlong%s","%1 along ")
	    text = text:gsub("([^%.%:])%sBelow%s","%1 below ")
	    text = text:gsub("([^%.%:])%sBeneath%s","%1 beneath ")
	    text = text:gsub("([^%.%:])%sBeside%s","%1 beside ")
	    text = text:gsub("([^%.%:])%sBetween%s","%1 between ")
	    text = text:gsub("([^%.%:])%sBeyond%s","%1 beyond ")
	    text = text:gsub("([^%.%:])%sUnder%s","%1 under ")
	    text = text:gsub("([^%.%:])%sUntil%s","%1 until ")
	    text = text:gsub("([^%.%:])%sVia%s","%1 via ")
	    -- roman numbers up to 20
	    text = text:gsub("%sIi([^%a])"," II%1")
	    text = text:gsub("%s([IX])v([^%a])"," %1V%2")
	    text = text:gsub("%s([IVX])ii([^%a])"," %1II%2")
	    text = text:gsub("%sVi([^%a])"," VI%1")
	    text = text:gsub("%s([VX])iii([^%a])"," %1III%2")
	    text = text:gsub("%s([IX])x([^%a])"," %1X%2")
	    text = text:gsub("%sXiv([^%a])"," XIV%1")
	    text = text:gsub("%sXvi([^%a])"," XVI%1")
	    text = text:gsub("%sXvii([^%a])"," XVII%1")
	    text = text:gsub("%sXviii([^%a])"," XVIII%1")
	    -- same at the end of line
	    text = text:gsub("%sIi$"," II")
	    text = text:gsub("%s([IX])v$"," %1V")
	    text = text:gsub("%s([VI])ii$"," %1II")
	    text = text:gsub("%sVi$"," VI")
	    text = text:gsub("%s([VX])iii$"," %1III")
	    text = text:gsub("%s([IX])x$"," %1X")
	    text = text:gsub("%sXiv$"," XIV")
	    text = text:gsub("%sXvi$"," XVI")
	    text = text:gsub("%sXvii$"," XVII")
	    text = text:gsub("%sXviii$"," XVIII")
	    -- other stuff
	    text = text:gsub("Ok([%s%p])","OK%1")
	    text = text:gsub("Ok$","OK")
	    text = text:gsub("%-San([%s%p])","-san%1")
	    text = text:gsub("%-Kun([%s%p])","-kun%1")
	    text = text:gsub("%-Chan([%s%p])","-chan%1")
	    text = text:gsub("%-Sama([%s%p])","-sama%1")
	    text = text:gsub("%-Dono([%s%p])","-dono%1")
	    text = text:gsub("%*small_break%*","\\n")
	    text = text:gsub("%*large_break%*","\\N")
	    text = text:gsub("%*hard_space%*","\\h")
	    line.text = text
	    subs[i] = line 
    end
end

function capital(subs, sel)
	dialog_config=
	{
	    {x=1,y=0,width=1,height=1,class="label",		
		label="Choose what you want to do with selected lines:",
	    },
	    {x=1,y=2,width=1,height=1,class="label",		
		label="Capitalize words - Capitalize All Words Like in Titles",
	    },
	    {x=1,y=3,width=1,height=1,class="label",		
		label="        Capitalize lines - Capitalize first word in selected lines",
	    },
	    {x=1,y=4,width=1,height=1,class="label",		
		label="                Lowercase - make text in selected lines lowercase",
	    },
	    {x=1,y=5,width=1,height=1,class="label",		
		label="                        Uppercase - MAKE TEXT IN SELECTED LINES UPPERCASE",
	    },
	    {x=1,y=6,width=1,height=1,class="label",label="",
	    },
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,
	{"Capitalize Words","Capitalize lines","lowercase","UPPERCASE","Cancel"},{cancel='Cancel'})
	if pressed=="Cancel" then    aegisub.cancel() end
	
	if pressed=="Capitalize Words" then    lowercase(subs, sel) capitalize(subs, sel) end
	if pressed=="Capitalize lines" then    capitalines(subs, sel) end
	if pressed=="lowercase" then    lowercase(subs, sel) end
	if pressed=="UPPERCASE" then    uppercase(subs, sel) end
	
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, capital)