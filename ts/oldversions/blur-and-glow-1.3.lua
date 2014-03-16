--[[	"Blur with Layers" is basically my simplified version of "Duplicate and Blur" that doesn't leave commented lines. 
	It supports 2 borders, xbord, ybord, shad, and yshad, but doesn't have the other modes D&B has.
	Also the script is not adjusted for transforms.
	
	"Blur and Glow" - Same as above but with an extra layer for glow. Set blur amount and alpha for the glow.
	
	The "double border" option works like in "Duplicate and Blur" but additionally lets you change the size and colour of the 2nd border.
	
	If blur is missing, \blur0.6 is added by default.
	
	"Bottom blur" allows you to use different blur for bottom [non-glow] layer than for top layer(s).
	
	"Fix layers with border for fading signs" - Uses \1a&HFF& for the duration of a fade on layers with border.
		"transition" - for \fad(500,0) with transition 80ms you get \1a&HFF&\t(420,500,\1a&H00&).
	
	"Change layer" - raises or lowers layer for all selected lines by the same amount. [This is separate from the other functions.]

]]

script_name = "Blur and Glow"
script_description = "Add blur and/or glow to signs"
script_author = "unanimated"
script_version = "1.3"

include("karaskel.lua")

function glow(subs, sel)
local meta,styles=karaskel.collect_head(subs,false)
    warning=0
    for i=#sel,1,-1 do
	local line = subs[sel[i]]
	text = subs[sel[i]].text
	karaskel.preproc_line(subs,meta,styles,line)
	if text:match("^{\\")==nil then warning=1
	else
	
	    if text:match("\\blur")==nil then
	    text=text:gsub("^{\\","{\\blur0.6\\") end			-- default blur if missing in tags
	    if text:match("\\blur") and text:match("^{\\") and text:match("^{\\[^}]*blur[^}]*}")==nil then
	    text=text:gsub("^{\\","{\\blur0.6\\") end			-- add blur if missing in first block of tags
	    line.text=text
	    
	    -- get colors, border, shadow from style
	    	primary=line.styleref.color1
		primary=primary:gsub("H%x%x","H")
		pri=text:match("\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		soutline=line.styleref.color3
		soutline=soutline:gsub("H%x%x","H")
		outline=soutline
		out=text:match("\\3c(&H%x+&)")
		if out~=nil then outline=out end
		
		border=tostring(line.styleref.outline)
		bord=text:match("\\bord([%d%.]+)")
		if bord~=nil then border=bord end
		
		shadow=tostring(line.styleref.shadow)
		shad=text:match("\\shad([%d%.]+)")
		if shad~=nil then shadow=shad end
		
--		line.effect="done"
		
	    if border~="0" or text:match("\\[xy]bord") then	--
	    
	    
	    -- with two borders
	    
		-- \t workaround
	    if text:match("^({\\[^}]-\\t)[^}]-}") then
		if text:match("^({\\[^}]-\\3c[^}]-\\t")==nil then text=text:gsub("^({\\","{\\3c"..soutline.."\\") end
		line.text=text
	    end
	    
	  if res["double"] then	

		-- second border
		
		outlinetwo=primary
		if res["clr"] then col3=res["c3"]
		col3=col3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
		outlinetwo=col3
		end
		
		bordertwo=border
		if res["bsize"] then
		bordertwo=res["secbord"]
		end
		
	    line1=line	
	    line1.text=text
	    if line1.text:match("\\bord")==nil then
	    line1.text=line1.text:gsub("^{\\","{\\bord"..border+bordertwo.."\\") else
	    line1.text=line1.text:gsub("\\bord[%d%.]+","\\bord"..border+bordertwo)
	    end
	    if line1.text:match("\\[xy]bord") then
		line1.text=line1.text:gsub("\\xbord([%d%.]+)",function(a) return "\\xbord"..a+a end)
		line1.text=line1.text:gsub("\\ybord([%d%.]+)",function(a) return "\\ybord"..a+a end)
	    end	    
	    
		if line1.text:match("\\3c&") then line1.text=line1.text:gsub("(\\3c)(&H%x+&)","%1"..outlinetwo.."")
		else line1.text=line1.text:gsub("^({\\[^}]+)}","%1\\3c"..outlinetwo.."}")
		end
		line1.text=line1.text:gsub("(\\r[^\\}]+)}","%1\\blur0.6}")
		if res.bbl then line1.text=line1.text:gsub("\\blur[%d%.]+","\\blur"..res.bblur) end
		
		if res.botalpha and line1.text:match("\\fad%(") then
		fadin,fadout = line1.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	line1.text = line1.text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	line1.text = line1.text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout .."," .. line.duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end		
		
	    line1.layer=line1.layer+1
	    line1.text=line1.text:gsub("{}","")
	    subs.insert(sel[i]+1,line1)

		-- first border
	    line2=line
	    line2.text=text
	    if shadow~="0" and line2.text:match("\\shad")==nil then
	    line2.text=line2.text:gsub("^{\\","{\\shad0\\")
	    end
    	    if shadow~="0" and line2.text:match("\\shad") then
	    line2.text=line2.text:gsub("\\shad[%d%.]+","\\shad0")
	    end
	    line2.text=line2.text:gsub("(\\[xy]shad)[%d%.%-]+","%10")
		line2.text=line2.text:gsub("\\1?c&H%x+&","")
		if line2.text:match("^{\\[^}]-\\3c&[^}]-}")==nil then
		line2.text=line2.text:gsub("^({\\[^}]+)}","%1\\c"..soutline.."}")
		end
		line2.text=line2.text:gsub("(\\3c)(&H%x+&)","%1%2\\c%2")
		line2.text=line2.text:gsub("(\\r[^\\}]+)}","%1\\blur0.6}")
		
		if res.botalpha and line2.text:match("\\fad%(") then
		fadin,fadout = line2.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	line2.text = line2.text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	line2.text = line2.text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout .."," .. line.duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end		
		
	    line2.layer=line2.layer+1
	    line2.text=line2.text:gsub("{}","")
	    subs.insert(sel[i]+2,line2)
	    
		-- top line
	    line3=line
	    line3.text=text
	    if line3.text:match("\\bord") then
	    line3.text=line3.text:gsub("\\bord[%d%.]+","\\bord0") else
	    line3.text=line3.text:gsub("^{\\","{\\bord0\\") end
	    line3.text=line3.text:gsub("(\\[xy]bord)[%d%.]+","%10")
	    line3.text=line3.text:gsub("(\\[xy]shad)[%d%.%-]+","%10")
	    if shadow~="0" then line3.text=line3.text:gsub("^({\\[^}]+)}","%1\\shad0}") end
	    line3.text=line3.text:gsub("(\\r[^\\}]+)}","%1\\bord0\\shad0\\blur0.6}")
	    line3.layer=line3.layer+1
	    line3.text=line3.text:gsub("{}","")
	    subs.insert(sel[i]+3,line3)

		-- bottom / glow
		if text:match("\\3c&") then text=text:gsub("(\\3c)(&H%x+&)","%1"..outlinetwo.."")
		else text=text:gsub("^({\\[^}]+)}","%1\\3c"..outlinetwo.."}")
		end
	    if text:match("\\bord")==nil then
	    text=text:gsub("^{\\","{\\bord"..border+bordertwo.."\\") else
	    text=text:gsub("\\bord[%d%.]+","\\bord"..border+bordertwo)	    
	    end
    	    if text:match("\\[xy]bord") then
		text=text:gsub("\\xbord([%d%.]+)",function(a) return "\\xbord"..a+a end)
		text=text:gsub("\\ybord([%d%.]+)",function(a) return "\\ybord"..a+a end)
	    end	
	    text=text:gsub("(\\blur)[%d%.]*([\\}])","%1"..res["blur"].."\\alpha&H"..res["alfa"].."&%2")
	    
		if res.botalpha and line.text:match("\\fad%(") then
		fadin,fadout = line.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout .."," .. line.duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end	    
	    
	    line.layer=line.layer-3
	    text=text:gsub("{}","")
	    line.text = text

	  else
	  
	    -- with one border
	    
		-- \t workaround
	    if text:match("^({\\[^}]-\\t)[^}]-}") then
		if text:match("^({\\[^}]-\\3c[^}]-\\t")==nil then text=text:gsub("^({\\","{\\3c"..soutline.."\\") end
		line.text=text
	    end
	    
		-- border
	    line2=line
	    text2=line2.text
		text2=text2:gsub("\\1?c&H%x+&","")
		if text2:match("^{\\[^}]-\\3c&[^}]-}")==nil then
		text2=text2:gsub("^({\\[^}]+)}","%1\\c"..soutline.."}")
		end
		text2=text2:gsub("(\\3c)(&H%x+&)","%1%2\\c%2")
		text2=text2:gsub("(\\r[^\\}]+)}","%1\\blur0.6}")
		
		if res.botalpha and text2:match("\\fad%(") then
		fadin,fadout = text2:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text2 = text2:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text2 = text2:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout .."," .. line.duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end
		
	    line2.text=text2
	    line2.layer=line2.layer+1
	    line2.text=line2.text:gsub("{}","")
	    if res.bbl then line2.text=line2.text:gsub("\\blur[%d%.]+","\\blur"..res.bblur) end
	    subs.insert(sel[i]+1,line2)
	    
		-- top line
	    line3=line
	    line3.text=text
	    if line3.text:match("\\bord") then
	    line3.text=line3.text:gsub("\\bord[%d%.]+","\\bord0") else
	    line3.text=line3.text:gsub("^{\\","{\\bord0\\") end
	    line3.text=line3.text:gsub("(\\[xy]bord)[%d%.]+","%10")
	    line3.text=line3.text:gsub("(\\[xy]shad)[%d%.%-]+","%10")
	    if shadow~="0" then line3.text=line3.text:gsub("^({\\[^}]+)}","%1\\shad0}") end
	    line3.text=line3.text:gsub("(\\r[^\\}]+)}","%1\\bord0\\shad0\\blur0.6}")
	    line3.layer=line3.layer+1
	    line3.text=line3.text:gsub("{}","")
	    subs.insert(sel[i]+2,line3)
	    
		-- bottom / glow
	    text=text:gsub("(\\blur)[%d%.]*([\\}])","%1"..res["blur"].."\\alpha&H"..res["alfa"].."&%2")
	    
		if res.botalpha and line.text:match("\\fad%(") then
		fadin,fadout = line.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout .."," .. line.duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end
		
	    line.layer=line.layer-2
	    text=text:gsub("{}","")
	    line.text = text
	    
	  end
	    
	    else

	    
	    -- without border
	    line2=line
	    line2.layer=line2.layer+1
	    subs.insert(sel[i]+1,line2)
	    text=text:gsub("(\\blur)[%d%.]*([\\}])","%1"..res["blur"].."\\alpha&H"..res["alfa"].."&%2")
	    line.layer=line.layer-1
	    line.text = text
	    end
	    
	end    
	subs[sel[i]] = line
    end
    if warning==1 then
    aegisub.dialog.display({{class="label",
		    label="Lines with no tags? What are you doing?",x=0,y=0,width=1,height=2}},{"OK"}) end
end

function layerblur(subs, sel)
local meta,styles=karaskel.collect_head(subs,false)
    warning=0
    for i=#sel,1,-1 do
	local line = subs[sel[i]]
	text = subs[sel[i]].text
	karaskel.preproc_line(subs,meta,styles,line)
	if text:match("^{\\")==nil then warning=1
	else
	
	    if text:match("\\blur")==nil then
	    text=text:gsub("^{\\","{\\blur0.6\\") end			-- default blur if missing in tags
	    if text:match("\\blur") and text:match("^{\\") and text:match("^{\\[^}]*blur[^}]*}")==nil then
	    text=text:gsub("^{\\","{\\blur0.6\\") end			-- add blur if missing in first block of tags
	    
	    line.text=text
	    
	    -- get colors, border, shadow from style
	    	primary=line.styleref.color1
		primary=primary:gsub("H%x%x","H")
		pri=text:match("\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		soutline=line.styleref.color3
		soutline=soutline:gsub("H%x%x","H")
		outline=soutline
		out=text:match("\\3c(&H%x+&)")
		if out~=nil then outline=out end
		
		border=tostring(line.styleref.outline)
		bord=text:match("\\bord([%d%.]+)")
		if bord~=nil then border=bord end
		
		shadow=tostring(line.styleref.shadow)
		shad=text:match("\\shad([%d%.]+)")
		if shad~=nil then shadow=shad end
		
--		line.effect="done"
	
	    if res["double"] then
	    
	    -- two borders
	    
		-- \t workaround
	    if text:match("^({\\[^}]-\\t)[^}]-}") then
		if text:match("^({\\[^}]-\\3c[^}]-\\t")==nil then text=text:gsub("^({\\","{\\3c"..soutline.."\\") end
		line.text=text
	    end

		-- first border
	    line2=line
	    text2=line2.text
	    if shadow~="0" and text2:match("\\shad")==nil then
	    text2=text2:gsub("^{\\","{\\shad0\\")
	    end
    	    if shadow~="0" and text2:match("\\shad") then
	    text2=text2:gsub("\\shad[%d%.]+","\\shad0")
	    end
	    text2=text2:gsub("(\\[xy]shad)[%d%.%-]+","%10")
		text2=text2:gsub("\\1?c&H%x+&","")
		if text2:match("^{\\[^}]-\\3c&[^}]-}")==nil then
		text2=text2:gsub("^({\\[^}]+)}","%1\\c"..soutline.."}")
		end
		text2=text2:gsub("(\\3c)(&H%x+&)","%1%2\\c%2")
		text2=text2:gsub("(\\r[^\\}]+)}","%1\\blur0.6}")
		
		if res.botalpha and text2:match("\\fad%(") then
		fadin,fadout = text2:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text2 = text2:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text2 = text2:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout .."," .. line.duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end
		
	    line2.text=text2
	    line2.layer=line2.layer+1
	    line2.text=line2.text:gsub("{}","")
	    subs.insert(sel[i]+1,line2)
		
		-- top line
	    line3=line
	    line3.text=text
	    if shadow~="0" then 
		if line3.text:match("\\shad") then
		line3.text=line3.text:gsub("\\shad[%d%.]+","\\shad0") else
		line3.text=line3.text:gsub("^{\\","{\\shad0\\") 
		end
	    end
	    
       	    if line3.text:match("\\bord") then
	    line3.text=line3.text:gsub("\\bord[%d%.]+","\\bord0") else
	    line3.text=line3.text:gsub("^{\\","{\\bord0\\") end
	    line3.text=line3.text:gsub("\\[xy]bord[%d%.]+","")
	    line3.text=line3.text:gsub("\\[xy]shad[%d%.%-]+","")
	    line3.text=line3.text:gsub("(\\r[^\\}]+)}","%1\\bord0\\shad0\\blur0.6}")
	    line3.layer=line3.layer+1
	    line3.text=line3.text:gsub("{}","")
	    subs.insert(sel[i]+2,line3)
		
		-- second border
		
		outlinetwo=primary
		if res["clr"] then col3=res["c3"]
		col3=col3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
		outlinetwo=col3
		end
		
		bordertwo=border
		if res["bsize"] then
		bordertwo=res["secbord"]
		end
		
	    if text:match("\\bord")==nil then
	    text=text:gsub("^{\\","{\\bord"..border+bordertwo.."\\") else
	    text=text:gsub("\\bord[%d%.]+","\\bord"..border+bordertwo)
	    end
	    if text:match("\\[xy]bord") then
		text=text:gsub("\\xbord([%d%.]+)",function(a) return "\\xbord"..a+a end)
		text=text:gsub("\\ybord([%d%.]+)",function(a) return "\\ybord"..a+a end)
	    end	    
	    
		if text:match("\\3c&") then text=text:gsub("(\\3c)(&H%x+&)","%1"..outlinetwo.."")
		else text=text:gsub("^({\\[^}]+)}","%1\\3c"..outlinetwo.."}")
		end
		text=text:gsub("(\\r[^\\}]+)}","%1\\blur0.6}")
		if res.bbl then text=text:gsub("\\blur[%d%.]+","\\blur"..res.bblur) end
		
		if res.botalpha and line.text:match("\\fad%(") then
		fadin,fadout = line.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout .."," .. line.duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end
		
	    line.layer=line.layer-2
	    text=text:gsub("{}","")
	    line.text = text
	    
	    else
	    
	    -- one border [regular Duplicate and Blur stuff]
		-- \t workaround
	    if text:match("^({\\[^}]-\\t)[^}]-}") then
		if text:match("^{\\[^}]-\\3c[^}]-\\t")==nil then text=text:gsub("^{\\","{\\3c"..soutline.."\\") end
		line.text=text
	    end
	    
		-- top line
	    line3=line
	    line3.text=text
	    if line3.text:match("\\bord")==nil then
	    line3.text=line3.text:gsub("^{\\","{\\bord0\\") else
	    line3.text=line3.text:gsub("\\bord[%d%.]+","\\bord0") end
	    if shadow~="0" then 
		if line3.text:match("\\shad") then
		line3.text=line3.text:gsub("\\shad[%d%.]+","\\shad0") else
		line3.text=line3.text:gsub("^{\\","{\\shad0\\") 
		end
	    end
	    line3.text=line3.text:gsub("\\[xy]bord[%d%.]+","")
	    line3.text=line3.text:gsub("\\[xy]shad[%d%.%-]+","")
		line3.text=line3.text:gsub("(\\r[^\\}]+)}","%1\\bord0\\shad0\\blur0.6}")	-- top line \r
	    line3.layer=line3.layer+1
	    line3.text=line3.text:gsub("{}","")
	    subs.insert(sel[i]+1,line3)
	    
		-- bottom line
		text=text:gsub("\\1?c&H%x+&","")
		if text:match("^{\\[^}]-\\3c&[^}]-}")==nil then
		text=text:gsub("^({\\[^}]+)}","%1\\c"..soutline.."}")
		end
		text=text:gsub("(\\3c)(&H%x+&)","%1%2\\c%2")
		text=text:gsub("(\\r[^\\}]+)}","%1\\blur0.6}")					-- bottom line \r
		if res.bbl then text=text:gsub("\\blur[%d%.]+","\\blur"..res.bblur) end
		
		if res.botalpha and line.text:match("\\fad%(") then
		fadin,fadout = line.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text = text:gsub("^({\\[^}]-)}","%1\\t(" .. line.duration-fadout .."," .. line.duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end

	    line.layer=line.layer-1
	    text=text:gsub("{}","")
	    line.text = text
	    end
	end    
	subs[sel[i]] = line
    end
    if warning==1 then
    aegisub.dialog.display({{class="label",
		    label="Lines with no tags? What are you doing?",x=0,y=0,width=1,height=2}},{"OK"}) end
end

function layeraise(subs, sel)
    for i=#sel,1,-1 do
	line = subs[sel[i]]
	text = subs[sel[i]].text
		if line.layer+res["layer"]>=0 then
		line.layer=line.layer+res["layer"] else
		aegisub.dialog.display({{class="label",
		label="You're dumb. Layers can't go below 0.",x=0,y=0,width=1,height=2}},{"OK"})
		end
	subs[sel[i]] = line
    end
    return sel
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=1,width=1,height=1,class="label",label="Glow blur:" },
	    {	x=0,y=2,width=1,height=1,class="label",label="Glow alpha:" },
	    
	    {	x=1,y=1,width=1,height=1,class="floatedit",name="blur",value="3" },				-- default glow
	    {	x=1,y=2,width=1,height=1,class="dropdown",name="alfa",
	    items={"00","20","30","40","50","60","70","80","90","A0","B0","C0","D0","F0"},value="80" },	-- default alpha
	    
	    {	x=0,y=0,width=2,height=1,class="checkbox",name="double",label="double border        modifications:",value=false },
	    
	    {	x=2,y=0,width=1,height=1,class="checkbox",name="clr",label="2nd b. col.:",
						hint="Colour for 2nd border \nif different from primary." },
	    {	x=3,y=0,width=2,height=1,class="color",name="c3" },
	    
	    {	x=2,y=1,width=1,height=1,class="checkbox",name="bsize",label="2nd b. size:",
					hint="Size for 2nd border \n[counts from first border out] \nif different from the current border."},
	    {	x=3,y=1,width=2,height=1,class="floatedit",name="secbord",value="2" },			-- default 2nd border
	    
	    {	x=2,y=2,width=1,height=1,class="checkbox",name="bbl",label="bottom blur:",
					hint="Blur for bottom layer \n[not the glow layer] \nif different from top layer."},
	    {	x=3,y=2,width=2,height=1,class="floatedit",name="bblur",value="1" },			-- default bottom blur
	    
	    {	x=0,y=3,width=3,height=1,class="checkbox",name="botalpha",label="fix layers with border for fading signs -> transition:",
			value=true,hint="uses \\1a&HFF& for bottom layer during fade"},
	    {	x=3,y=3,width=1,height=1,class="dropdown",name="alphade",items={0,45,80,120},value=45 },
	    {	x=4,y=3,width=1,height=1,class="label",label="ms" },
	    
	    {	x=2,y=4,width=1,height=1,class="label",label="Change layer:", },
	    {	x=3,y=4,width=1,height=1,class="dropdown",name="layer",
		items={"-5","-4","-3","-2","-1","+1","+2","+3","+4","+5"},value="+1" },
	    
	} 	
	buttons={"Blur with Layers","Blur and Glow","Change layer","cancel"}
	pressed, res = aegisub.dialog.display(dialog_config,buttons)
	if pressed=="Blur with Layers" then layerblur(subs, sel) end
	if pressed=="Blur and Glow" then glow(subs, sel) end
	if pressed=="Change layer" then layeraise(subs, sel) end
end

function blurandglow(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    if pressed=="Change layer" then return sel end
end

aegisub.register_macro(script_name, script_description, blurandglow)