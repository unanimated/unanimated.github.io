-- removes comments and other unneeded stuff from selected lines

script_name = "Script Cleanup"
script_description = "Removes unwanted stuff from script"
script_author = "unanimated"
script_version = "1.6"				-- added "kill tags" function - nuke selected tags

function nots(subs, sel)			-- remove {TS} comments from selected lines - lets you keep other comments
    for x, i in ipairs(sel) do
            local line = subs[i]
            local text = subs[i].text
            text = text:gsub("{TS[^}]*}%s*","")
	    text = text:gsub("^%s*","")
	    line.text = text
            subs[i] = line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function nocom(subs, sel)			-- remove all {comments} from selected lines
    for x, i in ipairs(sel) do
            local line = subs[i]
            local text = subs[i].text
	    text = text:gsub("^({[^}]*})%s*","%1")
	    text = text:gsub("{[^\\}]*}","")
	    text = text:gsub("{[^\\}]*\\N[^\\}]*}","")
	    text = text:gsub("^%s*","")
	    line.text = text
            subs[i] = line
    end
    return sel
end

function notag(subs, sel)			-- remove all {\tags} from selected lines
    for x, i in ipairs(sel) do
            local line = subs[i]
            local text = subs[i].text
	    text = text:gsub("{\\[^}]*}","")
	    text = text:gsub("^%s*","")
	    line.text = text
            subs[i] = line
    end
    return sel
end

function nocom_line(subs, sel)			-- delete commented lines from selected lines
	ncl_sel={}
	for i=#sel,1,-1 do
		line=subs[sel[i]]
		if line.comment==true then
		for x,y in ipairs(ncl_sel) do ncl_sel[x]=y-1 end
		subs.delete(sel[i])
		else
		table.insert(ncl_sel,sel[i])
		end
	end
	return ncl_sel
end

function noempty(subs, sel)			-- delete empty lines from selected lines
	noe_sel={}
	for i=#sel,1,-1 do
		line=subs[sel[i]]
		if line.text == "" then
		for x,y in ipairs(noe_sel) do noe_sel[x]=y-1 end
		subs.delete(sel[i])
		else
		table.insert(noe_sel,sel[i])
		end
	end
	return noe_sel
end

function noemptycom(subs, sel)			-- delete commented or empty lines from selected lines
	noecom_sel={}
	for i=#sel,1,-1 do
		line=subs[sel[i]]
		if line.comment==true or line.text == "" then
		for x,y in ipairs(noecom_sel) do noecom_sel[x]=y-1 end
		subs.delete(sel[i])
		else
		table.insert(noecom_sel,sel[i])
		end
	end
	return noecom_sel
end 

function clear_a(subs, sel)			-- clear actor field in selected lines
    for x, i in ipairs(sel) do
            local line = subs[i]
	    line.actor=""
            subs[i] = line
    end
    return sel
end

function clear_e(subs, sel)			-- clear effect field in selected lines
    for x, i in ipairs(sel) do
            local line = subs[i]
	    line.effect=""
            subs[i] = line
    end
    return sel
end

function layers(subs, sel)			-- set dialogue styles [matching "Defa" or "Alt"] 3 layers up to avoid overlapping with TS
    for x, i in ipairs(sel) do
		local line = subs[i]
		if line.style:match("Defa") or line.style:match("Alt") then line.layer=line.layer+3 end
		subs[i] = line	
    end
    return sel
end

function nobreak(subs, sel)			-- nuke linebreaks
    for x, i in ipairs(sel) do
            local line = subs[i]
            local text = subs[i].text
	    text = text:gsub("%s?\\[Nn]%s?"," ")
	    text = text:gsub("\\[Nn]"," ")
	    line.text = text
            subs[i] = line
    end
end 

function killemall(subs, sel)			-- kill everything
    for x, i in ipairs(sel) do
            local line = subs[i]		
            local text = subs[i].text		
	    if results["border"]==true then
		text = text:gsub("\\bord[%d%.]+([\\}])","%1")
		text = text:gsub("\\xbord[%d%.]+([\\}])","%1")
		text = text:gsub("\\ybord[%d%.]+([\\}])","%1")
	    end
	    if results["shadow"]==true then
		text = text:gsub("\\shad[%d%.]+([\\}])","%1")
		text = text:gsub("\\xshad[%d%.%-]+([\\}])","%1")
		text = text:gsub("\\yshad[%d%.%-]+([\\}])","%1")
	    end
	    if results["blur"]==true then
		text = text:gsub("\\blur[%d%.]+([\\}])","%1")
	    end
	    if results["bee"]==true then
		text = text:gsub("\\be[%d%.]+([\\}])","%1")
	    end
	    if results["fsize"]==true then
		text = text:gsub("\\fs[%d%.]+([\\}])","%1")
	    end
	    if results["fspace"]==true then
		text = text:gsub("\\fsp[%d%.%-]+([\\}])","%1")
	    end
	    if results["scalex"]==true then
		text = text:gsub("\\fscx[%d%.]+([\\}])","%1")
	    end
	    if results["scaley"]==true then
		text = text:gsub("\\fscy[%d%.]+([\\}])","%1")
	    end
	    if results["fade"]==true then
		text = text:gsub("\\fad%([%d%.%,]+%)","")
		text = text:gsub("\\fade%([%d%.%,]+%)","")
	    end
	    if results["posi"]==true then
		text = text:gsub("\\pos%([%d%.%,]+%)","")
	    end
	    if results["move"]==true then
		text = text:gsub("\\move%([%d%.%,]+%)","")
	    end
	    if results["color1"]==true then
		text = text:gsub("\\1?c&[%w]+&","")
	    end
	    if results["color2"]==true then
		text = text:gsub("\\2c&[%w]+&","")
	    end
	    if results["color3"]==true then
		text = text:gsub("\\3c&[%w]+&","")
	    end
	    if results["color4"]==true then
		text = text:gsub("\\4c&[%w]+&","")
	    end
	    if results["alfa1"]==true then
		text = text:gsub("\\1a&[%w]+&","")
	    end
	    if results["alfa2"]==true then
		text = text:gsub("\\2a&[%w]+&","")
	    end
	    if results["alfa3"]==true then
		text = text:gsub("\\3a&[%w]+&","")
	    end
	    if results["alfa4"]==true then
		text = text:gsub("\\4a&[%w]+&","")
	    end
	    if results["alpha"]==true then
		text = text:gsub("\\alpha&[%w]+&","")
	    end
	    if results["clip"]==true then
		text = text:gsub("\\i?clip%([%w%,%.%s]+%)","")
	    end
	    if results["fname"]==true then
		text = text:gsub("\\fn.+([\\}])","%1")
	    end
	    if results["frz"]==true then
		text = text:gsub("\\frz[%d%.%-]+([\\}])","%1")
	    end
	    if results["frx"]==true then
		text = text:gsub("\\frx[%d%.%-]+([\\}])","%1")
	    end
	    if results["fry"]==true then
		text = text:gsub("\\fry[%d%.%-]+([\\}])","%1")
	    end
	    if results["org"]==true then
		text = text:gsub("\\org%([%d%.%,]+%)","")
	    end
	    if results["fax"]==true then
		text = text:gsub("\\fax[%d%.%-]+([\\}])","%1")
	    end
	    if results["fay"]==true then
		text = text:gsub("\\fay[%d%.%-]+([\\}])","%1")
	    end
	    if results["anna"]==true then
		text = text:gsub("\\an%d([\\}])","%1")
	    end
	    if results["align"]==true then
		text = text:gsub("\\a%d([\\}])","%1")
	    end
	    if results["return"]==true then
		text = text:gsub("\\r.+([\\}])","%1")
	    end
	    if results["kara"]==true then
		text = text:gsub("\\k[fo]?[%d]+([\\}])","%1")
	    end
	    
	    text = text:gsub("{}","")
	    line.text = text
            subs[i] = line
    end
end 

function cleanup(subs, sel)	
	dialog_config=
	{
	{x=0,y=10,width=1,height=1,class="label",label="",    },
	{x=0,y=0,width=1,height=1,class="checkbox",name="nots",label="Remove TS timecodes",value=false    },
	{x=0,y=1,width=1,height=1,class="checkbox",name="nocom",label="Remove comments from lines",value=false    },
	{x=0,y=2,width=1,height=1,class="checkbox",name="clear_a",label="Clear Actor field",value=false    },
        {x=0,y=3,width=1,height=1,class="checkbox",name="clear_e",label="Clear Effect field",value=false    },
	{x=0,y=4,width=1,height=1,class="checkbox",name="layers",label="Raise dialogue layer by 3",value=false    },
	{x=0,y=6,width=1,height=1,class="checkbox",name="nocomline",label="Delete commented lines",value=false    },
	{x=0,y=7,width=1,height=1,class="checkbox",name="noempty",label="Delete empty lines",value=false    },
	{x=0,y=9,width=1,height=1,class="checkbox",name="all",label="ALL OF THE ABOVE",value=false    },
	{x=2,y=0,width=1,height=1,class="label",label="- Removes timecodes like {TS 12:36}",    },
	{x=2,y=1,width=1,height=1,class="label",label="- Removes all {comments} (not tags)",    },
	{x=2,y=2,width=1,height=1,class="label",label="- Clean up actor garbage...",    },
        {x=2,y=3,width=1,height=1,class="label",label="- Clean up effect garbage...",    },
	{x=2,y=4,width=1,height=1,class="label",label="- This makes sure dialogue is on top of TS",    },
	{x=2,y=6,width=1,height=1,class="label",label="- Deletes lines that are commented out",    },
	{x=2,y=7,width=1,height=1,class="label",label="- Deletes lines with no text/tags/comments",    },
	{x=2,y=9,width=1,height=1,class="checkbox",name="notag",label="Remove all {\\tags} from selected lines",value=false    },
	{x=2,y=10,width=1,height=1,class="checkbox",name="nobreak",label="Remove linebreaks  - \\N",value=false    },  
	
	{x=3,y=0,width=1,height=11,class="label",label="| \n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|",},

	{x=4,y=0,width=1,height=1,class="label",label="Kill tags:",},
	{x=5,y=0,width=1,height=1,class="checkbox",name="bee",label="be",value=false },
	
	{x=4,y=1,width=1,height=1,class="checkbox",name="border",label="bord",hint="includes xbord and ybord",value=false },
	{x=4,y=2,width=1,height=1,class="checkbox",name="shadow",label="shad",hint="includes xshad and yshad",value=false },
	{x=4,y=3,width=1,height=1,class="checkbox",name="blur",label="blur",value=false },
	{x=4,y=4,width=1,height=1,class="checkbox",name="fsize",label="fs",value=false },
	{x=4,y=5,width=1,height=1,class="checkbox",name="fspace",label="fsp",value=false },
	{x=4,y=6,width=1,height=1,class="checkbox",name="scalex",label="fscx",value=false },
	{x=4,y=7,width=1,height=1,class="checkbox",name="scaley",label="fscy",value=false },
	{x=4,y=8,width=1,height=1,class="checkbox",name="fade",label="fad",value=false },
	{x=4,y=9,width=1,height=1,class="checkbox",name="posi",label="pos",value=false },
	{x=4,y=10,width=1,height=1,class="checkbox",name="move",label="move",value=false },
	
	{x=5,y=1,width=1,height=1,class="checkbox",name="color1",label="c, 1c",value=false },
	{x=5,y=2,width=1,height=1,class="checkbox",name="color2",label="2c",value=false },
	{x=5,y=3,width=1,height=1,class="checkbox",name="color3",label="3c",value=false },
	{x=5,y=4,width=1,height=1,class="checkbox",name="color4",label="4c",value=false },
	{x=5,y=5,width=1,height=1,class="checkbox",name="alpha",label="alpha",value=false },
	{x=5,y=6,width=1,height=1,class="checkbox",name="alfa1",label="1a",value=false },
	{x=5,y=7,width=1,height=1,class="checkbox",name="alfa2",label="2a",value=false },
	{x=5,y=8,width=1,height=1,class="checkbox",name="alfa3",label="3a",value=false },
	{x=5,y=9,width=1,height=1,class="checkbox",name="alfa4",label="4a",value=false },
	{x=5,y=10,width=1,height=1,class="checkbox",name="clip",label="(i)clip",value=false },

	{x=6,y=0,width=1,height=1,class="checkbox",name="fname",label="fn",value=false },
	{x=6,y=1,width=1,height=1,class="checkbox",name="frz",label="frz",value=false },
	{x=6,y=2,width=1,height=1,class="checkbox",name="frx",label="frx",value=false },
	{x=6,y=3,width=1,height=1,class="checkbox",name="fry",label="fry",value=false },
	{x=6,y=4,width=1,height=1,class="checkbox",name="org",label="org",value=false },
	{x=6,y=5,width=1,height=1,class="checkbox",name="fax",label="fax",value=false },
	{x=6,y=6,width=1,height=1,class="checkbox",name="fay",label="fay",value=false },
	{x=6,y=7,width=1,height=1,class="checkbox",name="anna",label="an",value=false },
	{x=6,y=8,width=1,height=1,class="checkbox",name="align",label="a",value=false },
	{x=6,y=9,width=1,height=1,class="checkbox",name="return",label="r",value=false },
	{x=6,y=10,width=1,height=1,class="checkbox",name="kara",label="k/kf/ko",value=false },
	
	} 
	
	pressed, results = aegisub.dialog.display(dialog_config,
	{"Run selected","This button will definitely break your computer","Cancer","^ Kill checked tags"})
	
	if pressed=="Cancer" then aegisub.cancel() end
	
	if pressed=="^ Kill checked tags" then killemall(subs, sel) end
	
	if pressed=="This button will definitely break your computer" then 
			nocom(subs, sel)
			notag(subs, sel)
			nobreak(subs, sel)
			clear_a(subs, sel)
			clear_e(subs, sel)
			layers(subs, sel) 
			sel=noemptycom(subs, sel)
	end

	if pressed=="Run selected" then 
		if results["notag"]==true then notag(subs, sel) end
	    if results["all"]==true then 
			nocom(subs, sel) 
			clear_a(subs, sel)
			clear_e(subs, sel)
			layers(subs, sel)
			sel=noemptycom(subs, sel)
	    else
		if results["nots"]==true and results["nocom"]==false then nots(subs, sel) end
		if results["nocom"]==true then nocom(subs, sel) end
		if results["nobreak"]==true then nobreak(subs, sel) end
		if results["clear_a"]==true then clear_a(subs, sel) end
		if results["clear_e"]==true then clear_e(subs, sel) end
		if results["layers"]==true then layers(subs, sel) end 

		if results["nocomline"]==true and results["noempty"]==true then sel=noemptycom(subs, sel)
		else
		    if results["nocomline"]==true then sel=nocom_line(subs, sel) end
		    if results["noempty"]==true then sel=noempty(subs, sel) end
		end
	    end
	    
	end
	aegisub.set_undo_point(script_name)
	return sel
end


aegisub.register_macro(script_name, script_description, cleanup)