-- This will change \r[style] to tags with the [style]'s properties. Works with multiple \r's in the line.

script_name="Reset-to-tags"
script_description="Replaces \\r[style] with the [style]'s actual properties"
script_author="unanimated"
script_version="1.0"

keep_r=false	-- this will keep non-style properties like rotations for the whole line. change to 'true' to have the real \r effect.

function r2t(subs, sel)
    for x, i in ipairs(sel) do
	line=subs[i]
        text=line.text
	style1=line.style
	text=text:gsub("\\r([\\}])","\\r"..style1.."%1")
	for R in text:gmatch("\\r([^\\}]+)") do 
		style2=R
		sr1=stylechk(subs,style1)
		sr2=stylechk(subs,style2)
		if keep_r then newstyle="\\r" else newstyle="" end
		
		border="\\bord"..sr2.outline
		shadow="\\shad"..sr2.shadow
		size="\\fs"..sr2.fontsize
		space="\\fsp"..sr2.spacing
		scalex="\\fscx"..sr2.scale_x
		scaley="\\fscy"..sr2.scale_y
		name="\\fn"..sr2.fontname
		if sr2.bold then bold="\\b1" else bold="\\b0" end
		if sr2.italic then italic="\\i1" else italic="\\i0" end
		c1="\\c"..sr2.color1:gsub("H%x%x","H")
		c2="\\2c"..sr2.color2:gsub("H%x%x","H")
		c3="\\3c"..sr2.color3:gsub("H%x%x","H")
		c4="\\4c"..sr2.color4:gsub("H%x%x","H")
		a1="\\1a&"..sr2.color1:match("H%x%x").."&"
		a2="\\2a&"..sr2.color2:match("H%x%x").."&"
		a3="\\3a&"..sr2.color3:match("H%x%x").."&"
		a4="\\4a&"..sr2.color4:match("H%x%x").."&"
		
		if sr1.outline~=sr2.outline then add(border) end
		if sr1.shadow~=sr2.shadow then add(shadow) end
		if sr1.fontname~=sr2.fontname then add(name) end
		if sr1.fontsize~=sr2.fontsize then add(size) end
		if sr1.spacing~=sr2.spacing then add(space) end
		if sr1.scale_x~=sr2.scale_x then add(scalex) end
		if sr1.scale_y~=sr2.scale_y then add(scaley) end
		if sr1.color1:gsub("H%x%x","H")~=sr2.color1:gsub("H%x%x","H") then add(c1) end
		if sr1.color2:gsub("H%x%x","H")~=sr2.color2:gsub("H%x%x","H") then add(c2) end
		if sr1.color3:gsub("H%x%x","H")~=sr2.color3:gsub("H%x%x","H") then add(c3) end
		if sr1.color4:gsub("H%x%x","H")~=sr2.color4:gsub("H%x%x","H") then add(c4) end
		if sr1.color1:match("H%x%x")~=sr2.color1:match("H%x%x") then add(a1) end
		if sr1.color2:match("H%x%x")~=sr2.color2:match("H%x%x") then add(a2) end
		if sr1.color3:match("H%x%x")~=sr2.color3:match("H%x%x") then add(a3) end
		if sr1.color4:match("H%x%x")~=sr2.color4:match("H%x%x") then add(a4) end
		if sr1.bold~=sr2.bold then add(bold) end
		if sr1.italic~=sr2.italic then add(italic) end
		
		text=text:gsub("\\r"..style2,newstyle)
		style1=style2
	end

	line.text=text
	subs[i]=line
    end
    aegisub.set_undo_point(script_name)
    return sel
end

function add(x) newstyle=newstyle..x end

function stylechk(subs,stylename)
  for i=1, #subs do
    if subs[i].class=="style" then
      local st=subs[i]
      if stylename==st.name then styleref=st break end
    end
  end
  return styleref
end

aegisub.register_macro(script_name, script_description, r2t)