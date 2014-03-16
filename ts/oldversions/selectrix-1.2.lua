-- alternative to aegisub's select tool. unlike that one, this can also select by layer. 

script_name = "Selectricks"
script_description = "Does tricks with selecting"
script_author = "unanimated"
script_version = "1.2"

-- SETTINGS --				you can choose from the options below to change the default settings

search_in="layer"			-- "layer","style","actor","effect","text"
select_from="current selection"		-- "current selection","all lines"
matches_or_not="matches"		-- "matches","doesn't match"
numbers_option="=="			-- "==",">=","<="
case_sensitive=false			-- true/false
exact_match=false			-- true/false
use_regexp=false			-- true/false
exclude_commented=true			-- true/false

-- end of settings --

include("unicode.lua")

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

    for i = 1, #subs do
      if subs[i].class == "dialogue" then
	local line = subs[i]
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
    local line = subs[sel[i]]
    if res.nocom and line.comment then table.remove(sel,i) end
    end
    
    return sel
end

function inverse(subs,sel)
si=1
sel2={}
    for i = 1,#subs  do
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
	dialog_config=
	{
	    {x=0,y=0,width=1,height=1,class="label",label="Select by:"},
	    {x=0,y=1,width=1,height=1,class="label",label="Select from:"},
	    {x=0,y=2,width=1,height=1,class="label",label="Numbers:"},
	    {x=1,y=0,width=1,height=1,class="dropdown",name="mode",value=search_in,
	items={"------numbers------","layer","duration","word count","character count","--------text--------","style","actor","effect","text"}},
	    {x=1,y=1,width=1,height=1,class="dropdown",name="selection",value=select_from,items={"current selection","all lines"}},
	    {x=1,y=2,width=1,height=1,class="dropdown",name="equal",value=numbers_option,items={"==",">=","<="},
							hint="options for layer/duration"},
	    {x=1,y=3,width=1,height=1,class="dropdown",name="nomatch",value=matches_or_not,items={"matches","doesn't match"}},
	    
	    {x=0,y=4,width=1,height=1,class="label",label="Match this:"},
	    {x=1,y=4,width=3,height=1,class="edit",name="match",value=""},
	    
	    {x=2,y=0,width=2,height=1,class="checkbox",name="nocom",label="exclude commented lines",value=exclude_commented},
	    {x=2,y=1,width=1,height=1,class="label",label="Text:  "},
	    {x=3,y=1,width=1,height=1,class="checkbox",name="case",label="case sensitive",value=case_sensitive},
	    {x=3,y=2,width=1,height=1,class="checkbox",name="exact",label="exact match",value=exact_match},
	    {x=3,y=3,width=1,height=1,class="checkbox",name="regexp",label="use regexp",value=use_regexp},
	    
	}
	buttons={"Set Selection","Help","Cancel"}
	pressed, res = aegisub.dialog.display(dialog_config,buttons,{ok='Set Selection',cancel='Cancel'})
	if pressed=="Cancel" then aegisub.cancel() end

	if pressed=="Set Selection" and res.selection=="current selection" then slct(subs, sel) end
	if pressed=="Set Selection" and res.selection=="all lines" then slctall(subs, sel) 
	if res.nomatch=="doesn't match" then inverse(subs,sel) end
	end
	if pressed=="Help" then aegisub.dialog.display({{x=0,y=0,width=2,height=10,class="label",
		label="'Select by'\nThis is what the search string is compared against.\nThere are 4 'numbers' items and 4 'text' items.\n\n'Select from'\n'current selection' - only lines in the current selection will be scanned.\n\n'Numbers.'\nFor 'numbers' items, you can select lines with higher \nor lower layer/duration instead of just exact match.\n\n'Match this'\nOnly numbers for 'numbers' items. Duration is in milliseconds.\n\n'case sensitive'\nObviously applies only to 'text' items.\n\n'exact match'\nSame.\n\n'use regexp'\nNot sure how well this is working, but it should work.\nOnly for 'text' items."}},
	{"OK"},{close="OK"}) end

end

function selector(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    if res.nomatch=="doesn't match" then return sel2 else return sel end
end

aegisub.register_macro(script_name, script_description, selector)