--[[	"Blur with Layers" creates layers with blur.
	It supports 2 borders, xbord, ybord, xshad, and yshad. It has basic support for transforms and \r.
	
	"Blur and Glow" - Same as above but with an extra layer for glow. Set blur amount and alpha for the glow.
	
	The "double border" option additionally lets you change the size and colour of the 2nd border.
	
	If blur is missing, default_blur is added by default. (see settings)
	
	"Bottom blur" allows you to use different blur for bottom [non-glow] layer than for top layer(s).
	
	"fix \\1a for layers with border and fade" - Uses \1a&HFF& for the duration of a fade on layers with border.
		"transition" - for \fad(500,0) with transition 80ms you get \1a&HFF&\t(420,500,\1a&H00&).
	
	"Fix fades" - Recalculates those \1a fades mentioned above. 
	Use this when you shift something like an episode title to a new episode and the duration of the sign is different.
	
	"Change layer" - raises or lowers layer for all selected lines by the same amount. [This is separate from the other functions.]

]]

script_name="Blur and Glow"
script_description="Add blur and/or glow to signs"
script_author="unanimated"
script_version="2.0 beta3"

--	SETTINGS	--			OPTIONS

glow_blur=3					-- any number usable for blur
glow_alpha="80"					-- "00","20","30","40","50","60","70","80","90","A0","B0","C0","D0","F0"
second_border_size=2				-- any number usable for border
bottom_blur=1					-- any number usable for blur
fix_for_fades=true				-- true/false
change_layer="+1"				-- "-5","-4","-3","-2","-1","+1","+2","+3","+4","+5"
automatically_use_double_border=true		-- true/false; automatically use double border if 2nd colour or 2nd border size is checked
default_blur="0.6"

--	--	--	--


function glow(subs, sel)
    if not res.rep then al=res.alfa bl=res.blur end
    if automatically_use_double_border then if res.clr or res.bsize then res.double=true end end
    for i=#sel,1,-1 do
	aegisub.progress.title(string.format("Glowing line: %d/%d",(#sel-i+1),#sel))
	line=subs[sel[i]]
	text=line.text
	if defaref~=nil and line.style=="Default" then styleref=defaref
	else styleref=stylechk(line.style) end
	duration=line.end_time-line.start_time
	
	    -- get colors, border, shadow from style
	    	startags=text:match("^{\\[^}]-}")
		if startags==nil then startags="" end
		startags=startags:gsub("\\t%([^%(%)]+%)","") :gsub("\\t%([^%(%)]-%([^%)]-%)[^%)]-%)","")
		
		primary=styleref.color1:gsub("H%x%x","H")
		pri=startags:match("^{[^}]-\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		soutline=styleref.color3:gsub("H%x%x","H")
		outline=soutline
		out=startags:match("^{[^}]-\\3c(&H%x+&)")
		if out~=nil then outline=out end
		
		border=tostring(styleref.outline)
		bord=startags:match("^{[^}]-\\bord([%d%.]+)")
		if bord~=nil then border=bord end
		
		shadow=tostring(styleref.shadow)
		shad=startags:match("^{[^}]-\\shad([%d%.]+)")
		if shad~=nil then shadow=shad end
		
		if text:match("\\r%a") then 
		rstyle=text:match("\\r([^\\}]+)")
		reref=stylechk(rstyle)
		rimary=reref.color1:gsub("H%x%x","H")
		routline=reref.color3:gsub("H%x%x","H")
		rbord=tostring(reref.outline)
		else routline=soutline rimary=primary rbord=border
		end
		
		if res.glowcol then glowc=res.glc:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&") end
	
	if not text:match("^{\\") then text="{\\blur"..default_blur.."}"..text 
	text=text:gsub("(\\r[^}]-)}","%1\\blur"..default_blur.."}") end
	
	    if not text:match("\\blur") then text=text:gsub("^{\\","{\\blur"..default_blur.."\\")	-- default blur if missing in tags 
	    text=text:gsub("(\\r[^}]-)}","%1\\blur"..default_blur.."}") end
	    if text:match("\\blur") and not text:match("^{[^}]*blur[^}]*}") then
	    text=text:gsub("^{\\","{\\blur"..default_blur.."\\") end					-- add blur if missing in first tag block
	    text=text:gsub("\\1c","\\c")
	    if text:match("^({[^}]-\\t)[^}]-}") and not text:match("^{[^}]-\\3c[^}]-\\t") then	-- \t workaround
		text=text:gsub("^{\\","{\\3c"..soutline.."\\")
	    end
	    line.text=text
		
--		line.effect="done"
		
	if border~="0" or text:match("\\[xy]bord") then
	    
	    
	    -- with two borders
	    
	  if res["double"] then

		-- second border
	    line1=line
	    line1.text=text
	    line1.text=borderline2(line1.text)
	    line1.layer=line1.layer+1
	    subs.insert(sel[i]+1,line1)

		-- first border
	    line2=line
	    line2.text=text
	    line2.text=borderline(line2.text)
	    if shadow~="0" then line2.text=line2.text:gsub("^({\\[^}]+)}","%1\\shad0}") end
	    line2.text=line2.text:gsub("\\shad[%d%.]+","\\shad0")
	    line2.layer=line2.layer+1
	    subs.insert(sel[i]+2,line2)
	    
		-- top line
	    line3=line
	    line3.text=text
	    line3.text=topline(line3.text)
	    line3.layer=line3.layer+1
	    subs.insert(sel[i]+3,line3)

		-- bottom / glow
	    text=text:gsub("\\3c&H%x+&","")
	    if not text:match("^{[^}]-\\3c&[^}]-}") then text=text:gsub("^({\\[^}]+)}","%1\\3c"..outlinetwo.."}") end
	    text=text:gsub("(\\3c)(&H%x+&)","%1"..outlinetwo)
	    :gsub("(\\c)(&H%x+&)([^}]-)}","%1%2%3\\3c%2}")
	    :gsub("(\\r[^}]+)}","%1\\3c"..rimary.."}")
	    
	    bordertwo=border
	    if res.bsize then bordertwo=res.secbord end
	    
	    if not text:match("^{[^}]-\\bord") then text=text:gsub("^{\\","{\\bord"..border.."\\")  end
	    text=text:gsub("(\\r[^\\}]-)([\\}])","%1\\bord"..rbord.."%2")
	    :gsub("(\\r[^\\}]-)\\bord[%d%.%-]+([^}]-)(\\bord[%d%.%-]+)","%1%2%3")
	    text=text:gsub("(\\bord)([%d%.]+)",function(a,b) if res.bsize then brd=bordertwo else brd=b end return a..b+brd end)
	    text=text:gsub("(\\[xy]bord)([%d%.]+)",function(a,b) return a..b+b end)
	    :gsub("\\c&H%x+&([^}]-)(\\c&H%x+&)",function(a,b) if not a:match("\\t") then return a..b end end)
	    :gsub("\\3c&H%x+&([^}]-)(\\3c&H%x+&)",function(a,b) if not a:match("\\t") then return a..b end end)
	    text=glowlayer(text,"3c","3")
	    if res.botalpha and line.text:match("\\fad%(") then text=botalfa(text) end
	    line.layer=line.layer-3
	    line.text=text

	  else
	  
	    -- with one border
	    
		-- border
	    line2=line
	    line2.text=text
	    line2.text=borderline(line2.text)
	    line2.layer=line2.layer+1
	    subs.insert(sel[i]+1,line2)
	    
		-- top line
	    line3=line
	    line3.text=text
	    line3.text=topline(line3.text)
	    line3.layer=line3.layer+1
	    subs.insert(sel[i]+2,line3)
	    
		-- bottom / glow
	    text=glowlayer(text,"3c","3")
	    if res.botalpha and line.text:match("\\fad%(") then text=botalfa(text) end
	    line.layer=line.layer-2
	    line.text=text
	    
	  end
	    
	else

	    -- without border
	    line2=line
	    line2.layer=line2.layer+1
	    subs.insert(sel[i]+1,line2)
	    text=glowlayer(text,"c","1")
	    line.layer=line.layer-1
	    line.text=text
	end
	    
	    text=text:gsub("\\\\","\\")
	    text=text:gsub("\\}","}")
	    text=text:gsub("{%*?}","")	
	subs[sel[i]]=line
    end
    aegisub.progress.title(string.format("Blur & Glow: DONE"))
end

function layerblur(subs, sel)
    if automatically_use_double_border then if res.clr or res.bsize then res.double=true end end
    for i=#sel,1,-1 do
	aegisub.progress.title(string.format("Blurring line: %d/%d",(#sel-i+1),#sel))
	line=subs[sel[i]]
	text=line.text
	if defaref~=nil and line.style=="Default" then styleref=defaref
	else styleref=stylechk(line.style) end
	duration=line.end_time-line.start_time
	    
	    -- get colors, border, shadow from style
	    	startags=text:match("^{\\[^}]-}")
		if startags==nil then startags="" end
		startags=startags:gsub("\\t%([^%(%)]+%)","") :gsub("\\t%([^%(%)]-%([^%)]-%)[^%)]-%)","")
		
		primary=styleref.color1:gsub("H%x%x","H")
		pri=startags:match("^{[^}]-\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		soutline=styleref.color3:gsub("H%x%x","H")
		outline=soutline
		out=startags:match("^{[^}]-\\3c(&H%x+&)")
		if out~=nil then outline=out end
		
		border=tostring(styleref.outline)
		bord=startags:match("^{[^}]-\\bord([%d%.]+)")
		if bord~=nil then border=bord end
		
		shadow=tostring(styleref.shadow)
		shad=startags:match("^{[^}]-\\shad([%d%.]+)")
		if shad~=nil then shadow=shad end
		
		if text:match("\\r%a") then 
		rstyle=text:match("\\r([^\\}]+)")
		reref=stylechk(rstyle)
		rimary=reref.color1:gsub("H%x%x","H")
		routline=reref.color3:gsub("H%x%x","H")
		rbord=tostring(reref.outline)
		else routline=soutline rimary=primary rbord=border
		end
	
	if not text:match("^{\\") then text="{\\blur"..default_blur.."}"..text 
	text=text:gsub("(\\r[^}]-)}","%1\\blur"..default_blur.."}") end
	
	    if not text:match("\\blur") then text=text:gsub("^{\\","{\\blur"..default_blur.."\\")	-- default blur if missing in tags 
	    text=text:gsub("(\\r[^}]-)}","%1\\blur"..default_blur.."}") end
	    if text:match("\\blur") and not text:match("^{[^}]*blur[^}]*}") then
	    text=text:gsub("^{\\","{\\blur"..default_blur.."\\") end					-- add blur if missing in first tag block
	    text=text:gsub("\\1c","\\c")
	    if text:match("^({[^}]-\\t)[^}]-}") and not text:match("^{[^}]-\\3c[^}]-\\t") then	-- \t workaround
		text=text:gsub("^{\\","{\\3c"..soutline.."\\")
	    end
	    line.text=text
		
--		line.effect="done"
	
	    if res["double"] then
	    
	    -- two borders
	    
		-- first border
	    line2=line
	    line2.text=text
	    line2.text=borderline(line2.text)
	    line2.text=line2.text:gsub("(\\[xy]?shad)[%d%.%-]+","%10")
	    line2.layer=line2.layer+1
	    subs.insert(sel[i]+1,line2)
		
		-- top line
	    line3=line
	    line3.text=text
	    line3.text=topline(line3.text)
	    line3.layer=line3.layer+1
	    subs.insert(sel[i]+2,line3)
		
		-- second border
	    text=borderline2(text)
		
	    line.layer=line.layer-2
	    text=text:gsub("{}","")
	    line.text=text
	    
	    else
	    
	    -- one border [regular Duplicate and Blur stuff]
	    
		-- top line
	    line3=line
	    line3.text=text
	    line3.text=topline(line3.text)
	    line3.layer=line3.layer+1
	    subs.insert(sel[i]+1,line3)
	    
		-- bottom line
	    text=borderline(text)

	    line.layer=line.layer-1
	    text=text:gsub("\\\\","\\")
	    text=text:gsub("\\}","}")
	    text=text:gsub("{%*?}","")
	    line.text=text
	    end
	subs[sel[i]]=line
    end
    aegisub.progress.title(string.format("Blur: DONE"))
end

function topline(txt)
    -- transform check
    if txt:match("^{[^}]-\\t%([^%)]-\\bord") then
	pretrans=text:match("^{(\\[^}]-)\\t")
	if not pretrans:match("^{[^}]-\\bord") then txt=txt:gsub("^{\\","{\\bord0\\") end
    end
    if not txt:match("^{[^}]-\\bord") then txt=txt:gsub("^{\\","{\\bord0\\") end
    txt=txt:gsub("\\bord[%d%.]+","\\bord0") 
    :gsub("(\\r[^}]-)}","%1\\bord0}")
    txt=txt:gsub("(\\[xy]bord)[%d%.]+","%10")    :gsub("(\\[xy]shad)[%d%.%-]+","%10")    :gsub("\\3c&H%x+&","")
    if shadow~="0" then txt=txt:gsub("^({\\[^}]+)}","%1\\shad0}") end
    txt=txt
    :gsub("(\\t%([^%)]-)\\bord0","%1")
    :gsub("(\\t%([^%)]-)\\shad0","%1")
    :gsub("\\t%(%)","")
    :gsub("\\shad[%d%.]+","\\shad0")
    :gsub("(\\r[^}]-)}","%1\\shad0}")
    :gsub("\\bord[%d%.%-]+([^}]-)(\\bord[%d%.%-]+)","%1%2")
    :gsub("\\shad[%d%.%-]+([^}]-)(\\shad[%d%.%-]+)","%1%2")
    :gsub("{}","")
    return txt
end

function borderline(txt)
    txt=txt:gsub("\\c&H%x+&","")
    -- transform check
    if txt:match("^{[^}]-\\t%([^%)]-\\3c") then
	pretrans=text:match("^{(\\[^}]-)\\t")
	if not pretrans:match("^{[^}]-\\3c") then txt=txt:gsub("^{\\","{\\c"..soutline.."\\") end
    end
    if not txt:match("^{[^}]-\\3c&[^}]-}") then
        txt=txt:gsub("^({\\[^}]+)}","%1\\c"..soutline.."}")
	:gsub("(\\r[^}]-)}","%1\\c"..routline.."}")
    end
    txt=txt:gsub("(\\3c)(&H%x+&)","%1%2\\c%2")
    :gsub("(\\r[^}]-)}","%1\\c"..routline.."}")
    :gsub("(\\r[^}]-\\3c)(&H%x+&)([^}]-)}","%1%2\\c%2%3")
    if res.bbl then txt=txt:gsub("\\blur[%d%.]+","\\blur"..res.bblur) end
    -- alpha fades
    if res.botalpha and txt:match("\\fad%(") then
	txt=botalfa(txt)
    end
    txt=txt:gsub("\\c&H%x+&([^}]-)(\\c&H%x+&)",function(a,b) if not a:match("\\t") then return a..b end end)
    txt=txt:gsub("{}","")
    return txt
end

function borderline2(txt)
    outlinetwo=primary
    if res.clr then col3=res.c3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&") outlinetwo=col3 rimary=col3 end
    bordertwo=border
    if res.bsize then bordertwo=res.secbord end
    -- transform check
    if txt:match("^{[^}]-\\t%([^%)]-\\bord") then
	pretrans=text:match("^{(\\[^}]-)\\t")
	if not pretrans:match("^{[^}]-\\bord") then txt=txt:gsub("^{\\","{\\bord"..border.."\\") end
    end
    if not txt:match("^{[^}]-\\bord") then txt=txt:gsub("^{\\","{\\bord"..border.."\\")  end
    txt=txt:gsub("(\\r[^\\}]-)([\\}])","%1\\bord"..rbord.."%2")
    :gsub("(\\r[^\\}]-)\\bord[%d%.%-]+([^}]-)(\\bord[%d%.%-]+)","%1%2%3")
    txt=txt:gsub("(\\bord)([%d%.]+)",function(a,b) if res.bsize then brd=bordertwo else brd=b end return a..b+brd end)
    txt=txt:gsub("(\\[xy]bord)([%d%.]+)",function(a,b) return a..b+b end)
    
    txt=txt:gsub("\\3c&H%x+&","")
    txt=txt:gsub("(\\3c)(&H%x+&)","%1"..outlinetwo)
    :gsub("(\\c)(&H%x+&)([^}]-)}","%1%2%3\\3c%2}")
    if not txt:match("^{[^}]-\\3c&") then txt=txt:gsub("^({\\[^}]+)}","%1\\3c"..outlinetwo.."}") end
    txt=txt:gsub("(\\r[^}]+)}","%1\\3c"..rimary.."}")
    
    if res.bbl then txt=txt:gsub("\\blur[%d%.]+","\\blur"..res.bblur) end
    -- alpha fades
    if res.botalpha and txt:match("\\fad%(") then
	txt=botalfa(txt)
    end
    txt=txt:gsub("\\c&H%x+&([^}]-)(\\c&H%x+&)",function(a,b) if not a:match("\\t") then return a..b end end)
    txt=txt:gsub("\\3c&H%x+&([^}]-)(\\3c&H%x+&)",function(a,b) if not a:match("\\t") then return a..b end end)
    txt=txt:gsub("{}","")
    return txt
end

function glowlayer(txt,kol,alf)
    txt=txt:gsub("\\alpha&H(%x%x)&",function(a) if a>al then return "\\alpha&H"..a.."&" else return "\\alpha&H"..al.."&" end end)
    :gsub("\\"..alf.."a&H(%x%x)&",function(a) if a>al then return "\\"..alf.."a&H"..a.."&" else return "\\"..alf.."a&H"..al.."&" end end)
    :gsub("(\\blur)[%d%.]*([\\}])","%1"..bl.."%2")
    :gsub("^({\\[^}]-)}","%1\\alpha&H"..al.."&}")
    :gsub("(\\r[^}]-)}","%1\\alpha&H"..al.."&}")
    if res.alfa=="00" then txt=txt:gsub("^({\\[^}]-)\\alpha&H00&","%1") end
    txt=txt:gsub("{}","")
    if res.glowcol then
	if txt:match("^{\\[^}]-\\"..kol.."&") then txt=txt:gsub("\\"..kol.."&H%x+&","\\"..kol..glowc)
	else txt=txt:gsub("\\"..kol.."&H%x+&","\\"..kol..glowc) txt=txt:gsub("^({\\[^}]-)}","%1\\"..kol..glowc.."}")
	end
    end
    return txt
end

function botalfa(txt)
    fadin,fadout=txt:match("\\fad%((%d+)%,(%d+)")
        if fadin~="0" then
	    txt=txt:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t("..fadin-res.alphade..","..fadin..",\\1a&H00&)}")
        end
        if fadout~="0" then
	    txt=txt:gsub("^({\\[^}]-)}","%1\\t("..duration-fadout..","..duration-fadout+res.alphade..",\\1a&HFF&)}")
        end
    return txt
end

function fixfade(subs, sel)
    for i=#sel,1,-1 do
	line=subs[sel[i]]
	text=subs[sel[i]].text
	styleref=stylechk(subs,line.style)
	duration=line.end_time-line.start_time
		border=tostring(styleref.outline)
		bord=text:match("\\bord([%d%.]+)")
		if bord~=nil then border=bord end
	
		if border~="0" and line.text:match("\\fad%(") then
		text=text:gsub("\\1a&[%w]+&","")
		text=text:gsub("\\t%([^%(%)]-%)","")
		
		fadin,fadout=line.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text=text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text=text:gsub("^({\\[^}]-)}","%1\\t(" .. duration-fadout .."," .. duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end
		
	line.text=text
	subs[sel[i]]=line
    end
    return sel
end

function layeraise(subs, sel)
    for i=#sel,1,-1 do
	line=subs[sel[i]]
	text=subs[sel[i]].text
		if line.layer+res["layer"]>=0 then
		line.layer=line.layer+res["layer"] else
		aegisub.dialog.display({{class="label",
		label="You're dumb. Layers can't go below 0.",x=0,y=0,width=1,height=2}},{"OK"})
		end
	subs[sel[i]]=line
    end
    return sel
end

function stylechk(stylename)
    for i=1,#styles do
	if stylename==styles[i].name then
	    styleref=styles[i]
	    if styles[i].name=="Default" then defaref=styles[i] end
	end
    end
    return styleref
end

function styleget(subs)
    styles={}
    for i=1, #subs do
        if subs[i].class=="style" then
	    table.insert(styles,subs[i])
	end
    end
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=1,width=1,height=1,class="label",label="Glow blur:" },
	    {	x=0,y=2,width=1,height=1,class="label",label="Glow alpha:" },
	    
	    {	x=1,y=1,width=1,height=1,class="floatedit",name="blur",value=glow_blur },
	    {	x=1,y=2,width=1,height=1,class="dropdown",name="alfa",
	    items={"00","20","30","40","50","60","70","80","90","A0","B0","C0","D0","F0"},value=glow_alpha },
	    
	    {	x=0,y=0,width=3,height=1,class="checkbox",name="double",label="double border        modifications:",value=false },
	    
	    {	x=3,y=0,width=1,height=1,class="checkbox",name="clr",label="2nd b. colour:",
						hint="Colour for 2nd border \nif different from primary." },
	    {	x=4,y=0,width=2,height=1,class="color",name="c3" },
	    
	    {	x=3,y=1,width=1,height=1,class="checkbox",name="bsize",label="2nd b. size:",
					hint="Size for 2nd border \n[counts from first border out] \nif different from the current border."},
	    {	x=4,y=1,width=2,height=1,class="floatedit",name="secbord",value=second_border_size },
	    
	    {	x=3,y=2,width=1,height=1,class="checkbox",name="bbl",label="bottom blur:",
					hint="Blur for bottom layer \n[not the glow layer] \nif different from top layer."},
	    {	x=4,y=2,width=2,height=1,class="floatedit",name="bblur",value=bottom_blur },
	    
	    {	x=0,y=3,width=4,height=1,class="checkbox",name="botalpha",label="fix \\1a for layers with border and fade --> transition:",
			value=fix_for_fades,hint="uses \\1a&HFF& for bottom layer during fade"},
	    {	x=4,y=3,width=1,height=1,class="dropdown",name="alphade",items={0,45,80,120},value=45 },
	    {	x=5,y=3,width=1,height=1,class="label",label="ms" },
	    
	    {	x=3,y=4,width=1,height=1,class="label",label="     Change layer:", },
	    {	x=4,y=4,width=1,height=1,class="dropdown",name="layer",
		items={"-5","-4","-3","-2","-1","+1","+2","+3","+4","+5"},value=change_layer },
		
	    {	x=0,y=4,width=1,height=1,class="checkbox",name="glowcol",label="glow c.:",value=false,hint="glow colour"},
	    {	x=1,y=4,width=1,height=1,class="color",name="glc" },
	    
	    {	x=5,y=4,width=1,height=1,class="checkbox",name="rep",label="repeat",value=false,hint="repeat with last settings"},
	    
	} 	
	buttons={"Blur / Layers","Blur + Glow","Fix fades","Change layer","cancel"}
	pressed, res=aegisub.dialog.display(dialog_config,buttons,{ok='Blur / Layers',cancel='cancel'})
	
	
	if pressed=="Blur / Layers" then repetition() styleget(subs) layerblur(subs, sel) end
	if pressed=="Blur + Glow" then repetition() styleget(subs) glow(subs, sel) end
	if pressed=="Fix fades" then repetition() styleget(subs) fixfade(subs, sel) end
	if pressed=="Change layer" then repetition() layeraise(subs, sel) end
	
	if res.rep==false then
	lastblur=res.blur
	lastalfa=res.alfa
	lastdouble=res.double
	lastclr=res.clr
	lastc3=res.c3
	lastbsize=res.bsize
	lastsecbord=res.secbord
	lastbbl=res.bbl
	lastbblur=res.bblur
	lastbotalpha=res.botalpha
	lastalphade=res.alphade
	lastlayer=res.layer
	lastglowcol=res.glowcol	
	end
end

function repetition()
	if res.rep==true then
	res.blur=lastblur
	res.alfa=lastalfa
	res.double=lastdouble
	res.clr=lastclr
	res.c3=lastc3
	res.bsize=lastbsize
	res.secbord=lastsecbord
	res.bbl=lastbbl
	res.bblur=lastbblur
	res.botalpha=lastbotalpha
	res.alphade=lastalphade
	res.layer=lastlayer
	res.glowcol=lastglowcol
	end
end

function blurandglow(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    if pressed=="Change layer" then return sel end
end

aegisub.register_macro(script_name, script_description, blurandglow)