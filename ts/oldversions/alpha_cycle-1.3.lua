-- if an alpha tag exists, changes it to alphaFF, otherwise creates it
-- if there's alphaFF, cycles through 00, 30, 60. 80, A0, D0, FF

script_name = "Alpha cycle"
script_description = "Add alpha tags to selected lines."
script_author = "unanimated"
script_version = "1.3"

function alpha(subs, sel, active_line)
	for z, i in ipairs(sel) do
		local line = subs[i]
		local text = subs[i].text
		if text:match("\\t") then tf=text:match("(\\t%([^%)]-%))") 
		text = text:gsub("\\t%([^%)]+%)","\\_transform_") end
		
		if 	text:match("alpha&H") and
			text:match("alpha&HFF")==nil and
			text:match("alpha&H[0368AD]0")==nil
		then
		text = text:gsub("^({[^}]-)\\alpha&H..&","%1\\alpha&HFF&")
		elseif text:match("^{[^}]-\\alpha&HFF") then
		text = text:gsub("^({[^}]-)\\alpha&HFF&","%1\\alpha&H00&")
		elseif text:match("^{[^}]-\\alpha&H00") then
		text = text:gsub("^({[^}]-)\\alpha&H00&","%1\\alpha&H30&")
		elseif text:match("^{[^}]-\\alpha&H30") then
		text = text:gsub("^({[^}]-)\\alpha&H30&","%1\\alpha&H60&")
		elseif text:match("^{[^}]-\\alpha&H60") then
		text = text:gsub("^({[^}]-)\\alpha&H60&","%1\\alpha&H80&")
		elseif text:match("^{[^}]-\\alpha&H80") then
		text = text:gsub("^({[^}]-)\\alpha&H80&","%1\\alpha&HA0&")
		elseif text:match("^{[^}]-\\alpha&HA0") then
		text = text:gsub("^({[^}]-)\\alpha&HA0&","%1\\alpha&HD0&")
		elseif text:match("^{[^}]-\\alpha&HD0") then
		text = text:gsub("^({[^}]-)\\alpha&HD0&","%1\\alpha&HFF&")
		else
		text = "{\\alpha&HFF&}" .. text
		text = text:gsub("{\\alpha&HFF&}({\\[^}]*)}","%1\\alpha&HFF&}")
		end
		if tf~=nil then text = text:gsub("\\_transform_([^}]-)}","%1"..tf.."}") end
		line.text = text
		subs[i] = line	
	end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(script_name, script_description, alpha)