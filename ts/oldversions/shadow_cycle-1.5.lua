-- Adds \shad0 to selected lines, then cycles through 1, 2, 3, 4, 5, 6, 7, 8, 9, back to 0. 
-- Bind to a hotkey for better efficiency.

script_name = "Shadow cycle"
script_description = "Add shadow tags to selected lines."
script_author = "unanimated"
script_version = "1.5"

function shad(subs, sel, active_line)
	for z, i in ipairs(sel) do
	   local line=subs[i]
	   local text=subs[i].text
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
		
		if text:match("^{[^}]-\\shad[%d%.]*[\\}]") and not text:match("^{[^}]-\\shad[0123456789][\\}]") then
		text = text:gsub("^({[^}]-)\\shad[%d%.]*([\\}])","%1\\shad0%2")
		elseif text:match("^{[^}]-\\shad0[\\}]") then
		text = text:gsub("^({[^}]-)\\shad0","%1\\shad1")
		elseif text:match("^{[^}]-\\shad1[\\}]") then
		text = text:gsub("^({[^}]-)\\shad1","%1\\shad2")
		elseif text:match("^{[^}]-\\shad2[\\}]") then
		text = text:gsub("^({[^}]-)\\shad2","%1\\shad3")
		elseif text:match("^{[^}]-\\shad3[\\}]") then
		text = text:gsub("^({[^}]-)\\shad3","%1\\shad4")
		elseif text:match("^{[^}]-\\shad4[\\}]") then
		text = text:gsub("^({[^}]-)\\shad4","%1\\shad5")
		elseif text:match("^{[^}]-\\shad5[\\}]") then
		text = text:gsub("^({[^}]-)\\shad5","%1\\shad6")
		elseif text:match("^{[^}]-\\shad6[\\}]") then
		text = text:gsub("^({[^}]-)\\shad6","%1\\shad7")
		elseif text:match("^{[^}]-\\shad7[\\}]") then
		text = text:gsub("^({[^}]-)\\shad7","%1\\shad8")
		elseif text:match("^{[^}]-\\shad8[\\}]") then
		text = text:gsub("^({[^}]-)\\shad8","%1\\shad9")
		elseif text:match("^{[^}]-\\shad9[\\}]") then
		text = text:gsub("^({[^}]-)\\shad9","%1\\shad0")
		else
		text = "{\\shad0}" .. text
		text = text:gsub("({\\shad0)}{(\\[^}]*})","%1%2")
		end
		text=text:gsub("^({\\[^}]-)}","%1"..tf.."}")
	    line.text = text
	    subs[i] = line	
	end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, shad)