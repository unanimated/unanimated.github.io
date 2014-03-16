--[[	"Blur with Layers" is basically my simplified version of "Duplicate and Blur" that doesn't leave commented lines. 
	It supports 2 borders, xbord, ybord, shad, and yshad, but doesn't have the other modes D&B has.
	Also the script is not adjusted for transforms.
	
	"Blur and Glow" - Same as above but with an extra layer for glow. Set blur amount and alpha for the glow.
	
	The "double border" option works like in "Duplicate and Blur" but additionally lets you change the size and colour of the 2nd border.
	
	If blur is missing, \blur0.6 is added by default.
	
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
script_version="1.8"

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
    if not res.rep then al=res.alfa end
    if not res.rep then bl=res.blur end
    if automatically_use_double_border then if res.clr or res.bsize then res.double=true end end
    for i=#sel,1,-1 do
	local line=subs[sel[i]]
	text=subs[sel[i]].text
	styleref=stylechk(subs,line.style)
	duration=line.end_time-line.start_time
	if not text:match("^{\\") then text="{\\blur"..default_blur.."}"..text end
	
	    if not text:match("\\blur") then text=text:gsub("^{\\","{\\blur"..default_blur.."\\") end	-- default blur if missing in tags
	    if text:match("\\blur") and text:match("^{\\") and not text:match("^{\\[^}]*blur[^}]*}") then
	    text=text:gsub("^{\\","{\\blur"..default_blur.."\\") end					-- add blur if missing in first block of tags
	    line.text=text
	    
	    -- get colors, border, shadow from style
	    	primary=styleref.color1
		primary=primary:gsub("H%x%x","H")
		pri=text:match("\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		soutline=styleref.color3
		soutline=soutline:gsub("H%x%x","H")
		outline=soutline
		out=text:match("\\3c(&H%x+&)")
		if out~=nil then outline=out end
		
		border=tostring(styleref.outline)
		bord=text:match("\\bord([%d%.]+)")
		if bord~=nil then border=bord end
		
		shadow=tostring(styleref.shadow)
		shad=text:match("\\shad([%d%.]+)")
		if shad~=nil then shadow=shad end
		
		if res.glowcol then glowc=res.glc:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&") end	--aegisub.log(" "..glowc)
		
--		line.effect="done"
		
	    if border~="0" or text:match("\\[xy]bord") then	--
	    
	    
	    -- with two borders
	    
		-- \t workaround
	    if text:match("^({\\[^}]-\\t)[^}]-}") then
		if text:match("^{\\[^}]-\\3c[^}]-\\t")==nil then text=text:gsub("^({\\","{\\3c"..soutline.."\\") end
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
		fadin,fadout=line1.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	line1.text=line1.text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	line1.text=line1.text:gsub("^({\\[^}]-)}","%1\\t(" .. duration-fadout .."," .. duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end		
		
	    line1.layer=line1.layer+1
	    line1.text=line1.text:gsub("{}","")
	    subs.insert(sel[i]+1,line1)

		-- first border
	    line2=line
	    line2.text=text
	    if shadow~="0" then line2.text=line2.text:gsub("^({\\[^}]+)}","%1\\shad0}") end
	    line2.text=line2.text:gsub("\\shad[%d%.%-]+([^}]-)(\\shad[%d%.%-]+)","%1%2")
	    line2.text=line2.text:gsub("(\\[xy]shad)[%d%.%-]+","%10")
		line2.text=line2.text:gsub("\\1?c&H%x+&","")
		if line2.text:match("^{\\[^}]-\\3c&[^}]-}")==nil then
		line2.text=line2.text:gsub("^({\\[^}]+)}","%1\\c"..soutline.."}")
		end
		line2.text=line2.text:gsub("(\\3c)(&H%x+&)","%1%2\\c%2")
		line2.text=line2.text:gsub("(\\r[^\\}]+)}","%1\\blur0.6}")
		
		if res.botalpha and line2.text:match("\\fad%(") then
		fadin,fadout=line2.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	line2.text=line2.text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	line2.text=line2.text:gsub("^({\\[^}]-)}","%1\\t(" .. duration-fadout .."," .. duration-fadout+res.alphade .. ",\\1a&HFF&)}")
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
	    line3.text=line3.text:gsub("\\shad[%d%.%-]+([^}]-)(\\shad[%d%.%-]+)","%1%2")
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
	    text=text:gsub("\\alpha&H(%x%x)&",function(a) if a>al then return "\\alpha&H"..a.."&" else return "\\alpha&H"..al.."&" end end)
	    text=text:gsub("\\3a&H(%x%x)&",function(a) if a>al then return "\\3a&H"..a.."&" else return "\\3a&H"..al.."&" end end)
	    text=text:gsub("(\\blur)[%d%.]*([\\}])","%1"..bl.."%2")
	    text=text:gsub("^({\\[^}]-)}","%1\\alpha&H"..al.."&}")
	    if res.alfa=="00" then text=text:gsub("^({\\[^}]-)\\alpha&H00&","%1") end
	    
		if res.botalpha and line.text:match("\\fad%(") then
		fadin,fadout=line.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text=text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text=text:gsub("^({\\[^}]-)}","%1\\t(" .. duration-fadout .."," .. duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end
		if res.glowcol then
		    if text:match("^{\\[^}]-\\3c&") then text=text:gsub("\\3c&H%x+&","\\3c"..glowc)
		    else text=text:gsub("\\3c&H%x+&","\\3c"..glowc) text=text:gsub("^({\\[^}]-)}","%1\\3c"..glowc.."}")
		    end
		end
	    
	    line.layer=line.layer-3
	    text=text:gsub("{}","")
	    line.text=text

	  else
	  
	    -- with one border
	    
		-- \t workaround
	    if text:match("^({\\[^}]-\\t)[^}]-}") then
		if text:match("^{\\[^}]-\\3c[^}]-\\t")==nil then text=text:gsub("^({\\","{\\3c"..soutline.."\\") end
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
		fadin,fadout=text2:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text2=text2:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text2=text2:gsub("^({\\[^}]-)}","%1\\t(" .. duration-fadout .."," .. duration-fadout+res.alphade .. ",\\1a&HFF&)}")
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
	    line3.text=line3.text:gsub("\\shad[%d%.%-]+([^}]-)(\\shad[%d%.%-]+)","%1%2")
	    line3.text=line3.text:gsub("(\\r[^\\}]+)}","%1\\bord0\\shad0\\blur0.6}")
	    line3.layer=line3.layer+1
	    line3.text=line3.text:gsub("{}","")
	    subs.insert(sel[i]+2,line3)
	    
		-- bottom / glow
	    text=text:gsub("\\alpha&H(%x%x)&",function(a) if a>al then return "\\alpha&H"..a.."&" else return "\\alpha&H"..al.."&" end end)
	    text=text:gsub("\\3a&H(%x%x)&",function(a) if a>al then return "\\3a&H"..a.."&" else return "\\3a&H"..al.."&" end end)
	    text=text:gsub("(\\blur)[%d%.]*([\\}])","%1"..bl.."%2")
	    text=text:gsub("^({\\[^}]-)}","%1\\alpha&H"..al.."&}")
	    if res.alfa=="00" then text=text:gsub("^({\\[^}]-)\\alpha&H00&","%1") end
	    
		if res.botalpha and line.text:match("\\fad%(") then
		fadin,fadout=line.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text=text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text=text:gsub("^({\\[^}]-)}","%1\\t(" .. duration-fadout .."," .. duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end
		if res.glowcol then
		    if text:match("^{\\[^}]-\\3c&") then text=text:gsub("\\3c&H%x+&","\\3c"..glowc)
		    else text=text:gsub("\\3c&H%x+&","\\3c"..glowc) text=text:gsub("^({\\[^}]-)}","%1\\3c"..glowc.."}")
		    end
		end
	    line.layer=line.layer-2
	    text=text:gsub("{}","")
	    line.text=text
	    
	  end
	    
	    else

	    
	    -- without border
	    line2=line
	    line2.layer=line2.layer+1
	    subs.insert(sel[i]+1,line2)
	    text=text:gsub("\\alpha&H(%x%x)&",function(a) if a>al then return "\\alpha&H"..a.."&" else return "\\alpha&H"..al.."&" end end)
	    text=text:gsub("\\1a&H(%x%x)&",function(a) if a>al then return "\\1a&H"..a.."&" else return "\\1a&H"..al.."&" end end)
	    text=text:gsub("(\\blur)[%d%.]*([\\}])","%1"..bl.."%2")
	    text=text:gsub("^({\\[^}]-)}","%1\\alpha&H"..al.."&}")
	    if res.alfa=="00" then text=text:gsub("^({\\[^}]-)\\alpha&H00&","%1") end
	    if res.glowcol then
		if text:match("^{\\[^}]-\\1?c&") then text=text:gsub("\\1?c&H%x+&","\\c"..glowc)
		else text=text:gsub("\\1?c&H%x+&","\\c"..glowc) text=text:gsub("^({\\[^}]-)}","%1\\c"..glowc.."}")
		end
	    end
	    line.layer=line.layer-1
	    line.text=text
	    end
	    
	    text=text:gsub("\\\\","\\")
	    text=text:gsub("\\}","}")
	    text=text:gsub("{%*?}","")	
	subs[sel[i]]=line
    end
end

function layerblur(subs, sel)
    if automatically_use_double_border then if res.clr or res.bsize then res.double=true end end
    for i=#sel,1,-1 do
	local line=subs[sel[i]]
	text=subs[sel[i]].text
	styleref=stylechk(subs,line.style)
	duration=line.end_time-line.start_time
	if not text:match("^{\\") then text="{\\blur"..default_blur.."}"..text end
	
	    if text:match("\\blur")==nil then
	    text=text:gsub("^{\\","{\\blur"..default_blur.."\\") end			-- default blur if missing in tags
	    if text:match("\\blur") and text:match("^{\\") and text:match("^{\\[^}]*blur[^}]*}")==nil then
	    text=text:gsub("^{\\","{\\blur"..default_blur.."\\") end			-- add blur if missing in first block of tags
	    
	    line.text=text
	    
	    -- get colors, border, shadow from style
	    	primary=styleref.color1
		primary=primary:gsub("H%x%x","H")
		pri=text:match("\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		soutline=styleref.color3
		soutline=soutline:gsub("H%x%x","H")
		outline=soutline
		out=text:match("\\3c(&H%x+&)")
		if out~=nil then outline=out end
		
		border=tostring(styleref.outline)
		bord=text:match("\\bord([%d%.]+)")
		if bord~=nil then border=bord end
		
		shadow=tostring(styleref.shadow)
		shad=text:match("\\shad([%d%.]+)")
		if shad~=nil then shadow=shad end
		
--		line.effect="done"
	
	    if res["double"] then
	    
	    -- two borders
	    
		-- \t workaround
	    if text:match("^({\\[^}]-\\t)[^}]-}") then
		if text:match("^{\\[^}]-\\3c[^}]-\\t")==nil then text=text:gsub("^({\\","{\\3c"..soutline.."\\") end
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
		fadin,fadout=text2:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text2=text2:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text2=text2:gsub("^({\\[^}]-)}","%1\\t(" .. duration-fadout .."," .. duration-fadout+res.alphade .. ",\\1a&HFF&)}")
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
		fadin,fadout=line.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text=text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text=text:gsub("^({\\[^}]-)}","%1\\t(" .. duration-fadout .."," .. duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end
		
	    line.layer=line.layer-2
	    text=text:gsub("{}","")
	    line.text=text
	    
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
		fadin,fadout=line.text:match("\\fad%((%d+)%,(%d+)")
		    if fadin~="0" then
	text=text:gsub("^({\\[^}]-)}","%1\\1a&HFF&\\t(".. fadin-res.alphade .."," .. fadin ..",\\1a&H00&)}")
		    end
		    if fadout~="0" then
	text=text:gsub("^({\\[^}]-)}","%1\\t(" .. duration-fadout .."," .. duration-fadout+res.alphade .. ",\\1a&HFF&)}")
		    end
		end

	    line.layer=line.layer-1
	    text=text:gsub("\\\\","\\")
	    text=text:gsub("\\}","}")
	    text=text:gsub("{%*?}","")
	    line.text=text
	    end
	subs[sel[i]]=line
    end
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

function stylechk(subs,stylename)
    for i=1, #subs do
        if subs[i].class=="style" then
	    local style=subs[i]
	    if stylename==style.name then
		styleref=style	    
	    end
	end
    end
    return styleref
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
	pressed, res=aegisub.dialog.display(dialog_config,buttons,{cancel='cancel'})
	
	
	if pressed=="Blur / Layers" then repetition() layerblur(subs, sel) end
	if pressed=="Blur + Glow" then repetition() glow(subs, sel) end
	if pressed=="Fix fades" then repetition() fixfade(subs, sel) end
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