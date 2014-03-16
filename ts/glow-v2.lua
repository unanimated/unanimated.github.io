-- if there's no border, 2 layers are created. top is the original, bottom has the blur/alpha you set.
-- if there's border, 3 layers are created. top is without border, middle has primary colour changed to match outline, bottom has glow.
-- if there's no blur, \blur0.6 is added to top layer(s). if there are no tags at all, you should probably quit.
-- "Apply 2layer blur" is basically my simplified version of "Duplicate and Blur" that doesn't leave commented lines. 
-- It supports 2 borders, xbord, ybord, shad, and yshad, but doesn't have the other modes D&B has.

script_name = "Add glow v2"
script_description = "Add glow to signs"
script_author = "unanimated"
script_version = "2.1"

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
	    text=text:gsub("^{\\","{\\blur0.6\\") end
	    line.text=text
	    
	    -- get colors, border, shadow from style
	    	primary=line.styleref.color1
		primary=primary:gsub("H%d%d","H")
		pri=text:match("\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		outline=line.styleref.color3
		outline=outline:gsub("H%d%d","H")
		out=text:match("\\3c(&H%x+&)")
		if out~=nil then outline=out end
		
		border=line.styleref.outline
		bord=text:match("\\bord([%d%.]+)")
		if bord~=nil then border=bord end
		
		shadow=line.styleref.shadow
		shad=text:match("\\shad([%d%.]+)")
		if shad~=nil then shadow=shad end
		
	    if border~="0" or text:match("\\[xy]bord")==nil then
	    
	    -- with border
	    
		-- border
	    line2=line
	    text2=line2.text
--[[	    if shadow~=0 and text2:match("\\shad")==nil then
	    text2=text2:gsub("^{\\","{\\shad"..shadow.."\\")
	    end
	    if text2:match("\\bord")==nil then
	    text2=text2:gsub("^{\\","{\\bord"..border.."\\")
	    end	]]
		if text2:match("\\1?c&") then text2=text2:gsub("(\\1?c)(&H%d+&)","%1"..outline.."")
		else text2=text2:gsub("^({\\[^}]+)}","%1\\c"..outline.."}")
		end
	    line2.text=text2
	    line2.layer=line2.layer+1
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
	    line3.layer=line3.layer+1
	    subs.insert(sel[i]+2,line3)
	    
		-- bottom / glow
	    text=text:gsub("(\\blur)[%d%.]*([\\}])","%1"..res["blur"].."\\alpha&H"..res["alfa"].."&%2")
	    line.layer=line.layer-2
	    line.text = text
	    
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
	    text=text:gsub("^({\\[^}]+)}","%1\\blur0.6}") end
	    line.text=text
	    
	    -- get colors, border, shadow from style
	    	primary=line.styleref.color1
		primary=primary:gsub("H%d%d","H")
		pri=text:match("\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		outline=line.styleref.color3
		outline=outline:gsub("H%d%d","H")
		out=text:match("\\3c(&H%x+&)")
		if out~=nil then outline=out end
		
		border=line.styleref.outline
		bord=text:match("\\bord([%d%.]+)")
		if bord~=nil then border=bord end
		
		shadow=line.styleref.shadow
		shad=text:match("\\shad([%d%.]+)")
		if shad~=nil then shadow=shad end
	
	  if border~="0" then
	
	    if res["double"] then
	    
	    -- two borders
	    
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
		if text2:match("\\1?c&") then text2=text2:gsub("(\\1?c)(&H%d+&)","%1"..outline.."")
		else text2=text2:gsub("^({\\[^}]+)}","%1\\c"..outline.."}")
		end
	    line2.text=text2
	    line2.layer=line2.layer+1
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
	    line3.text=line3.text:gsub("(\\[xy]bord)[%d%.]+","%10")
	    line3.text=line3.text:gsub("(\\[xy]shad)[%d%.%-]+","%10")
	    line3.layer=line3.layer+1
	    subs.insert(sel[i]+2,line3)
		
		-- second border
	--    line.text = text
	    if text:match("\\bord")==nil then
	    text=text:gsub("^{\\","{\\bord"..border+border.."\\") else
	    text=text:gsub("\\bord[%d%.]+","\\bord"..border+border)
	    end
	    if text:match("\\[xy]bord") then
		text=text:gsub("\\xbord([%d%.]+)",function(a) return "\\xbord"..a+a end)
		text=text:gsub("\\ybord([%d%.]+)",function(a) return "\\ybord"..a+a end)
	    end	    
	    
		if text:match("\\3c&") then text=text:gsub("(\\3c)(&H%d+&)","%1"..primary.."")
		else text=text:gsub("^({\\[^}]+)}","%1\\3c"..primary.."}")
		end
	    line.layer=line.layer-2
	    line.text = text
	    
	    else
	    
	    -- one border
	    
		-- top line
	    line3=line
	    line3.text=text
	    line3.text=line3.text:gsub("^({\\[^}]+)}","%1\\bord0}")
	    if shadow~="0" then line3.text=line3.text:gsub("^({\\[^}]+)}","%1\\shad0}") end
	    line3.text=line3.text:gsub("(\\[xy]bord)[%d%.]+","%10")
	    line3.text=line3.text:gsub("(\\[xy]shad)[%d%.%-]+","%10")
	    line3.layer=line3.layer+1
	    subs.insert(sel[i]+1,line3)
	    
		-- bottom line
--	    if text:match("\\bord")==nil then
--	    text=text:gsub("^{\\","{\\bord"..border.."\\")
--	    end
	--    if shadow~=0 and text:match("\\shad")==nil then
	--    text=text:gsub("^({\\[^}]+)}","%1\\shad"..shadow.."}")
	--    end
		if text:match("\\1?c&") then text=text:gsub("(\\1?c)(&H%d+&)","%1"..outline.."")
		else text=text:gsub("^({\\[^}]+)}","%1\\c"..outline.."}")
		end
	    line.layer=line.layer-1
	    line.text = text
	    end
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
	    {	x=0,y=0,width=1,height=1,class="label",label="Glow blur:" },
	    {	x=0,y=1,width=1,height=1,class="label",label="Glow alpha:" },
	    
	    {	x=1,y=0,width=1,height=1,class="floatedit",name="blur",value="3" },
	    {	x=1,y=1,width=1,height=1,class="dropdown",name="alfa",
	    items={"20","30","40","50","60","70","80","90","A0","B0","C0","D0"},value="80" },
	    
	   -- {	x=2,y=0,width=1,height=2,class="label",label="||\n||\n||" },
	    {	x=2,y=0,width=2,height=1,class="checkbox",name="double",label="double border for 2layer blur",value=false },
	    
	    {	x=2,y=1,width=1,height=1,class="label",label="Change layer:", },
	    {	x=3,y=1,width=1,height=1,class="dropdown",name="layer",
		items={"-3","-2","-1","+1","+2","+3","+4","+5"},value="+1" },
	    
	} 	
	buttons={"Apply glow","Apply 2layer blur","Change layer","cancel"}
	pressed, res = aegisub.dialog.display(dialog_config,buttons)
	if pressed=="Apply glow" then glow(subs, sel) end
	if pressed=="Change layer" then layeraise(subs, sel) end
	if pressed=="Apply 2layer blur" then layerblur(subs, sel) end
end

function addglow(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, addglow)