-- switches between bold and regular [based on style and tags]
-- supports multiple \b tags in a line by switching 0 to 1 and vice versa

script_name = "Bold"
script_description = "Bold"
script_author = "unanimated"
script_version = "1.5"

include("karaskel.lua")

function bold(subs, sel, active_line)
	local meta,styles=karaskel.collect_head(subs,false)
	for z, i in ipairs(sel) do
		local l=subs[i]
		text=l.text
		karaskel.preproc_line(sub,meta,styles,l)
		local sb=l.styleref.bold
		if sb==false then b="1" else b="0" end
		    if text:match("^{[^}]*\\b%d[^}]*}") then
			text=text:gsub("\\b(%d)", function(num) return "\\b"..(1-num) end)
		    else
			if text:match("\\b([01])") then bolt=text:match("\\b([01])") end
			if bolt==b then text=text:gsub("\\b(%d)", function(num) return "\\b"..(1-num) end) end
			text="{\\b"..b.."}"..text
			text=text:gsub("{\\b(%d)}({\\[^}]*)}","%1\\b%1}")
		    end
		l.text=text
		subs[i]=l
	end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, bold)