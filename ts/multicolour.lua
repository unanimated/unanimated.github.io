-- See description. Also, why the fuck has nobody written this yet?

script_name = "Multicolour"
script_description = "Apply colours to multiple lines"
script_author = "unanimated"
script_version = "1.0"

function mc(subs, sel)
	for z, i in ipairs(sel) do
	    line = subs[i]
	    text = subs[i].text
	-- get colours from input
	    col1=results["c1"]
	    col1=col1:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col3=results["c3"]
	    col3=col3:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col4=results["c4"]
	    col4=col4:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	    col2=results["c2"]
	    col2=col2:gsub("#(%x%x)(%x%x)(%x%x)","&H%3%2%1&")
	-- set selected colours
	if text:match("^{\\")==nil then text="{\\}"..text end	-- add {\} if line has no tags
	if results["k1"]==true then
	    if text:match("^{[^}]*\\c&") then
	    text=text:gsub("^({[^}]*\\c)(&H%x%x%x%x%x%x&)","%1"..col1) 
	    else
	    text=text:gsub("^({\\[^}]*)}","%1\\c"..col1.."}")
	    end 
	end
	if results["k2"]==true then
	    if text:match("^{[^}]*\\2c&") then
	    text=text:gsub("^({[^}]*\\2c)(&H%x%x%x%x%x%x&)","%1"..col2) 
	    else	    
	    text=text:gsub("^({\\[^}]*)}","%1\\2c"..col2.."}") 
	    end
	end
	if results["k3"]==true then
	    if text:match("^{[^}]*\\3c&") then
	    text=text:gsub("^({[^}]*\\3c)(&H%x%x%x%x%x%x&)","%1"..col3) 
	    else	    
	    text=text:gsub("^({\\[^}]*)}","%1\\3c"..col3.."}") 
	    end
	end
	if results["k4"]==true then
	    if text:match("^{[^}]*\\4c&") then
	    text=text:gsub("^({[^}]*\\4c)(&H%x%x%x%x%x%x&)","%1"..col4) 
	    else	    
	    text=text:gsub("^({\\[^}]*)}","%1\\4c"..col4.."}") 
	    end
	end
	text=text:gsub("{\\\\","{\\")	-- clean up \\
	    line.text = text
	    subs[i] = line
	end
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=0,width=3,height=1,class="label",label="Check colours you want used", },
	    {	x=0,y=1,width=1,height=1,class="checkbox",name="k1",label="Primary:",value=true },
	    {	x=0,y=2,width=1,height=1,class="checkbox",name="k3",label="Border:",value=false },
	    {	x=0,y=3,width=1,height=1,class="checkbox",name="k4",label="Shadow:",value=false },
	    {	x=0,y=5,width=1,height=1,class="checkbox",name="k2",label="useless... (2c):",value=false },
	    
	    {	x=1,y=1,width=1,height=1,class="color",name="c1" },
	    {	x=1,y=2,width=1,height=1,class="color",name="c3" },
	    {	x=1,y=3,width=1,height=1,class="color",name="c4" },
	    {	x=1,y=5,width=1,height=1,class="color",name="c2" },
	} 	
	pressed, results = aegisub.dialog.display(dialog_config,{"Apply","Cancel"})
	if pressed=="Apply" then mc(subs, sel) end
	if pressed=="Cancel" then aegisub.cancel() end
end

function multicolour(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, multicolour)