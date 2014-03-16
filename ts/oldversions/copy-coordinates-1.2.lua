-- Copies coordinates (whatever's in parentheses) from first selected line to the rest of selected lines.
-- Works with \pos, \move, \org, \clip, \iclip, \t\clip, \t\iclip.

script_name = "Copy Coordinates"
script_description = "Copy pos, move, org, clip coordinates from first line to others"
script_author = "unanimated"
script_version = "1.2"

function replace(subs, sel)
    for x, i in ipairs(sel) do
        local line = subs[i]
        local text = subs[i].text
	if not text:match("^{\\") then text=text:gsub("^","{\\}") end

	if res["pos"]==true then
		if x==1 and text:match("\\pos") then
		posi=text:match("\\pos%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\pos") and posi~=nil	 then
		text=text:gsub("\\pos%([^%)]-%)","\\pos%("..posi.."%)")
		end
		if x~=1 and not text:match("\\pos") and posi~=nil and res.cre then
		text=text:gsub("^{\\","{\\pos%("..posi.."%)\\")
		end
	end
	
	if res["mov"]==true then
		if x==1 and text:match("\\move") then
		move=text:match("\\move%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\move") and move~=nil then
		text=text:gsub("\\move%([^%)]-%)","\\move%("..move.."%)")
		end
		if x~=1 and not text:match("\\move") and move~=nil and res.cre then
		text=text:gsub("^{\\","{\\move%("..move.."%)\\")
		end
	end
	
	if res["org"]==true then
		if x==1 and text:match("\\org") then
		orig=text:match("\\org%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\org") and orig~=nil then
		text=text:gsub("\\org%([^%)]-%)","\\org%("..orig.."%)")
		end
		if x~=1 and not text:match("\\org") and orig~=nil and res.cre then
		text=text:gsub("^({\\[^}]*)}","%1\\org%("..orig.."%)}")
		end
	end
	
	if res["clip"]==true then
		if x==1 and text:match("\\i?clip") then
		klip=text:match("\\i?clip%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\i?clip") and klip~=nil then
		text=text:gsub("\\(i?clip)%([^%)]-%)","\\%1%("..klip.."%)")
		end
		if x~=1 and not text:match("\\i?clip") and klip~=nil and res.cre then
		text=text:gsub("^({\\[^}]*)}","%1\\clip%("..klip.."%)}")
		end
	end
	
	if res["tclip"]==true then
		if x==1 and text:match("\\t%([%d%.%,]*\\i?clip") then
		tklip=text:match("\\t%([%d%.%,]*\\i?clip%(([^%)]-)%)")
		end
		if x~=1 and text:match("\\i?clip") and tklip~=nil then
		text=text:gsub("\\t%(([%d%.%,]*)\\(i?clip)%([^%)]-%)","\\t%(%1\\%2%("..tklip.."%)")
		end
		if x~=1 and not text:match("\\t%([%d%.%,]*\\i?clip") and tklip~=nil and res.cre then
		text=text:gsub("^({\\[^}]*)}","%1\\t%(\\clip%("..tklip.."%)%)}")
		end
	end

	text=text
	:gsub("\\\\","\\")
	:gsub("\\}","}")
	:gsub("{}","")
	
	line.text = text
	subs[i] = line
    end
    posi, move, orig, klip, tklip=nil
end

function konfig(subs, sel)
	dialog_config=
	{
	    {	x=0,y=0,width=2,height=1,class="label",label="Copy from first line to the rest"},
	    {	x=0,y=1,width=1,height=1,class="checkbox",name="pos",label="\\pos",value=true },
	    {	x=0,y=2,width=1,height=1,class="checkbox",name="mov",label="\\move",value=true },
	    {	x=0,y=3,width=1,height=1,class="checkbox",name="org",label="\\org",value=true },
	    {	x=1,y=1,width=1,height=1,class="checkbox",name="clip",label="\\[i]clip",value=true },
	    {	x=1,y=2,width=1,height=1,class="checkbox",name="tclip",label="\\t(\\[i]clip)",value=true },
	    {	x=0,y=4,width=2,height=1,class="checkbox",name="cre",label="create tags if missing",value=true },
	    
	} 	
	buttons={"Copy","Cancel"}
	pressed, res = aegisub.dialog.display(dialog_config,buttons)
	
	if pressed=="Copy" then replace(subs, sel) end
end

function copytags(subs, sel)
    konfig(subs, sel)
    aegisub.set_undo_point(script_name)
    return sel
end

aegisub.register_macro(script_name, script_description, copytags)