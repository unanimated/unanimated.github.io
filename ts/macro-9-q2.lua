script_name = "Add q2"			-- adds/removes a \q2 tag
script_description = "adds q2"
script_author = "unanimated"
script_version = "1.2"

function add_q2(subs, sel, active_line)
	for z, i in ipairs(sel) do
	    local l = subs[i]
		if l.text:match("\\q2") then
		l.text = l.text:gsub("\\q2","")
		l.text = l.text:gsub("{}","")
		else	
		l.text = "{\\q2}" .. l.text
		l.text = l.text:gsub("{\\q2}{\\","{\\q2\\")
		end
	    subs[i] = l
	end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, add_q2)