script_name = "Multi-line Editor"
script_description = "Multi-line Editor"
script_author = "unanimated"
script_version = "1.0"

require "clipboard"

function editlines(subs, sel)
	editext=""
	dura=""
    for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	dur=line.end_time-line.start_time
	dur=dur/1000
	      if x~=#sel then editext=editext..text.."\n" dura=dura..dur.."\n" end
	      if x==#sel then editext=editext..text dura=dura..dur end
	subs[i] = line
    end
    editbox(subs, sel)
    if failt==1 then editext=res.dat editbox(subs, sel) end
    return sel
end

function editbox(subs, sel)
	if #sel<=4 then boxheight=5 end
	if #sel>=5 and #sel<9 then boxheight=7 end
	if #sel>=9 and #sel<15 then boxheight=math.ceil(#sel*0.8) end
	if #sel>=15 and #sel<18 then boxheight=12 end
	if #sel>=18 then boxheight=15 end
	dialog=
	{
	    {x=0,y=0,width=40,height=1,class="label",label="Text"},
	    {x=40,y=0,width=5,height=1,class="label",label="Duration"},
	    
	    {x=0,y=1,width=40,height=boxheight,class="textbox",name="dat",value=editext},
	    {x=40,y=1,width=5,height=boxheight,class="textbox",name="durr",value=dura,hint="This is informative only. \nIt will not be saved."},
	    
	    {x=0,y=boxheight+1,width=40,height=1,class="edit",name="info",value="Lines loaded: "..#sel},

	} 	
	buttons={"Save","Add italics","Add \\an8","Remove \\N","Reload text","Cancel"}
	repeat
	if pressed=="Add italics" or pressed=="Add \\an8" or pressed=="Remove \\N" or pressed=="Reload text" then
		if pressed=="Add italics" then
		res.dat=res.dat	:gsub("$","\n") :gsub("(.-)\n","{\\i1}%1\n") :gsub("{\\i1}{\\","{\\i1\\") :gsub("\n$","") end
		if pressed=="Add \\an8" then
		res.dat=res.dat	:gsub("$","\n") :gsub("(.-)\n","{\\an8}%1\n") :gsub("{\\an8}{\\","{\\an8\\") :gsub("\n$","") end
		if pressed=="Remove \\N" then res.dat=res.dat	:gsub("%s?\\N%s?"," ") end
		
		
		for key,val in ipairs(dialog) do
		  if pressed~="Reload text" then
		    if val.name=="dat" then val.value=res.dat end
		    if val.name=="durr" then val.value=res.durr end
		    if val.name=="info" then val.value=res.info end
		    if val.name=="oneline" then val.value=res.oneline end
		  else
		    if val.name=="dat" then val.value=editext end
		  end
		end

	end
	pressed, res = aegisub.dialog.display(dialog,buttons)
	until pressed~="Add italics" and pressed~="Add \\an8" and pressed~="Remove \\N" and pressed~="Reload text"

	if pressed=="Cancel" then    aegisub.cancel() end
	if pressed=="Save" then savelines(subs, sel) end
	return sel
	
end


function savelines(subs, sel)
    local data={}	raw=res.dat.."\n"	--aegisub.log("raw\n"..raw)
    if #sel==1 then raw=raw:gsub("\n(.)","\\N%1") end
    for dataline in raw:gmatch("(.-)\n") do table.insert(data,dataline) end
    failt=0    
    if #sel~=#data and #sel>1 then failt=1 else
	for x, i in ipairs(sel) do
        local line = subs[i]
	local text=subs[i].text
	text=data[x]
	line.text=text
	subs[i] = line
	end
    end
    if failt==1 then aegisub.dialog.display({{class="label",
		    label="Line count of edited text does not \nmatch the number of selected lines.",x=0,y=0,width=1,height=2}},{"OK"})  
		    clipboard.set(res.dat) end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, editlines)