-- alternative to aegisub's select tool. unlike that one, this can also select by layer.
-- version 2.0 includes sorting of selected/all lines, by the same markers as the selecting uses.

script_name="Selectricks"
script_description="Selectricks and Sortricks"
script_author="unanimated"
script_version="2.0"

-- SETTINGS --				you can choose from the options below to change the default settings

search_in="text"			-- "layer","style","actor","effect","text"
select_from="current selection"		-- "current selection","all lines"
matches_or_not="matches"		-- "matches","doesn't match"
numbers_option="=="			-- "==",">=","<="
case_sensitive=false			-- true/false
exact_match=false			-- true/false
use_regexp=false			-- true/false
exclude_commented=true			-- true/false
load_in_editor=false			-- true/false
remember_last=true			-- true/false [will remember last search string]
your_retarded=false			-- set to true if your skiddiks

-- end of settings --

require "clipboard"

function slct(subs, sel)
sel2={}
	if res.regexp then res.match=res.match:gsub("%\\","%%") :gsub("%%%%","\\") end
	
    for i=#sel,1,-1 do
	local line=subs[sel[i]]
	local text=line.text
	a=sel[i]
	dur=line.end_time-line.start_time
	eq=res.equal
	txt=text:gsub("{[^}]-}","") :gsub("\\N","")
	wrd=0	for word in txt:gmatch("([%a\']+)") do wrd=wrd+1 end
	char=txt:len()
	if res.mode=="style" then search_area=line.style end
	if res.mode=="actor" then search_area=line.actor end
	if res.mode=="effect" then search_area=line.effect end
	if res.mode=="text" then search_area=line.text end
	if res.mode=="visible text (no tags)" then search_area=line.text:gsub("{[^}]-}","") end
	if res.mode=="layer" then numb=line.layer end
	if res.mode=="duration" then numb=dur end
	if res.mode=="word count" then numb=wrd end
	if res.mode=="character count" then numb=char end
	
	nonregexp=esc(res.match)
	nonregexplower=nonregexp:lower()
	regexplower=res.match:lower()
	
	
	if res.mode=="layer" or res.mode=="duration" or res.mode=="word count" or res.mode=="character count" then 
	numbers=true else numbers=false end
	
	if numbers==false then s_area_lower=search_area:lower() end
	
	if numbers then
	if eq=="==" and numb~=tonumber(res.match) then table.remove(sel,i) end
	if eq==">=" and numb<tonumber(res.match) then table.remove(sel,i) end
	if eq=="<=" and numb>tonumber(res.match) then table.remove(sel,i) end
	end
	
      if numbers==false then
	if res.case then
	  if res.exact then if search_area~=res.match then table.remove(sel,i) end
	  else
	    if res.regexp then
		if not search_area:match(res.match) then  table.remove(sel,i) end
	    else 
	    
		if not search_area:match(nonregexp) then  table.remove(sel,i) end
	    end
	  end
	end
	
	if not res.case then
	  if res.exact then if s_area_lower~=res.match:lower() then table.remove(sel,i) end
	  else
	    if res.regexp then
		if not s_area_lower:match(regexplower) then  table.remove(sel,i) end
	    else
		if not s_area_lower:match(nonregexplower) then  table.remove(sel,i) end
	    end
	  end
	end
      end
	
	if res.nocom and line.comment and sel[i]==a then table.remove(sel,i) end
	
	if sel[i]~=a then 
		if res.nocom and line.comment then
		else
		table.insert(sel2,a) 
		end
	end
    end
  
    if res.nomatch=="doesn't match" then return sel2 else return sel end
end

function slctall(subs, sel)
    for i=#sel,1,-1 do	table.remove(sel,i) end
    if res.regexp then res.match=res.match:gsub("%\\","%%") :gsub("%%%%","\\") end

    for i=1, #subs do
      if subs[i].class == "dialogue" then
	local line=subs[i]
	local text=line.text
	a=sel[i]
	dur=line.end_time-line.start_time
	eq=res.equal
	txt=text:gsub("{[^}]-}","") :gsub("\\N","")
	wrd=0	for word in txt:gmatch("([%a\']+)") do wrd=wrd+1 end
	char=txt:len()
	if res.mode=="style" then search_area=line.style end
	if res.mode=="actor" then search_area=line.actor end
	if res.mode=="effect" then search_area=line.effect end
	if res.mode=="text" then search_area=line.text end
	if res.mode=="visible text (no tags)" then search_area=line.text:gsub("{[^}]-}","") end
	if res.mode=="layer" then numb=line.layer end
	if res.mode=="duration" then numb=dur end
	if res.mode=="word count" then numb=wrd end
	if res.mode=="character count" then numb=char end
	
	nonregexp=esc(res.match)
	nonregexplower=nonregexp:lower()
	regexplower=res.match:lower()
	
	if res.mode=="layer" or res.mode=="duration" or res.mode=="word count" or res.mode=="character count" then 
	numbers=true else numbers=false end
	
	if numbers==false then s_area_lower=search_area:lower() end
	
	if numbers then
	if eq=="==" and numb==tonumber(res.match) then table.insert(sel,i) end
	if eq==">=" and numb>=tonumber(res.match) then table.insert(sel,i) end
	if eq=="<=" and numb<=tonumber(res.match) then table.insert(sel,i) end
	end

      if numbers==false then
	if res.case then
	  if res.exact then if search_area==res.match then table.insert(sel,i) end
	  else
	    if res.regexp then 
		if search_area:match(res.match) then  table.insert(sel,i) end
	    else 
		if search_area:match(nonregexp) then  table.insert(sel,i) end
	    end
	  end
	end
	
	if not res.case then
	  if res.exact then if s_area_lower==res.match:lower() then table.insert(sel,i) end
	  else
	    if res.regexp then 
		if s_area_lower:match(regexplower) then  table.insert(sel,i) end
	    else 
		if s_area_lower:match(nonregexplower) then  table.insert(sel,i) end
	    end
	  end
	end
      end
	
      end
    end
    
    for i=#sel,1,-1 do	
    local line=subs[sel[i]]
    if res.nocom and line.comment then table.remove(sel,i) end
    end
    
    return sel
end

function inverse(subs,sel)
si=1
sel2={}
    for i=1,#subs do
	local line=subs[i]
        if subs[i].class == "dialogue" then
	    if i~=sel[si] then
		if res.nocom and line.comment then else
		table.insert(sel2,i)	end
	    else
	    si=si+1
	    end
	end
    end
    return sel2
end

function preset(subs, sel)
for i=#sel,1,-1 do	table.remove(sel,i) end
    for i=1,#subs do
	if subs[i].class=="dialogue" then
	local line=subs[i]
	local text=line.text
	local nc=text:gsub("{[^\\}]-}","")
	    if res.pres=="Default style - All" then
		if line.style:match("Defa") or line.style:match("Alt") then table.insert(sel,i) end
	    end
	    if res.pres=="nonDefault - All" then
		if not line.style:match("Defa") and not line.style:match("Alt") then table.insert(sel,i) end
	    end
	    if res.pres=="OP in style" then
		if line.style:match("OP") then table.insert(sel,i) end
	    end
	    if res.pres=="ED in style" then
		if line.style:match("ED") then table.insert(sel,i) end
	    end
	    if res.pres=="layer 0" then
		if line.layer==0 then table.insert(sel,i) end
	    end
	    if res.pres=="skiddiks, your their?" then
	      if line.style:match("Defa") or line.style:match("Alt") then
		if nc:match("[Yy]ou\'?re?%s")
		or nc:match("[Tt]hey?\'?re")
		or nc:match("[Tt]heir")
		then table.insert(sel,i)
		if your_retarded then line.effect=line.effect.." your retarded" subs[i]=line end
		end
	      end
	    end
	end
    end
    return sel
end

function esc(str)
	str=str:gsub("%%","%%%%")
	str=str:gsub("%(","%%%(")
	str=str:gsub("%)","%%%)")
	str=str:gsub("%[","%%%[")
	str=str:gsub("%]","%%%]")
	str=str:gsub("%.","%%%.")
	str=str:gsub("%*","%%%*")
	str=str:gsub("%-","%%%-")
	str=str:gsub("%+","%%%+")
	str=str:gsub("%?","%%%?")
	return str
end

function konfig(subs, sel)
	if lastmatch==nil then lastmatch="" end
	dialog_config=
	{
	    {x=0,y=0,width=1,height=1,class="label",label="Select by:"},
	    {x=0,y=1,width=1,height=1,class="label",label="Select from:"},
	    {x=0,y=2,width=1,height=1,class="label",label="Numbers:"},
	    {x=1,y=0,width=1,height=1,class="dropdown",name="mode",value=search_in,
		items={"------numbers------","layer","duration","word count","character count","--------text--------","style","actor","effect","text","visible text (no tags)"}},
	    {x=1,y=1,width=1,height=1,class="dropdown",name="selection",value=select_from,items={"current selection","all lines"}},
	    {x=1,y=2,width=1,height=1,class="dropdown",name="equal",value=numbers_option,items={"==",">=","<="},
							hint="options for layer/duration"},
	    {x=1,y=3,width=1,height=1,class="dropdown",name="nomatch",value=matches_or_not,items={"matches","doesn't match"}},
	    
	    {x=0,y=4,width=1,height=1,class="label",label="Match this:"},
	    {x=1,y=4,width=3,height=1,class="edit",name="match",value=lastmatch},
	    
	    {x=0,y=5,width=1,height=1,class="label",label="Preset:"},
	    {x=1,y=5,width=1,height=1,class="dropdown",name="pres",value="Default style - All",
	    items={"Default style - All","nonDefault - All","OP in style","ED in style","layer 0","skiddiks, your their?"}},
	    
	    {x=2,y=0,width=1,height=1,class="label",label="Text:  "},
	    {x=3,y=0,width=1,height=1,class="checkbox",name="case",label="case sensitive",value=case_sensitive},
	    {x=3,y=1,width=1,height=1,class="checkbox",name="exact",label="exact match",value=exact_match},
	    {x=2,y=1,width=1,height=1,class="checkbox",name="regexp",label="regexp",value=use_regexp},
	    {x=2,y=2,width=2,height=1,class="checkbox",name="nocom",label="exclude commented lines",value=exclude_commented},
	    
	    {x=2,y=3,width=1,height=1,class="label",label="Sotring:"},
	    {x=3,y=3,width=1,height=1,class="checkbox",name="rev",label="reversed",value=false},
	    
	    {x=2,y=5,width=2,height=1,class="checkbox",name="editor",label="load results in an editor",value=load_in_editor},
	    
	}
	buttons={"Set Selection","Preset","Sort","Cancel"}
	pressed, res=aegisub.dialog.display(dialog_config,buttons,{ok='Set Selection',close='Cancel'})
	if pressed=="Cancel" then aegisub.cancel() end
	if pressed=="Preset" then preset(subs, sel) end
	if pressed=="Sort" and res.selection=="current selection" then sorting(subs, sel) end
	if pressed=="Sort" and res.selection=="all lines" then sel=selectall(subs, sel) sorting(subs, sel) end

	if pressed=="Set Selection" and res.selection=="current selection" then slct(subs, sel) end
	if pressed=="Set Selection" and res.selection=="all lines" then slctall(subs, sel) 
	if res.nomatch=="doesn't match" then inverse(subs,sel) end
	end
	if pressed=="Help" then aegisub.dialog.display({{x=0,y=0,width=2,height=10,class="label",
		label="'Select by'\nThis is what the search string is compared against.\nThere are 4 'numbers' items and 4 'text' items.\n\n'Select from'\n'current selection' - only lines in the current selection will be scanned.\n\n'Numbers.'\nFor 'numbers' items, you can select lines with higher \nor lower layer/duration instead of just exact match.\n\n'Match this'\nOnly numbers for 'numbers' items. Duration is in milliseconds.\n\n'case sensitive'\nObviously applies only to 'text' items.\n\n'exact match'\nSame.\n\n'use regexp'\nNot sure how well this is working, but it should work.\nOnly for 'text' items."}},
	{"OK"},{close="OK"}) end
	if remember_last then lastmatch=res.match end

end

function editlines(subs, sel)
	editext=""
	dura=""
    for x, i in ipairs(sel) do
        local line=subs[i]
	local text=subs[i].text
	dur=line.end_time-line.start_time
	dur=dur/1000
	      if x~=#sel then editext=editext..text.."\n" dura=dura..dur.."\n" end
	      if x==#sel then editext=editext..text dura=dura..dur end
	subs[i]=line
    end
    editbox(subs, sel)
    if failt==1 then editext=res.dat editbox(subs, sel) end
    return sel
end

function selectall(subs, sel)
sel={}
    for i=1, #subs do
	if subs[i].class=="dialogue" then table.insert(sel,i) end
    end
    return sel
end

function sorting(subs,sel)
    subtable={}
    -- lines into table
    for x, i in ipairs(sel) do
	local l=subs[i]
	l.i=x
	table.insert(subtable,l)
    end
    -- sort lines
    if res.mode=="layer" then table.sort(subtable,function(a,b) return a.layer<b.layer or (a.layer==b.layer and a.i<b.i) end) end
    if res.mode=="duration" then table.sort(subtable,function(a,b) 
	return a.end_time-a.start_time<b.end_time-b.start_time or (a.end_time-a.start_time==b.end_time-b.start_time and a.i<b.i) end) end
    if res.mode=="actor" then table.sort(subtable, function(a,b) return a.actor<b.actor or (a.actor==b.actor and a.i<b.i) end) end
    if res.mode=="effect" then table.sort(subtable,function(a,b) return a.effect<b.effect or (a.effect==b.effect and a.i<b.i) end) end
    if res.mode=="style" then table.sort(subtable,function(a,b) return a.style<b.style or (a.style==b.style and a.i<b.i) end) end
    if res.mode=="text" then table.sort(subtable,function(a,b) 
	return a.text:lower()<b.text:lower() or (a.text:lower()==b.text:lower() and a.i<b.i) end) end
    if res.mode=="visible text (no tags)" then table.sort(subtable,function(a,b) 
	return a.text:lower():gsub("{[^}]-}","")<b.text:lower():gsub("{[^}]-}","") 
	or (a.text:lower():gsub("{[^}]-}","")==b.text:lower():gsub("{[^}]-}","") and a.i<b.i) end) end
    if res.mode=="word count" then table.sort(subtable,function(a,b)
	txta=a.text:gsub("{[^}]-}","") :gsub("\\N","")
	wrda=0	for word in txta:gmatch("([%a\']+)") do wrda=wrda+1 end
	txtb=b.text:gsub("{[^}]-}","") :gsub("\\N","")
	wrdb=0	for word in txtb:gmatch("([%a\']+)") do wrdb=wrdb+1 end
	return wrda<wrdb or (wrda==wrdb and a.i<b.i) end) end
    if res.mode=="character count" then table.sort(subtable,function(a,b)
	txta=a.text:gsub("{[^}]-}","") :gsub("\\N","")	chara=txta:len()
	txtb=b.text:gsub("{[^}]-}","") :gsub("\\N","")	charb=txtb:len()
	return chara<charb or (chara==charb and a.i<b.i) end) end
    -- lines back
    for x, i in ipairs(sel) do
	local l=subtable[x]
	local r=subtable[#subtable-x+1]
	if res.rev then subs[i]=r else subs[i]=l end
    end
end

function esc(str)
	str=str:gsub("%%","%%%%")
	str=str:gsub("%(","%%%(")
	str=str:gsub("%)","%%%)")
	str=str:gsub("%[","%%%[")
	str=str:gsub("%]","%%%]")
	str=str:gsub("%.","%%%.")
	str=str:gsub("%*","%%%*")
	str=str:gsub("%-","%%%-")
	str=str:gsub("%+","%%%+")
	str=str:gsub("%?","%%%?")
	return str
end

function editbox(subs, sel)
	if #sel<=4 then boxheight=6 end
	if #sel>=5 and #sel<9 then boxheight=8 end
	if #sel>=9 and #sel<15 then boxheight=math.ceil(#sel*0.8) end
	if #sel>=15 and #sel<18 then boxheight=12 end
	if #sel>=18 then boxheight=15 end
	dialog=
	{
	    {x=0,y=0,width=35,height=1,class="label",label="Text"},
	    {x=35,y=0,width=5,height=1,class="label",label="Duration"},
	    
	    {x=0,y=1,width=35,height=boxheight,class="textbox",name="dat",value=editext},
	    {x=35,y=1,width=5,height=boxheight,class="textbox",name="durr",value=dura,hint="This is informative only. \nIt will not be saved."},
	    
	    {x=15,y=boxheight+1,width=20,height=1,class="edit",name="info",value="Lines loaded: "..#sel..", Characters: "..editext:len() },
	    
	    {x=0,y=boxheight+1,width=1,height=1,class="label",label="Replace:"},
	    {x=1,y=boxheight+1,width=1,height=1,class="edit",name="rep1",value=""},
	    {x=2,y=boxheight+1,width=1,height=1,class="label",label="with"},
	    {x=3,y=boxheight+1,width=1,height=1,class="edit",name="rep2",value=""},

	} 	
	buttons={"Save","Replace","Remove tags","Rm. comments","Remove \"- \"","Remove \\N","Add italics","Add \\an8","Reload text","Cancel"}
	repeat
	if pressed=="Replace" or pressed=="Add italics" or pressed=="Add \\an8" or pressed=="Remove \\N" or pressed=="Reload text"
		or pressed=="Remove tags" or pressed=="Rm. comments" or pressed=="Remove \"- \"" then
		
		if pressed=="Add italics" then
		res.dat=res.dat	:gsub("$","\n") :gsub("(.-)\n","{\\i1}%1\n") :gsub("{\\i1}{\\","{\\i1\\") :gsub("\n$","") end
		if pressed=="Add \\an8" then
		res.dat=res.dat	:gsub("$","\n") :gsub("(.-)\n","{\\an8}%1\n") :gsub("{\\an8}{\\","{\\an8\\") :gsub("\n$","") end
		if pressed=="Remove \\N" then res.dat=res.dat	:gsub("%s?\\N%s?"," ") end
		if pressed=="Remove tags" then res.dat=res.dat:gsub("{\\[^}]-}","") end
		if pressed=="Rm. comments" then res.dat=res.dat:gsub("{[^\\}]-}","") :gsub("{[^\\}]-\\N[^\\}]-}","") end
		if pressed=="Remove \"- \"" then res.dat=res.dat:gsub("%-%s","") end
		if pressed=="Replace" then rep1=esc(res.rep1)
		res.dat=res.dat:gsub(rep1,res.rep2)
		end
		
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
	pressed, res=aegisub.dialog.display(dialog,buttons,{save='Save',close='Cancel'})
	until pressed~="Add italics" and pressed~="Add \\an8" and pressed~="Remove \\N" and pressed~="Reload text" 
		and pressed~="Remove tags"and pressed~="Rm. comments" and pressed~="Remove \"- \"" and pressed~="Replace"

	if pressed=="Cancel" then aegisub.cancel() end
	if pressed=="Save" then savelines(subs, sel) end
	return sel
end

function savelines(subs, sel)
    local data={}	raw=res.dat.."\n"
    if #sel==1 then raw=raw:gsub("\n(.)","\\N%1") end
    for dataline in raw:gmatch("(.-)\n") do table.insert(data,dataline) end
    failt=0    
    if #sel~=#data and #sel>1 then failt=1 else
	for x, i in ipairs(sel) do
        local line=subs[i]
	local text=subs[i].text
	text=data[x]
	line.text=text
	subs[i]=line
	end
    end
    if failt==1 then aegisub.dialog.display({{class="label",
		    label="Line count of edited text does not \nmatch the number of selected lines.",x=0,y=0,width=1,height=2}},{"OK"})  
		    clipboard.set(res.dat) end
	aegisub.set_undo_point(script_name)
	return sel
end

function selector(subs, sel)
    konfig(subs, sel)
    if res.editor then editlines(subs, sel) end
    aegisub.set_undo_point(script_name)
    if res.nomatch=="doesn't match" and pressed=="Set Selection" then return sel2 else return sel end
end

aegisub.register_macro(script_name, script_description, selector)