--[[	"2-Layer Blur" is basically my simplified version of "Duplicate and Blur" that doesn't leave commented lines. 
	It supports 2 borders, xbord, ybord, shad, and yshad, but doesn't have the other modes D&B has.
	
	"Blur and Glow" - If there's no border, 2 layers are created. Top is the original, bottom has the blur/alpha you set.
	If there's border, 3 layers are created. Top is without border, middle has primary colour changed to match outline, bottom has glow.
	If there's no blur, \blur0.6 is added to top layer(s). If there are no tags at all, you should probably quit.
	
	"Change layer" - raises or lower layer for all selected lines by the same amount.

	Things to do: colour picker for 2nd border, 2nd border size option.
]]

script_name = "Blur and Glow"
script_description = "Add blur and/or glow to signs"
script_author = "unanimated"
script_version = "1.0"

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
		primary=primary:gsub("H%x%x","H")
		pri=text:match("\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		outline=line.styleref.color3
		outline=outline:gsub("H%x%x","H")
		out=text:match("\\3c(&H%x+&)")
		if out~=nil then outline=out end
		
		border=line.styleref.outline
		bord=text:match("\\bord([%d%.]+)")
		if bord~=nil then border=bord end
		
		shadow=line.styleref.shadow
		shad=text:match("\\shad([%d%.]+)")
		if shad~=nil then shadow=shad end
		
	    if border~="0" or text:match("\\[xy]bord")==nil then
	    
	    -- with two borders
	    
	  if res["double"] then	

		-- second border
	    line1=line	
	    line1.text=text
	    if line1.text:match("\\bord")==nil then
	    line1.text=line1.text:gsub("^{\\","{\\bord"..border+border.."\\") else
	    line1.text=line1.text:gsub("\\bord[%d%.]+","\\bord"..border+border)
	    end
	    if line1.text:match("\\[xy]bord") then
		line1.text=line1.text:gsub("\\xbord([%d%.]+)",function(a) return "\\xbord"..a+a end)
		line1.text=line1.text:gsub("\\ybord([%d%.]+)",function(a) return "\\ybord"..a+a end)
	    end	    
	    
		if line1.text:match("\\3c&") then line1.text=line1.text:gsub("(\\3c)(&H%x+&)","%1"..primary.."")
		else line1.text=line1.text:gsub("^({\\[^}]+)}","%1\\3c"..primary.."}")
		end
	    line1.layer=line1.layer+1
	    subs.insert(sel[i]+1,line1)

		-- first border
	    line2=line
	    line2.text=text
		if line2.text:match("\\1?c&") then line2.text=line2.text:gsub("(\\1?c)(&H%x+&)","%1"..outline.."")
		else line2.text=line2.text:gsub("^({\\[^}]+)}","%1\\c"..outline.."}")
		end
	    line2.layer=line2.layer+1
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
	    line3.layer=line3.layer+1
	    subs.insert(sel[i]+3,line3)

		-- bottom / glow
		if text:match("\\3c&") then text=text:gsub("(\\3c)(&H%x+&)","%1"..primary.."")
		else text=text:gsub("^({\\[^}]+)}","%1\\3c"..primary.."}")
		end
	    if text:match("\\bord")==nil then
	    text=text:gsub("^{\\","{\\bord"..border+border.."\\") else
	    text=text:gsub("\\bord[%d%.]+","\\bord"..border+border)	    
	    end
	    text=text:gsub("(\\blur)[%d%.]*([\\}])","%1"..res["blur"].."\\alpha&H"..res["alfa"].."&%2")
	    line.layer=line.layer-3
	    line.text = text

	  else
	  
	    -- with border
	    
		-- border
	    line2=line
	    text2=line2.text
		if text2:match("\\1?c&") then text2=text2:gsub("(\\1?c)(&H%x+&)","%1"..outline.."")
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
	    text=text:gsub("^({\\[^}]+)}","%1\\blur0.6}") end
	    line.text=text
	    
	    -- get colors, border, shadow from style
	    	primary=line.styleref.color1
		primary=primary:gsub("H%x%x","H")
		pri=text:match("\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		outline=line.styleref.color3
		outline=outline:gsub("H%x%x","H")
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
		if text2:match("\\1?c&") then text2=text2:gsub("(\\c)(&H%x+&)","%1"..outline.."")
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
	    line3.text=line3.text:gsub("\\[xy]bord[%d%.]+","")
	    line3.text=line3.text:gsub("\\[xy]shad[%d%.%-]+","")
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
	    
		if text:match("\\3c&") then text=text:gsub("(\\3c)(&H%x+&)","%1"..primary.."")
		else text=text:gsub("^({\\[^}]+)}","%1\\3c"..primary.."}")
		end
	    line.layer=line.layer-2
	    line.text = text
	    
	    else
	    
	    -- one border
	    
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
	    line3.layer=line3.layer+1
	    subs.insert(sel[i]+1,line3)
	    
		-- bottom line
		if text:match("\\1?c&") then text=text:gsub("(\\1?c)(&H%x+&)","%1"..outline.."")
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
	    {	x=0,y=1,width=1,height=1,class="label",label="Glow blur:" },
	    {	x=0,y=2,width=1,height=1,class="label",label="Glow alpha:" },
	    
	    {	x=1,y=1,width=1,height=1,class="floatedit",name="blur",value="3" },
	    {	x=1,y=2,width=1,height=1,class="dropdown",name="alfa",
	    items={"20","30","40","50","60","70","80","90","A0","B0","C0","D0"},value="80" },
	    
	    {	x=0,y=0,width=2,height=1,class="checkbox",name="double",label="double border",value=false },
	    {	x=2,y=0,width=1,height=1,class="checkbox",name="clr",label="2nd border colour:" },
	    {	x=3,y=0,width=1,height=1,class="color",name="c3" },
	    
	    {	x=2,y=2,width=1,height=1,class="checkbox",name="bsize",label="2nd border size",value=false },
	    {	x=3,y=2,width=1,height=1,class="floatedit",name="secbord",value="2" },
	    
	    {	x=2,y=2,width=1,height=1,class="label",label="Change layer:", },
	    {	x=3,y=2,width=1,height=1,class="dropdown",name="layer",
		items={"-3","-2","-1","+1","+2","+3","+4","+5"},value="+1" },
	    
	} 	
	buttons={"2-Layer Blur","Blur and Glow","Change layer","cancel"}
	pressed, res = aegisub.dialog.display(dialog_config,buttons)
	if pressed=="2-Layer Blur" then layerblur(subs, sel) end
	if pressed=="Blur and Glow" then glow(subs, sel) end
	if pressed=="Change layer" then layeraise(subs, sel) end
end

function addglow(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
end

aegisub.register_macro(script_name, script_description, addglow)