-- removes comments and other unneeded stuff from selected lines

script_name = "Script Cleanup"
script_description = "Removes unwanted stuff from script"
script_author = "unanimated"
script_version = "2.2"

include("karaskel.lua")

function cleanlines(subs, sel)
local meta,styles=karaskel.collect_head(subs,false)
    for x, i in ipairs(sel) do
            local line = subs[i]
            local text = subs[i].text
	    karaskel.preproc_line(subs,meta,styles,line)
	    
	    if res["nots"] and res["nocom"]==false then
            text=text:gsub("{TS[^}]*}%s*","")
	    text=text:gsub("^%s*","")    end	
	    
	    if res["nocom"] or res["all"] then
	    text=text:gsub("{[^\\}]*}","")
	    text=text:gsub("{[^\\}]*\\N[^\\}]*}","")
	    text=text:gsub("^({[^}]*})%s*","%1")
	    text=text:gsub("^%s*","")    end
	    
	    if res["clear_a"] or res["all"] then line.actor="" end
	    
	    if res["clear_e"] or res["all"] then line.effect="" end
	    
	    if res["layers"] or res["all"] then 
	    if line.style:match("Defa") or line.style:match("Alt") then line.layer=line.layer+5 end
	    end
	    
	    if res["cleantag"] or res["all"] then
  	    text=text:gsub("\\\\","\\")
	    text=text:gsub("\\}","}")
		repeat
		text=text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
		until text:match("{(\\[^}]-)}{(\\[^}]-)}")==nil
		
		text=text:gsub("^{(\\[^}]-)\\frx0\\fry0([\\}])","{%1%2")

		if not text:match("\\t") then text=duplikill(text) end
		
	    end
	    
	    if res["overlap"] or res["all"] then
	    	start=line.start_time
		endt=line.end_time
		if i<#subs then nextline=subs[i+1]
		nextart=nextline.start_time end
		prevline=subs[i-1]
		prevstart=prevline.start_time
		prevend=prevline.end_time
		dur=line.end_time-line.start_time
		ms2fr=aegisub.frame_from_ms
		fr2ms=aegisub.ms_from_frame
		if line.comment==false and line.style:match("Defa") then
		
			keyframes = aegisub.keyframes()
			startf=ms2fr(start)		-- startframe
			endf=ms2fr(endt)		-- endframe
			prevendf=ms2fr(prevend)
			nextartf=ms2fr(nextart)
		
			-- start gaps/overlaps
			if prevline.class=="dialogue" and prevline.style:match("Defa") and dur>50 then
				-- get keyframes
				kfst=0  kfprev=0
				for k,kf in ipairs(keyframes) do
				if kf==startf then kfst=1 end
				if kf==prevendf then kfprev=1 end
				end
				-- start overlap
				if start<prevend and prevend-start<=50 then
				if kfst==0 or kfprev==1 then start=prevend end
				end
				-- start gap
				if start>prevend and start-prevend<=50 then 
				if kfst==0 and kfprev==1 then start=prevend end
				end
			end
			-- end gaps/overlaps
			if i<#subs and nextline.style:match("Defa") and dur>50 then
				--get keyframes
				kfend=0 kfnext=0
				for k,kf in ipairs(keyframes) do
				if kf==endf then kfend=1 end
				if kf==nextartf then kfnext=1 end
				end
				-- end overlap
				if endt>nextart and endt-nextart<=50 then
				if kfnext==1 and kfend==0 then endt=nextart end
				end
				-- end gap
				if endt<nextart and nextart-endt<=50 then
				if kfend==0 or kfnext==1 then endt=nextart end
				end
			end
		end
		line.start_time = start
		line.end_time = endt
	    end
	    
	    if res.spaces or res.all then
	    text=text:gsub("%s%s+"," ")
	    text=text:gsub("%s*$","")
	    text=text:gsub("^%s*","")	end
	
	    if res.nobreak then
	    text=text:gsub("%s?\\[Nn]%s?"," ")
	    text=text:gsub("\\[Nn]"," ")	end
	    
	    if res.notag then
	    text=text:gsub("{\\[^}]*}","")
	    text=text:gsub("^%s*","")	end
	    
	if res.alphacol then
	
	    	primary=line.styleref.color1
		primary=primary:gsub("H%x%x","H")
		pri=text:match("\\c(&H%x+&)")
		if pri~=nil then primary=pri end
		
		soutline=line.styleref.color3
		soutline=soutline:gsub("H%x%x","H")
		outline=soutline
		out=text:match("\\3c(&H%x+&)")
		if out~=nil then outline=out end
		
	text=text:gsub("alpha&(%x%x)&","alpha&H%1&")
	text=text:gsub("alpha(%x%x)([\\}])","alpha&H%1&%2")
	text=text:gsub("(\\[1234]a)&(%x%x)&","%1&H%2&")
	text=text:gsub("(\\[1234]a)(%x%x)([\\}])","%1&H%2&%3")
	text=text:gsub("(\\[1234]?c&)(%x%x%x%x%x%x)&","%1H%2&")
	end
	
	    text=text:gsub("{}","")
	    line.text=text
            subs[i] = line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function nocom_line(subs, sel)			-- delete commented lines from selected lines
	ncl_sel={}
	for i=#sel,1,-1 do
		local line=subs[sel[i]]
		if line.comment then
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
		local line=subs[sel[i]]
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
		if line.comment or line.text == "" then
		for x,y in ipairs(noecom_sel) do noecom_sel[x]=y-1 end
		subs.delete(sel[i])
		else
		table.insert(noecom_sel,sel[i])
		end
	end
	return noecom_sel
end 

function killemall(subs, sel)			-- kill everything
    for x, i in ipairs(sel) do
      local line=subs[i]
      local text=subs[i].text
	if res.border then text=killtag("bord",text) text=killtag("xbord",text) text=killtag("ybord",text) end
	if res.shadow then text=killtag("shad",text) text=killtag("xshad",text) text=killtag("yshad",text) end
	if res.blur then text=killtag("blur",text) end
	if res.bee then text=killtag("be",text) end
	if res.fsize then text=killtag("fs",text) end
	if res.fspace then text=killtag("fsp",text) end
	if res.scalex then text=killtag("fscx",text) end
	if res.scaley then text=killtag("fscy",text) end
	if res.fade then text=text:gsub("\\fad%([%d%.%,]+%)","")	:gsub("\\fade%([%d%.%,]+%)","") end
	if res.posi then text=text:gsub("\\pos%([%d%.%,]+%)","") end
	if res.move then text=text:gsub("\\move%([%d%.%,]+%)","") end
	if res.org then text=text:gsub("\\org%([%d%.%,]+%)","") end
	if res.color1 then text=killctag("c",text) text=killctag("1c",text) end
	if res.color2 then text=killctag("2c",text) end
	if res.color3 then text=killctag("3c",text) end
	if res.color4 then text=killctag("4c",text) end
	if res.alfa1 then text=killctag("1a",text) end
	if res.alfa2 then text=killctag("2a",text) end
	if res.alfa3 then text=killctag("3a",text) end
	if res.alfa4 then text=killctag("4a",text) end
	if res.alpha then text=killctag("alpha",text) end
	if res.clip then text=text:gsub("\\i?clip%([%w%,%.%s%-]+%)","") end
	if res.fname then text=text:gsub("\\fn.+([\\}])","%1") end
	if res.frz then text=killtag("frz",text) end
	if res.frx then text=killtag("frz",text) end
	if res.fry then text=killtag("fry",text) end
	if res.fax then text=killtag("fax",text) end
	if res.fay then text=killtag("fay",text) end
	if res.anna then text=killtag("an",text) end
	if res.align then text=killtag("a",text) end
	if res["return"] then text=text:gsub("\\r.+([\\}])","%1") end
	if res.kara then text=text:gsub("\\k[fo]?[%d]+([\\}])","%1") end
	if res.ital then text=text:gsub("\\i[01]","") end
	if res.bold then text=text:gsub("\\b[01]","") end
	if res.trans then text=text:gsub("\\t%([^%(%)]-%)","") text=text:gsub("\\t%([^%(%)]-%([^%)]-%)[^%)]-%)","") end
	text=text:gsub("{}","")
	line.text=text
        subs[i] = line
    end
end

function killtag(tag,text) text=text:gsub("\\"..tag.."[%d%.%-]+([\\}])","%1") return text end

function killctag(tag,text) text=text:gsub("\\"..tag.."&H%x+&","") return text end

function duplikill(text)
	tags1={"blur","be","bord","shad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay"}
	for i=1,#tags1 do
	    tag=tags1[i]
	    text=text:gsub("\\"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%1%2")
	end
	text=text:gsub("\\1c&","\\c&")
	tags2={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}
	for i=1,#tags2 do
	    tag=tags1[i]
	    text=text:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%1%2")
	end	
	return text
end

function cleanup(subs, sel)
	dialog_config=
	{
	{x=0,y=0,width=1,height=1,class="checkbox",name="nots",label="Remove TS timecodes",value=false    },
	{x=0,y=1,width=1,height=1,class="checkbox",name="nocom",label="Remove comments from lines",value=false    },
	{x=0,y=2,width=1,height=1,class="checkbox",name="clear_a",label="Clear Actor field",value=false    },
        {x=0,y=3,width=1,height=1,class="checkbox",name="clear_e",label="Clear Effect field",value=false    },
	{x=0,y=4,width=1,height=1,class="checkbox",name="layers",label="Raise dialogue layer by 5",value=false    },
	{x=0,y=5,width=1,height=1,class="checkbox",name="cleantag",label="Clean up tags",value=false    },
	{x=0,y=6,width=1,height=1,class="checkbox",name="overlap",label="Fix 1-frame gaps/overlaps",value=false    },
	{x=0,y=7,width=1,height=1,class="checkbox",name="nocomline",label="Delete commented lines",value=false    },
	{x=0,y=8,width=1,height=1,class="checkbox",name="noempty",label="Delete empty lines",value=false    },
	{x=0,y=9,width=1,height=1,class="checkbox",name="spaces",label="Fix start/end/double spaces",value=false    },
	{x=0,y=11,width=1,height=1,class="checkbox",name="all",label="ALL OF THE ABOVE",value=false    },
	
	{x=2,y=0,width=1,height=1,class="label",label="- Removes timecodes like {TS 12:36}",    },
	{x=2,y=1,width=1,height=1,class="label",label="- Removes all {comments} (not tags)",    },
	{x=2,y=2,width=1,height=1,class="label",label="- Clean up actor garbage...",    },
        {x=2,y=3,width=1,height=1,class="label",label="- Clean up effect garbage...",    },
	{x=2,y=4,width=1,height=1,class="label",label="- This makes sure dialogue is on top of TS",    },
	{x=2,y=5,width=1,height=1,class="label",label="- Fixes \\\\, \\}, }{ and some duplicates",    },
	{x=2,y=6,width=1,height=1,class="label",label="- Fixes timing derps on dialogue lines",    },
	{x=2,y=7,width=1,height=1,class="label",label="- Deletes lines that are commented out",    },
	{x=2,y=8,width=1,height=1,class="label",label="- Deletes lines with no text/tags/comments",    },
	{x=2,y=9,width=1,height=1,class="checkbox",name="nobreak",label="Remove linebreaks  - \\N",value=false    },  
	{x=2,y=10,width=1,height=1,class="checkbox",name="alphacol",label="Fix alphacolor (typesetter a shit)",value=false    },
	{x=2,y=11,width=1,height=1,class="checkbox",name="notag",label="Remove all {\\tags} from selected lines",value=false    },
	
	{x=3,y=0,width=1,height=12,class="label",label="| \n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|",},

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
	{x=4,y=11,width=1,height=1,class="checkbox",name="clip",label="(i)clip",value=false },
	
	{x=5,y=1,width=1,height=1,class="checkbox",name="color1",label="c, 1c",value=false },
	{x=5,y=2,width=1,height=1,class="checkbox",name="color2",label="2c",value=false },
	{x=5,y=3,width=1,height=1,class="checkbox",name="color3",label="3c",value=false },
	{x=5,y=4,width=1,height=1,class="checkbox",name="color4",label="4c",value=false },
	{x=5,y=5,width=1,height=1,class="checkbox",name="alpha",label="alpha",value=false },
	{x=5,y=6,width=1,height=1,class="checkbox",name="alfa1",label="1a",value=false },
	{x=5,y=7,width=1,height=1,class="checkbox",name="alfa2",label="2a",value=false },
	{x=5,y=8,width=1,height=1,class="checkbox",name="alfa3",label="3a",value=false },
	{x=5,y=9,width=1,height=1,class="checkbox",name="alfa4",label="4a",value=false },
	{x=5,y=10,width=1,height=1,class="checkbox",name="ital",label="i",value=false },
	{x=5,y=11,width=1,height=1,class="checkbox",name="bold",label="b",value=false },

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
	{x=6,y=11,width=1,height=1,class="checkbox",name="trans",label="t",value=false },
	} 
	
	pressed, res = aegisub.dialog.display(dialog_config,
	{"Run selected","Comments","Tags","Dial 5","Cancer","^ Kill checked tags"},{cancel='Cancer'})
	
	if pressed=="Cancer" then aegisub.cancel() end
	
	if pressed=="^ Kill checked tags" then killemall(subs, sel) end
	
	if pressed=="Comments" then res.nocom=true cleanlines(subs, sel) end
	if pressed=="Tags" then res.notag=true cleanlines(subs, sel) end
	if pressed=="Dial 5" then res.layers=true cleanlines(subs, sel) end

	if pressed=="Run selected" then 
		
	    if res["all"] then 
			cleanlines(subs, sel)
			sel=noemptycom(subs, sel)
			
	    else	cleanlines(subs, sel)

		if res["nocomline"] and res["noempty"] then sel=noemptycom(subs, sel)
		else
		    if res["nocomline"] then sel=nocom_line(subs, sel) end
		    if res["noempty"] then sel=noempty(subs, sel) end
		end
	    end
	end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, cleanup)