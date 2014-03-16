-- italicizes or unitalicizes text [based on style and tags]
-- supports multiple \i tags in a line by switching 0 to 1 and vice versa

script_name = "Italicize"
script_description = "Italicizes or unitalicizes text"
script_author = "unanimated"
script_version = "1.3"

include("karaskel.lua")

function italicize(subs, sel, active_line)
	local meta,styles=karaskel.collect_head(subs,false)
	for z, i in ipairs(sel) do
		local l = subs[i]
		karaskel.preproc_line(sub,meta,styles,l)
		local ita = l.styleref.italic
		    if l.text:match("^{.*\\i%d.*}") then
				l.text = l.text:gsub("\\i(%d)", function(num) return "\\i"..(1-num) end)
		    else
			if ita == false then
				l.text = l.text:gsub("\\i(%d)", function(num) return "\\i"..(1-num) end)
				l.text = "{\\i1}" .. l.text
				l.text = l.text:gsub("{\\i1}({\\[^}]*)}","%1\\i1}")
				else
				l.text = l.text:gsub("\\i(%d)", function(num) return "\\i"..(1-num) end)
				l.text = "{\\i0}" .. l.text
				l.text = l.text:gsub("{\\i0}({\\[^}]*)}","%1\\i0}")
			end
		    end
		subs[i] = l
	end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, italicize)