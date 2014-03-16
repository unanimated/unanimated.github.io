-- italicizes or unitalicizes text [based on style and tags]
-- supports multiple \i tags in a line by switching 0 to 1 and vice versa

script_name = "Italicize"
script_description = "Italicizes or unitalicizes text"
script_author = "unanimated"
script_version = "1.5"

include("karaskel.lua")

function italicize(subs, sel, active_line)
	local meta,styles=karaskel.collect_head(subs,false)
	for z, i in ipairs(sel) do
		local l=subs[i]
		text=l.text
		karaskel.preproc_line(sub,meta,styles,l)
		local si=l.styleref.italic
		if si==false then it="1" else it="0" end
		    if text:match("^{[^}]*\\i%d[^}]*}") then
			text=text:gsub("\\i(%d)", function(num) return "\\i"..(1-num) end)
		    else
			if text:match("\\i([01])") then italix=text:match("\\i([01])") end
			if italix==it then text=text:gsub("\\i(%d)", function(num) return "\\i"..(1-num) end) end
			text="{\\i"..it.."}"..text
			text=text:gsub("{\\i(%d)}({\\[^}]*)}","%1\\i%1}")
		    end
		l.text=text
		subs[i]=l
	end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, italicize)