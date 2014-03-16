-- Capitalize text or make it lowercase / uppercase. Select lines, run the script, choose from the 5 options.

script_name = "Change capitalization"
script_description = "Capitalizes text or makes it lowercase or uppercase"
script_author = "unanimated"
script_version = "1.71"

function lowercase(subs, sel)
    for x, i in ipairs(sel) do
            local line=subs[i]
	    local text=subs[i].text
	    text=text:gsub("\\n","small_break")
	    text=text:gsub("\\N","large_break")
	    text=text:gsub("\\h","hard_space")
	    text=text:gsub("^([^{]*)", function (l) return l:lower() end)
	    text=text:gsub("}([^{]*)", function (l) return "}"..l:lower() end)
	    text=text:gsub("small_break","\\n")
	    text=text:gsub("large_break","\\N")
	    text=text:gsub("hard_space","\\h")
	    line.text=text
	    subs[i]=line
    end
end

function uppercase(subs, sel)
    for x, i in ipairs(sel) do
            local line=subs[i]
	    local text=subs[i].text
	    text=text:gsub("\\n","SMALL_BREAK")
	    text=text:gsub("\\N","LARGE_BREAK")
	    text=text:gsub("\\h","HARD_SPACE")
	    text=text:gsub("^([^{]*)", function (u) return u:upper() end)
	    text=text:gsub("}([^{]*)", function (u) return "}"..u:upper() end)
	    text=text:gsub("SMALL_BREAK","\\n")
	    text=text:gsub("LARGE_BREAK","\\N")
	    text=text:gsub("HARD_SPACE","\\h")
	    line.text=text
	    subs[i]=line
    end
end

function capitalines(subs, sel)
    for x, i in ipairs(sel) do
            local line=subs[i]
	    local text=subs[i].text
	    text=text:gsub("^(%l)([^{]-)", function (c,d) return c:upper()..d end)
	    text=text:gsub("^({[^}]-})(%l)([^{]-)", function (e,f,g) return e..f:upper()..g end)
	    text=text:gsub(" i "," I ")
	    text=text:gsub(" i\'"," I'")
	    text=text:gsub("\\Ni ","\\NI ")
	    text=text:gsub("\\Ni\'","\\NI'")
	    line.text=text
	    subs[i]=line
    end
end

function sentences(subs, sel)
    for x, i in ipairs(sel) do
            local line=subs[i]
	    local text=subs[i].text
	    text=text:gsub("^(%l)([^{]-)", function (c,d) return c:upper()..d end)
	    text=text:gsub("^({[^}]-})(%l)([^{]-)", function (e,f,g) return e..f:upper()..g end)
	    text=text:gsub("([%.?!]%s)(%l)", function (k,l) return k..l:upper() end)
	    text=text:gsub(" i "," I ")
	    text=text:gsub(" i\'"," I'")
	    text=text:gsub("\\Ni ","\\NI ")
	    text=text:gsub("\\Ni\'","\\NI'")
	    line.text=text
	    subs[i]=line
    end
end

word={"The","A","An","At","As","On","Of","Or","For","Nor","With","Without","Within","To","Into","Onto","Unto","And","But","In","Inside","By","Till","From","Over","Above","About","Around","After","Against","Along","Below","Beneath","Beside","Between","Beyond","Under","Until","Via"}

vord={"the","a","an","at","as","on","of","or","for","nor","with","without","within","to","into","onto","unto","and","but","in","inside","by","till","from","over","above","about","around","after","against","along","below","beneath","beside","between","beyond","under","until","via"}

function capitalize(subs, sel)
    for x, i in ipairs(sel) do
            local line=subs[i]
	    local text=subs[i].text
	    text=text:gsub("\\n","*small_break*")
	    text=text:gsub("\\N","*large_break*")
	    text=text:gsub("\\h","*hard_space*")
	    text=text:gsub("^(%l)(%l-)", function (c,d) return c:upper()..d end)				-- start of line
	    text=text:gsub("([%s\"}%(%-=])(%l)(%l-)", function (e,f,g) return e..f:upper()..g end)	-- after: space " } ( - =
	    text=text:gsub("(break%*)(%l)(%l-)", function (h,j,k) return h..j:upper()..k end)			-- after \N
	    text=text:gsub("%s([\'])(%l)(%l-)", function (l,m,n) return " "..l..m:upper()..n end)	-- after space+'
	    text=text:gsub("^(\')(%l)(%l-)", function (l,m,n) return l..m:upper()..n end)			-- start of line+'

	    for r=1,#word do
	    w=word[r]	    v=vord[r]
	    text=text:gsub("([^%.%:])%s"..w.."%s","%1 "..v.." ")
	    text=text:gsub("([^%.%:])%s({[^}]-})"..w.."%s","%1 %2"..v.." ")
	    end

	    -- other stuff
	    text=text:gsub("$","#")
	    text=text:gsub("(%s?)([IVXLCDM])([ivxlcdm]+)([%s%p#])",function (s,r,m,e) return s..r..m:upper()..e end)	-- Roman numbers
	    text=text:gsub("LID","Lid")
	    text=text:gsub("DIM","Dim")
	    text=text:gsub("Ok([%s%p#])","OK%1")
	    text=text:gsub("%-San([%s%p#])","-san%1")
	    text=text:gsub("%-Kun([%s%p#])","-kun%1")
	    text=text:gsub("%-Chan([%s%p#])","-chan%1")
	    text=text:gsub("%-Sama([%s%p#])","-sama%1")
	    text=text:gsub("%-Dono([%s%p#])","-dono%1")
	    text=text:gsub("#$","")
	    text=text:gsub("%*small_break%*","\\n")
	    text=text:gsub("%*large_break%*","\\N")
	    text=text:gsub("%*hard_space%*","\\h")

	    line.text=text
	    subs[i]=line
    end
end

function capital(subs, sel)
	dialog_config=
	{
	    {x=1,y=0,width=1,height=1,class="label",
		label="Words - Capitalize All Words Like in Titles",
	    },
	    {x=1,y=1,width=1,height=1,class="label",
		label="        Lines - Capitalize first word in selected lines",
	    },
	    {x=1,y=2,width=1,height=1,class="label",
		label="                Sentences - Capitalize first word in each sentence",
	    },
	    {x=1,y=3,width=1,height=1,class="label",
		label="                        Lowercase - make text in selected lines lowercase",
	    },
	    {x=1,y=4,width=1,height=1,class="label",
		label="                                Uppercase - MAKE TEXT IN SELECTED LINES UPPERCASE",
	    },
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,
	{"Words","Lines","Sentences","lowercase","UPPERCASE","Cancel"},{cancel='Cancel'})
	if pressed=="Cancel" then aegisub.cancel() end
	
	if pressed=="Words" then lowercase(subs, sel) capitalize(subs, sel) end
	if pressed=="Lines" then capitalines(subs, sel) end
	if pressed=="Sentences" then sentences(subs, sel) end
	if pressed=="lowercase" then lowercase(subs, sel) end
	if pressed=="UPPERCASE" then uppercase(subs, sel) end
	
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, capital)