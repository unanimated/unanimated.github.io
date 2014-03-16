-- Alpha Text: Select timed lines with the same text. Alpha tags will be applied based on linebreaks in the GUI.
-- Alpha Time: Select only one line with the full duration. Alpha tags will be applied, and line will be split and timed to even segments.
-- @ - If the one selected line has @ markers, the line will be split by them without using the GUI.

script_name="Alpha Timer"
script_description="Alpha times shit"
script_author="unanimated"
script_version="1.1"

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
    
    if not alfatext:match("@") then
	-- GUI
	dialog_config={{x=0,y=0,width=5,height=8,class="textbox",name="alfa",value=alfatext },
	{x=0,y=8,width=1,height=1,class="label",
		label="Break the text with 'Enter' the way it should be alpha-timed. (lines selected: "..#sel..")"},}
	pressed,res=aegisub.dialog.display(dialog_config,{"Alpha Text","Alpha Time","Cancel"},{ok='Alpha Text',close='Cancel'})
	if pressed=="Cancel" then aegisub.cancel() end
	data=res.alfa
    else
	data=alfatext:gsub("@","\n")
	pressed="Alpha Time"
    end
	-- sort data into a table
	altab={}	data=data.."\n"
	for a in data:gmatch("(.-)\n") do if a~="" then table.insert(altab,a) end end
	
    -- apply alpha text
    if pressed=="Alpha Text" then
      for x, i in ipairs(sel) do
        altxt=""
	for a=1,x do altxt=altxt..altab[a] end
	line=subs[i]
	text=line.text
	if altab[x]~=nil then
	  tags=text:match("^{\\[^}]-}")
	  text=text
	  :gsub("^{\\[^}]-}","")
	  :gsub(altxt,altxt.."{\\alpha&HFF&}")
	  :gsub("({\\alpha&HFF&}.-){\\alpha&HFF&}","%1")
	  :gsub("{\\alpha&HFF&}$","")
	  :gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
	  if tags~=nil then text=tags..text end
	end
	line.text=text
	subs[i]=line
      end
    end
    
    -- apply alpha etxt + split line
    if pressed=="Alpha Time" then
	line=subs[sel[1]]
	start=line.start_time
	endt=line.end_time
	dur=endt-start
	f=dur/#altab
	for a=#altab,1,-1 do
          altxt=""
	  altxt=altxt..altab[a]
	  line.text=line.text:gsub("@","")
	  line2=line
	  tags=line2.text:match("^{\\[^}]-}")
	  line2.text=line2.text
	  :gsub("^{\\[^}]-}","")
	  :gsub(altxt,altxt.."{\\alpha&HFF&}")
	  :gsub("({\\alpha&HFF&}.-){\\alpha&HFF&}","%1")
	  :gsub("{\\alpha&HFF&}$","")
	  :gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
	  if tags~=nil then line2.text=tags..line2.text end
	  line2.start_time=start+f*(a-1)
	  line2.end_time=start+f+f*(a-1)
	  subs.insert(sel[1]+1,line2)
	end
	subs.delete(sel[1])
    end
    
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, alfatxt)