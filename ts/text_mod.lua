
script_name="Modify Text"
script_description="A collection of scripts for text modification"
script_author="unanimated"
script_version="1.0"

function italicize(subs,sel)
	for z, i in ipairs(sel) do
		local l=subs[i]
		text=l.text
		styleref=stylechk(subs,l.style)
		local si=styleref.italic
		if si==false then it="1" else it="0" end
		text=text:gsub("\\i([\\}])","\\i".. 1-it.."%1")
		    if text:match("^{[^}]*\\i%d[^}]*}") then
			text=text:gsub("\\i(%d)", function(num) return "\\i".. 1-num end)
		    else
			if text:match("\\i([01])") then italix=text:match("\\i([01])") end
			if italix==it then text=text:gsub("\\i(%d)", function(num) return "\\i".. 1-num end) end
			text="{\\i"..it.."}"..text
			text=text:gsub("{\\i(%d)}({\\[^}]*)}","%2\\i%1}")
		    end
		l.text=text
		subs[i]=l
	end
end

function bold(subs,sel)
	for z, i in ipairs(sel) do
		local l=subs[i]
		text=l.text
		styleref=stylechk(subs,l.style)
		local sb=styleref.bold
		if sb==false then b="1" else b="0" end
		text=text:gsub("\\b([\\}])","\\b".. 1-b.."%1")
		    if text:match("^{[^}]*\\b%d[^}]*}") then
			text=text:gsub("\\b(%d)", function(num) return "\\b".. 1-num end)
		    else
			if text:match("\\b([01])") then bolt=text:match("\\b([01])") end
			if bolt==b then text=text:gsub("\\b(%d)", function(num) return "\\b".. 1-num end) end
			text="{\\b"..b.."}"..text
			text=text:gsub("{\\b(%d)}({\\[^}]*)}","%2\\b%1}")
		    end
		l.text=text
		subs[i]=l
	end
end

function lowercase(subs,sel)
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

function uppercase(subs,sel)
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

function capitalines(subs,sel)
    for x, i in ipairs(sel) do
            local line=subs[i]
	    local text=subs[i].text
	    text=text:gsub("^(%l)([^{]-)", function (c,d) return c:upper()..d end)
	    text=text:gsub("^({[^}]-})(%l)([^{]-)", function (e,f,g) return e..f:upper()..g end)
	    text=text:gsub(" i "," I ")
	    text=text:gsub(" i'"," I'")
	    text=text:gsub("\\Ni ","\\NI ")
	    text=text:gsub("\\Ni'","\\NI'")
	    line.text=text
	    subs[i]=line
    end
end

function sentences(subs,sel)
    for x, i in ipairs(sel) do
            local line=subs[i]
	    local text=subs[i].text
	    text=text:gsub("^(%l)([^{]-)", function (c,d) return c:upper()..d end)
	    text=text:gsub("^({[^}]-})(%l)([^{]-)", function (e,f,g) return e..f:upper()..g end)
	    text=text:gsub("([%.?!]%s)(%l)", function (k,l) return k..l:upper() end)
	    text=text:gsub(" i "," I ")
	    text=text:gsub(" i'"," I'")
	    text=text:gsub("\\Ni ","\\NI ")
	    text=text:gsub("\\Ni'","\\NI'")
	    line.text=text
	    subs[i]=line
    end
end

word={"The","A","An","At","As","On","Of","Or","For","Nor","With","Without","Within","To","Into","Onto","Unto","And","But","In","Inside","By","Till","From","Over","Above","About","Around","After","Against","Along","Below","Beneath","Beside","Between","Beyond","Under","Until","Via"}

vord={"the","a","an","at","as","on","of","or","for","nor","with","without","within","to","into","onto","unto","and","but","in","inside","by","till","from","over","above","about","around","after","against","along","below","beneath","beside","between","beyond","under","until","via"}

function capitalize(subs,sel)
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

function strikealpha(subs,sel)
    for x, i in ipairs(sel) do
        local l=subs[i]
	l.text=l.text:gsub("\\s1","\\alpha&H00&")
	l.text=l.text:gsub("\\s0","\\alpha&HFF&")
	l.text=l.text:gsub("\\u1","\\alpha&HFF&")
	l.text=l.text:gsub("\\u0","\\alpha&H00&")
	subs[i]=l
    end
end

function an8q2(subs,sel)
    for x, i in ipairs(sel) do
        local line=subs[i]
        local text=subs[i].text
	if res.anq=="\\an8" then
	    if line.text:match("\\an%d") then
	    text=text:gsub("\\an%d","")
	    text=text:gsub("{}","")
	    else
	    text="{\\an8}"..text
	    text=text:gsub("{\\an8}{\\","{\\an8\\")
	    end
	end
	if res.anq=="\\q2" then
	    if text:match("\\q2") then
	    text=text:gsub("\\q2","")
	    text=text:gsub("{}","")
	    else
	    text="{\\q2}"..text
	    text=text:gsub("{\\q2}{\\","{\\q2\\")
	    end
	end
	line.text=text
	subs[i]=line
    end
end

function honorifix(subs, sel)
    for i=#subs,1,-1 do
      if subs[i].class=="dialogue" then
        local line=subs[i]
        local text=subs[i].text
	text=text
	:gsub("%-san([^%a]?)","{-san}%1")
	:gsub("%-chan([^%a]?)","{-chan}%1")
	:gsub("%-kun([^%a]?)","{-kun}%1")
	:gsub("%-sama([^%a]?)","{-sama}%1")
	:gsub("%-niisan","{-niisan}")
	:gsub("%-oniisan","{-oniisan}")
	:gsub("%-oniichan","{-oniichan}")
	:gsub("%-oneesan","{-oneesan}")
	:gsub("%-oneechan","{-oneechan}")
	:gsub("%-oneesama","{-oneesama}")
	:gsub("%-neesama","{-neesama}")
	:gsub("%-sensei","{-sensei}")
	:gsub("%-se[mn]pai","{-senpai}")
	:gsub("%-dono","{-dono}")
	:gsub("Onii{%-chan}","Brother{Onii-chan}")
	:gsub("Onii{%-san}","Brother{Onii-san}")
	:gsub("Onee{%-chan}","Sister{Onee-chan}")
	:gsub("Onee{%-san}","Sister{Onee-san}")
	:gsub("Onee{%-sama}","Sister{Onee-sama}")
	:gsub("onii{%-chan}","brother{onii-chan}")
	:gsub("onii{%-san}","brother{onii-san}")
	:gsub("onii{%-sama}","brother{onii-sama}")
	:gsub("onee{%-chan}","sister{onee-chan}")
	:gsub("onee{%-san}","sister{onee-san}")
	:gsub("onee{%-sama}","sister{onee-sama}")
	:gsub("{{","{")
	:gsub("}}","}")
	:gsub("({[^{}]-){(%-%a-)}([^{}]-})","%1%2%3")
	line.text=text
        subs[i]=line
      end
    end
end

function stylechk(subs,stylename)
    for i=1,#subs do
        if subs[i].class=="style" then
	    style=subs[i]
	    if stylename==style.name then
		styleref=style
		break
	    end
	end
    end
    return styleref
end

function textmod(subs,sel)
	dialog_config={
	{x=0,y=0,width=1,height=1,class="dropdown",name="ita",items={"italicize","bold"},value="italicize" },
	{x=1,y=0,width=1,height=1,class="dropdown",name="capi",items={"capit. words","capit. lines","capit. sentences","lowercase","uppercase"},value="capit. words" },
	{x=2,y=0,width=1,height=1,class="dropdown",name="anq",items={"\\an8","\\q2"},value="\\an8" },
	} 	
	pressed, res=aegisub.dialog.display(dialog_config,{"itabold","capitalize","an8 / q2","honorifix","cancel"},{close='cancel'})
	if pressed=="cancel" then aegisub.cancel() end
	
	if pressed=="itabold" then
	    if res.ita=="italicize" then italicize(subs,sel) end
	    if res.ita=="bold" then bold(subs,sel) end
	end
	if pressed=="capitalize" then
	    if res.capi=="capit. words" then capitalize(subs,sel) end
	    if res.capi=="capit. lines" then capitalines(subs,sel) end
	    if res.capi=="capit. sentences" then sentences(subs,sel) end
	    if res.capi=="lowercase" then lowercase(subs,sel) end
	    if res.capi=="uppercase" then uppercase(subs,sel) end
	end
	if pressed=="an8 / q2" then an8q2(subs,sel) end
	if pressed=="honorifix" then honorifix(subs,sel) end
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, textmod)