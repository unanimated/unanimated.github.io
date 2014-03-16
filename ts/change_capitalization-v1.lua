-- Capitalize text or make it lowercase / uppercase. Select lines, run the script, choose from the 4 options.

script_name="Change capitalization"
script_description="Capitalizes text or makes it lowercase or uppercase"
script_author="unanimated"
script_version="1.0"

function lowercase(subs, sel)
    for x, i in ipairs(sel) do
            local line=subs[i]
	    local text=subs[i].text
	    text=text:gsub("^([^{]*)", function (l) return l:lower() end)
	    text=text:gsub("}([^{]*)", function (l) return "}"..l:lower() end)
	    text=text:gsub("\\n","\\N")
	    line.text=text
	    subs[i]=line 
    end
end

function uppercase(subs, sel)
    for x, i in ipairs(sel) do
            local line=subs[i]
	    local text=subs[i].text
	    text=text:gsub("^([^{]*)", function (u) return u:upper() end)
	    text=text:gsub("}([^{]*)", function (u) return "}"..u:upper() end)
	    line.text=text
	    subs[i]=line 
    end
end

function capitalines(subs, sel)
    for x, i in ipairs(sel) do
            local line=subs[i]
	    local text=subs[i].text
	    text=text:gsub("^(%l)([^{]-)", function (c,d) return c:upper()..d end)
	    text=text:gsub("}(%l)([^{]-)", function (a,b) return "}"..a:upper()..b end)
	    line.text=text
	    subs[i]=line 
    end
end

function capitalize(subs, sel)
    for x, i in ipairs(sel) do
            local line=subs[i]
	    local text=subs[i].text
	    text=text:gsub("^(%l)(%l-)", function (c,d) return c:upper()..d end)				-- start of line
	    text=text:gsub("([%s\"}%(%-])(%l)(%l-)", function (e,f,g) return e..f:upper()..g end)		-- after: space " } ( -
	    text=text:gsub("(\\N)(%l)(%l-)", function (h,j,k) return h..j:upper()..k end)			-- after \N
	    text=text:gsub("%s([\'])(%l)(%l-)", function (l,m,n) return " "..l..m:upper()..n end)	-- after space+'
	    text=text:gsub("^(\')(%l)(%l-)", function (l,m,n) return l..m:upper()..n end)			-- start of line+'
	    text=text:gsub("([^%.%:])%sThe%s","%1 the ")
	    text=text:gsub("([^%.%:])%sA([nts]?)%s","%1 a%2 ")
	    text=text:gsub("([^%.%:])%sO([nfr])%s","%1 o%2 ")
	    text=text:gsub("([^%.%:])%sNor%s","%1 nor ")
	    text=text:gsub("([^%.%:])%sFor%s","%1 for ")
	    text=text:gsub("([^%.%:])%sWith([(in)(in)]?)%s","%1 with ")
	    text=text:gsub("([^%.%:])%sTo%s","%1 to ")
	    text=text:gsub("([^%.%:])%sInto%s","%1 into ")
	    text=text:gsub("([^%.%:])%sOnto%s","%1 onto ")
	    text=text:gsub("([^%.%:])%sUnto%s","%1 unto ")
	    text=text:gsub("([^%.%:])%sAnd%s","%1 and ")
	    text=text:gsub("([^%.%:])%sBut%s","%1 but ")
	    text=text:gsub("([^%.%:])%sIn%s","%1 in ")
	    text=text:gsub("([^%.%:])%sBy%s","%1 by ")
	    text=text:gsub("([^%.%:])%sFrom%s","%1 from ")
	    text=text:gsub("([^%.%:])%sOver%s","%1 over ")
	    text=text:gsub("([^%.%:])%sAbove%s","%1 above ")
	    text=text:gsub("([^%.%:])%sUnder%s","%1 under ")
	    text=text:gsub("%sIi([^%a])"," II%1")
	    text=text:gsub("%sIv([^%a])"," IV%1")
	    text=text:gsub("%s([IVX])ii([^%a])"," %1II%2")
	    text=text:gsub("%sVi([^%a])"," VI%1")
	    text=text:gsub("%s([VX])iii([^%a])"," %1III%2")
	    text=text:gsub("%s([IX])x([^%a])"," %1X%2")
	    text=text:gsub("%sIi$"," II")
	    text=text:gsub("%sIv$"," IV")
	    text=text:gsub("%s([VI])ii$"," %1II")
	    text=text:gsub("%sVi$"," VI")
	    text=text:gsub("%s([VX])iii$"," %1III")
	    text=text:gsub("%s([IX])x$"," %1X")
	    line.text=text
	    subs[i]=line 
    end
end

function capital(subs, sel)	
	dialog_config=
	{
	    {
		class="dropdown",name="option",
		x=0,y=0,width=1,height=1,
		items={"Capitalize words (titles)","Cpitalize lines", "Make lowercase", "Make uppercase"},
		value="Capitalize words (titles)"
	    },
	} 	
	pressed, results=aegisub.dialog.display(dialog_config,{"OK","Cancel"})
	if pressed=="Cancel" then    aegisub.cancel() end
	
	if pressed=="OK" then 
		if results["option"]=="Capitalize words (titles)" then lowercase(subs, sel) capitalize(subs, sel) end
		if results["option"]=="Cpitalize lines" then lowercase(subs, sel) capitalines(subs, sel) end
		if results["option"]=="Make lowercase" then lowercase(subs, sel) end
		if results["option"]=="Make uppercase" then uppercase(subs, sel) end
	end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, capital)