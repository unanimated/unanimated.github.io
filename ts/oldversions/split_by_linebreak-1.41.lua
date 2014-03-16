script_name = "Split by Linebreaks"
script_description = "Split by Linebreaks"	-- make a new line for each \N, keep initial tags for every line
script_author = "unanimated"
script_version = "1.2"		-- allow splitting by spaces if no \N

function splitbreak(subs, sel)		-- 1.41
	for i=#sel,1,-1 do
	  line=subs[sel[i]]
	  text=subs[sel[i]].text
	    text=text:gsub("({[^}]-})",function (a) return debreak(a) end)
	    
	    if not text:match("\\N") then
	    pressed=aegisub.dialog.display({{class="label",
	    label="Selection line "..i.." has no \\N. \nSplit by spaces?",x=0,y=0,width=1,height=2}},{"Yes","No","Cancel"})
	      if pressed=="Cancel" then aegisub.cancel() end
	      
	      -- split by spaces
	      if pressed=="Yes" then 
		line2=line
		    text=text:gsub("({[^}]-})",function (a) return despace(a) end)
		if text:match("^{\\") then				-- lines 2+, with initial tags
		    tags=text:match("^({\\[^}]*})")			-- initial tags
		    if tags==nil then tags="" end
		    count=0
		    text=text:gsub("^({\\[^}]*})","%1 ")		-- add space
		    for aftern in text:gmatch("%s+([^%s]+)") do	-- part after \N [*]
		     aftern=aftern:gsub("_sp_"," ")
		     tags=tags:gsub("_sp_"," ")
		      aftern=aftern:gsub("_break_","\\N")
		      count=count+1
		      line2.text=tags..aftern			-- every new line=initial tags + part after one \N
		      --line2.effect=count
		      line2.text=line2.text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
		      line2.text=duplikill(line2.text)
		      tags=line2.text:match("^({\\[^}]*})")
		    subs.insert(sel[i]+count,line2)			-- insert each match one line further
		    end
		else							-- lines 2+, without initial tags
		    count=0
		    text=" "..text
		    for aftern in text:gmatch("%s+([^%s]+)") do
		    if tags==nil then tags="" end
		    aftern=aftern:gsub("_sp_"," ")
		    aftern=aftern:gsub("_break_","\\N")
		    count=count+1
		    line2.text=tags..aftern
		      line2.text=line2.text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
		      line2.text=duplikill(line2.text)
		      tags=line2.text:match("^({\\[^}]*})")
		    --line2.effect=count
		    subs.insert(sel[i]+count,line2)
		    end
		end
		subs.delete(sel[i])
	      end
	    end
	  
	    -- split by \N
	    if text:match("\\N")then
	    line2=line
		if text:match("%*")then text=text:gsub("%*","_asterisk_") end
		if text:match("^{\\") then				-- lines 2+, with initial tags
		    tags=text:match("^({\\[^}]*})")			-- initial tags
		    tags2=""
		    count=0
		    text=text:gsub("\\N","*")				-- switch \N for *
		    for aftern in text:gmatch("%*%s*([^%*]*)") do	-- part after \N [*]
		      aftern=aftern:gsub("_break_","\\N")	:gsub("%s*$","")	:gsub("_asterisk_","*")
		      if aftern~="" then
		        count=count+1
		        line2.text=tags..aftern				-- every new line=initial tags + part after one \N
		        --line2.effect=count+1
		        line2.text=line2.text:gsub("{(\\[^}]-)}{(\\[^}]-)}","{%1%2}")
		        line2.text=duplikill(line2.text)
		        tags=line2.text:match("^({\\[^}]*})")
		        subs.insert(sel[i]+count,line2)		-- insert each match one line further 
		      end
		    end
		else							-- lines 2+, without initial tags
		    count=0
		    text=text:gsub("\\N","*")
		    for aftern in text:gmatch("%*%s*([^%*]*)") do
		      aftern=aftern:gsub("_break_","\\N")	:gsub("%s*$","")	:gsub("_asterisk_","*")
		      if aftern~="" then
		        count=count+1
		        line2.text=aftern
		        subs.insert(sel[i]+count,line2)
		      end
		    end
		end
		if text:match("^{\\") then				-- line 1, with initial tags
		    text=text:gsub("^({\\[^}]-})(.-)%*(.*)","%1%2")
		    text=text:gsub("_break_","\\N")	:gsub("%s*$","")
		    --line.effect=1
		else							-- line 1, without initial tags
		    text=text:gsub("^(.-)%*(.*)","%1")
		    text=text:gsub("_break_","\\N")	:gsub("%s*$","")
		end
		text=text:gsub("_asterisk_","*")
		
	    line.text=text
	    subs[sel[i]]=line
	    end
	end
	aegisub.set_undo_point(script_name)
end

function despace(txt) txt=txt:gsub("%s","_sp_") return txt end
function debreak(txt) txt=txt:gsub("\\N","_break_") return txt end
function duplikill(text)
	tags1={"blur","be","bord","shad","fs","fsp","fscx","fscy","frz","frx","fry","fax","fay"}
	for i=1,#tags1 do
	    tag=tags1[i]
	    text=text:gsub("\\"..tag.."[%d%.%-]+([^}]-)(\\"..tag.."[%d%.%-]+)","%1%2")
	end
	text=text:gsub("\\1c&","\\c&")
	tags2={"c","2c","3c","4c","1a","2a","3a","4a","alpha"}
	for i=1,#tags2 do
	    tag=tags2[i]
	    text=text:gsub("\\"..tag.."&H%x+&([^}]-)(\\"..tag.."&H%x+&)","%1%2")
	end	
	return text
end

aegisub.register_macro(script_name, script_description, splitbreak)