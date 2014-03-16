-- switches between bold and regular [based on style and tags]
-- supports multiple \b tags in a line by switching 0 to 1 and vice versa

script_name = "Bold"
script_description = "Bold"
script_author = "unanimated"
script_version = "1.3"

include("karaskel.lua")

function bold(subs, sel, active_line)
	local meta,styles=karaskel.collect_head(subs,false)
	for z, i in ipairs(sel) do
		local l = subs[i]
		karaskel.preproc_line(sub,meta,styles,l)
		local b = l.styleref.bold
		    if l.text:match("^{.*\\b%d.*}") then
				l.text = l.text:gsub("\\b(%d)", function(num) return "\\b"..(1-num) end)
		    else
			if b == false then
				l.text = l.text:gsub("\\b(%d)", function(num) return "\\b"..(1-num) end)
				l.text = "{\\b1}" .. l.text
				l.text = l.text:gsub("{\\b1}({\\[^}]*)}","%1\\b1}")
				else
				l.text = l.text:gsub("\\b(%d)", function(num) return "\\b"..(1-num) end)
				l.text = "{\\b0}" .. l.text
				l.text = l.text:gsub("{\\b0}({\\[^}]*)}","%1\\b0}")
			end
		    end
		subs[i] = l
	end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, bold)