script_name = "xy BorderShadow"
script_description = "Adds xbord / ybord / xshad / yshad to selected lines"
script_author = "unanimated"
script_version = "1.0"

function xybs(subs, sel)
	for z, i in ipairs(sel) do
	    line = subs[i]
	    text = subs[i].text
	    
	if text:match("^{\\")==nil then text="{\\}"..text end	-- add {\} if line has no tags
	    
	-- \xbord
	if results["xbord1"]==true then
	    if text:match("^{[^}]*\\xbord%d") then
	    text=text:gsub("^({[^}]*\\xbord)([%d%.]+)","%1"..results["xbord2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\xbord"..results["xbord2"].."}") 
	    end
	end
	-- \ybord
	if results["ybord1"]==true then
	    if text:match("^{[^}]*\\ybord%d") then
	    text=text:gsub("^({[^}]*\\ybord)([%d%.]+)","%1"..results["ybord2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\ybord"..results["ybord2"].."}") 
	    end
	end
	-- \xshad
	if results["xshad1"]==true then
	    if text:match("^{[^}]*\\xshad%d") then
	    text=text:gsub("^({[^}]*\\xshad)([%d%.]+)","%1"..results["xshad2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\xshad"..results["xshad2"].."}") 
	    end
	end
	-- \yshad
	if results["yshad1"]==true then
	    if text:match("^{[^}]*\\yshad%d") then
	    text=text:gsub("^({[^}]*\\yshad)([%d%.]+)","%1"..results["yshad2"]) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\yshad"..results["yshad2"].."}") 
	    end
	end
	
	text=text:gsub("\\\\","\\")	text=text:gsub("\\}","}")	-- clean up \\
	    line.text = text
	    subs[i] = line
	end
end
	    
function konfig(subs, sel)
	dialog_config=
	{
	    {	x=2,y=0,width=4,height=1,class="label",label="Tags are added at the end of tag string.", },
	    
	    {	x=2,y=1,width=1,height=1,class="checkbox",name="xbord1",label="\\xbord",value=false },
	    {	x=2,y=2,width=1,height=1,class="checkbox",name="ybord1",label="\\ybord",value=false },
	    {	x=2,y=3,width=1,height=1,class="checkbox",name="xshad1",label="\\xshad",value=false },
	    {	x=2,y=4,width=1,height=1,class="checkbox",name="yshad1",label="\\yshad",value=false },
	    
	    {	x=3,y=1,width=1,height=1,class="floatedit",name="xbord2",value="",min="0" },
	    {	x=3,y=2,width=1,height=1,class="floatedit",name="ybord2",value="",min="0" },
	    {	x=3,y=3,width=1,height=1,class="floatedit",name="xshad2",value="" },
	    {	x=3,y=4,width=1,height=1,class="floatedit",name="yshad2",value="" },
	    
	    {	x=2,y=5,width=4,height=1,class="label",label="They will override existng \\bord or \\shad tags.", },
	} 	
	buttons={"Apply to selected lines","check all","cancel"}
	
	repeat
	
	    if pressed=="check all" then
		for key,val in ipairs(dialog_config) do
		    if val.class=="checkbox" then
			val.value=true
		    end
		end
	    end
	pressed,results=aegisub.dialog.display(dialog_config,buttons)
	until pressed~="check all"
	
	if pressed=="Apply to selected lines" then xybs(subs, sel) end
end

function bordershadow(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, bordershadow)