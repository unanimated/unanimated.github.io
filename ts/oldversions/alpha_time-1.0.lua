script_name="Alpha Timer"
script_description="Alpha times shit"
script_author="unanimated"
script_version="1.0"

function alfatxt(subs,sel)
    -- collect / check text
    for x, i in ipairs(sel) do
	text=subs[i].text
	if x==1 then alfatext=text:gsub("^{\\[^}]-}","") end
	if x~=1 then alfatext2=text:gsub("^{\\[^}]-}","") 
	  if alfatext2~=alfatext then 
	    aegisub.dialog.display({{class="label",label="Text must be the same for all selected lines",x=0,y=0,width=1,height=2}},{"OK"})
	    aegisub.cancel()
	  end
	end
    end
    
	-- GUI
	dialog_config={{x=0,y=0,width=5,height=8,class="textbox",name="alfa",value=alfatext },
	{x=0,y=8,width=1,height=1,class="label",
		label="Break the text with 'Enter' the way it should be alpha-timed. ("..#sel.." lines selected)"},}
	pressed,res=aegisub.dialog.display(dialog_config,{"Alpha","Cancel"},{ok='Alpha',close='Cancel'})
	if pressed=="Cancel" then aegisub.cancel() end
	
	-- sort data into a table
	altab={}	data=res.alfa.."\n"
	for a in data:gmatch("(.-)\n") do table.insert(altab,a) end
	
    -- apply alpha
    for x, i in ipairs(sel) do
        altxt=""
	for a=1,x do altxt=altxt..altab[a] end
	line=subs[i]
	text=line.text
	if altab[x]~=nil then
	  text=text
	  :gsub(altxt,altxt.."{\\alpha&HFF&}")
	  :gsub("{\\alpha&HFF&}$","")
	  :gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
	end
	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, alfatxt)