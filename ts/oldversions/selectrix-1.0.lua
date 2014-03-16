-- alternative to aegisub's select tool. unlike that one, this can also select by layer. 

script_name = "Selectricks"
script_description = "Does tricks with selecting"
script_author = "unanimated"
script_version = "1.0"

-- SETTINGS --				you can choose from the options below to change the default settings

search_in="layer"			-- "layer","style","actor","effect","text"
select_from="current selection"		-- "current selection","all lines"
matches_or_not="matches"		-- "matches","doesn't match"
case_sensitive=false			-- true/false
exact_match=false			-- true/false
use_regexp=false			-- true/false
exclude_commented=true			-- true/false

-- end of settings --

include("unicode.lua")

function slct(subs, sel)
sel2={}
	
    for i=#sel,1,-1 do
	local line=subs[sel[i]]
	a=sel[i]
	if res.mode=="style" then search_area=line.style end
	if res.mode=="actor" then search_area=line.actor end
	if res.mode=="effect" then search_area=line.effect end
	if res.mode=="text" then search_area=line.text end
	
	nonregexp=esc(res.match)
	nonregexplower=nonregexp:lower()
	regexplower=res.match:lower()
	if res.mode~="layer" then s_area_lower=search_area:lower() end
	
	if res.mode=="layer" then
	if line.layer~=tonumber(res.match) then  table.remove(sel,i) end
	end
	
      if res.mode~="layer" then
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
	    if res.regexp then  aegisub.log("s_area_lower "..s_area_lower.." regexplower "..regexplower)
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

    for i = 1, #subs do
      if subs[i].class == "dialogue" then
	local line = subs[i]
	if res.mode=="style" then search_area=line.style end
	if res.mode=="actor" then search_area=line.actor end
	if res.mode=="effect" then search_area=line.effect end
	if res.mode=="text" then search_area=line.text end
	
	nonregexp=esc(res.match)
	nonregexplower=nonregexp:lower()
	regexplower=res.match:lower()
	if res.mode~="layer" then s_area_lower=search_area:lower() end
	
	if res.mode=="layer" then
	if line.layer==tonumber(res.match) then  table.insert(sel,i) end
	end
	
      if res.mode~="layer" then
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
	    {x=0,y=0,width=1,height=1,class="label",label="Search in:"},
	    {x=0,y=1,width=1,height=1,class="label",label="Select from:"},
	    {x=1,y=0,width=1,height=1,class="dropdown",name="mode",value=search_in,items={"layer","style","actor","effect","text"}},
	    {x=1,y=1,width=1,height=1,class="dropdown",name="selection",value=select_from,items={"current selection","all lines"}},
	    {x=1,y=2,width=1,height=1,class="dropdown",name="nomatch",value=matches_or_not,items={"matches","doesn't match"}},
	    
	    {x=0,y=3,width=1,height=1,class="label",label="Match this:"},
	    {x=1,y=3,width=3,height=1,class="edit",name="match",value=""},
	    
	    {x=3,y=0,width=1,height=1,class="checkbox",name="case",label="case sensitive",value=case_sensitive},
	    {x=3,y=1,width=1,height=1,class="checkbox",name="exact",label="exact match",value=exact_match},
	    {x=3,y=2,width=1,height=1,class="checkbox",name="regexp",label="use regexp",value=use_regexp},
	    
	    {x=1,y=4,width=2,height=1,class="checkbox",name="nocom",label="exclude commented lines",value=exclude_commented},
	    {x=4,y=3,width=1,height=1,class="label",label="   "},
	    
	}
	buttons={"Set Selection","Cancel"}
	pressed, res = aegisub.dialog.display(dialog_config,buttons)
	if pressed=="Cancel" then aegisub.cancel() end

	if pressed=="Set Selection" and res.selection=="current selection" then slct(subs, sel) end
	if pressed=="Set Selection" and res.selection=="all lines" then slctall(subs, sel) 
	if res.nomatch=="doesn't match" then inverse(subs,sel) end
	end

end

function selector(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    if res.nomatch=="doesn't match" then return sel2 else return sel end
end

aegisub.register_macro(script_name, script_description, selector)