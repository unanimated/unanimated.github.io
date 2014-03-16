-- Adds \bord0 to selected lines, then cycles through 1, 2, 3, 4, 5, 6, 7, 8, 9, back to 0. 
-- Bind to a hotkey for better efficiency.

script_name = "Border cycle"
script_description = "Add border tags to selected lines."
script_author = "unanimated"
script_version = "1.5"

function bord(subs, sel, active_line)
	for z, i in ipairs(sel) do
	    local line = subs[i]
	    local text = subs[i].text
		tf=""
		if text:match("^{\\[^}]-}") then
		tags=text:match("^({\\[^}]-})")
		after=text:match("^{\\[^}]-}(.*)")
		  if tags:match("\\t") then 
		    for t in tags:gmatch("(\\t%([^%)]-%))") do tf=tf..t end
		    tags=tags:gsub("\\t%([^%)]+%)","")
		    text=tags..after
		  end
		end
		
		if text:match("^{[^}]-\\bord[%d%.]*[\\}]") and not text:match("^{[^}]-\\bord[0123456789][\\}]") then
		text = text:gsub("^({[^}]-)\\bord[%d%.]*([\\}])","%1\\bord0%2")
		elseif text:match("^{[^}]-\\bord0[\\}]") then
		text = text:gsub("^({[^}]-)\\bord0","%1\\bord1")
		elseif text:match("^{[^}]-\\bord1[\\}]") then
		text = text:gsub("^({[^}]-)\\bord1","%1\\bord2")
		elseif text:match("^{[^}]-\\bord2[\\}]") then
		text = text:gsub("^({[^}]-)\\bord2","%1\\bord3")
		elseif text:match("^{[^}]-\\bord3[\\}]") then
		text = text:gsub("^({[^}]-)\\bord3","%1\\bord4")
		elseif text:match("^{[^}]-\\bord4[\\}]") then
		text = text:gsub("^({[^}]-)\\bord4","%1\\bord5")
		elseif text:match("^{[^}]-\\bord5[\\}]") then
		text = text:gsub("^({[^}]-)\\bord5","%1\\bord6")
		elseif text:match("^{[^}]-\\bord6[\\}]") then
		text = text:gsub("^({[^}]-)\\bord6","%1\\bord7")
		elseif text:match("^{[^}]-\\bord7[\\}]") then
		text = text:gsub("^({[^}]-)\\bord7","%1\\bord8")
		elseif text:match("^{[^}]-\\bord8[\\}]") then
		text = text:gsub("^({[^}]-)\\bord8","%1\\bord9")
		elseif text:match("^{[^}]-\\bord9[\\}]") then
		text = text:gsub("^({[^}]-)\\bord9","%1\\bord0")
		else
		text = "{\\bord0}" .. text
		text = text:gsub("({\\bord0)}{(\\[^}]*})","%1%2")
		end
		text=text:gsub("^({\\[^}]-)}","%1"..tf.."}")
	    line.text = text
	    subs[i] = line
	end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, bord)